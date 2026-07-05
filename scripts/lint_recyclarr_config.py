#!/usr/bin/env python3
"""
Recyclarr Config Lint - Project Mother

Catches the class of bug found 2026-07-02: a `local-*` custom format referenced in
recyclarr.yml for a given service (radarr/sonarr) with no matching JSON definition
file and/or no registered `resource_providers` entry for that service in
settings.yml. `recyclarr sync --preview` only reports this as a silent "Invalid
trash_id" rather than failing loudly, so a real safety-net custom format (e.g. the
BHDStudio/MP4-container blocks) can be dead on arrival with no visible error.

Usage:
    python3 scripts/lint_recyclarr_config.py
    python3 scripts/lint_recyclarr_config.py --config-dir /opt/mother/configs/recyclarr

Exits non-zero if any local-* trash_id referenced in recyclarr.yml is missing its
JSON definition file or its service's resource_providers registration.
"""

import argparse
import json
import sys
from pathlib import Path

import yaml


class _RecyclarrLoader(yaml.SafeLoader):
    """recyclarr.yml uses a custom !env_var tag for secrets (e.g. api_key: !env_var
    RADARR_HD_API_KEY) that plain safe_load doesn't recognize. We don't need the
    resolved value for linting, just enough to parse the document."""
    pass


_RecyclarrLoader.add_constructor(
    '!env_var',
    lambda loader, node: loader.construct_scalar(node),
)


def find_local_trash_ids_by_service(recyclarr_yml: dict) -> dict:
    """Walk recyclarr.yml, return {service: {trash_id, ...}} for every local-* trash_id
    referenced anywhere under that service's instances."""
    referenced = {}
    for service in ('radarr', 'sonarr'):
        instances = recyclarr_yml.get(service) or {}
        found = set()
        for _inst_name, inst_cfg in instances.items():
            for cf_block in inst_cfg.get('custom_formats') or []:
                for trash_id in cf_block.get('trash_ids') or []:
                    if trash_id.startswith('local-'):
                        found.add(trash_id)
        if found:
            referenced[service] = found
    return referenced


def find_registered_providers(settings_yml: dict) -> dict:
    """Return {service: [provider names]} from settings.yml's resource_providers."""
    registered = {}
    for provider in settings_yml.get('resource_providers') or []:
        service = provider.get('service')
        if service:
            registered.setdefault(service, []).append(provider.get('name', '?'))
    return registered


def find_available_trash_ids(custom_formats_dir: Path, service: str) -> dict:
    """Scan configs/recyclarr/custom-formats/<service>/*.json, return
    {trash_id: filename} using each file's *internal* trash_id field (filenames
    don't necessarily match the trash_id, e.g. bhdstudio.json -> "local-bhdstudio")."""
    available = {}
    service_dir = custom_formats_dir / service
    if not service_dir.is_dir():
        return available
    for f in sorted(service_dir.glob('*.json')):
        try:
            data = json.loads(f.read_text())
        except json.JSONDecodeError as e:
            print(f"  ERROR: {f} is not valid JSON: {e}")
            continue
        trash_id = data.get('trash_id')
        if trash_id:
            available[trash_id] = f.name
    return available


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        '--config-dir',
        default='/opt/mother/configs/recyclarr',
        help='Path to configs/recyclarr (default: /opt/mother/configs/recyclarr)',
    )
    args = parser.parse_args()

    config_dir = Path(args.config_dir)
    recyclarr_yml_path = config_dir / 'recyclarr.yml'
    settings_yml_path = config_dir / 'settings.yml'
    custom_formats_dir = config_dir / 'custom-formats'

    for p in (recyclarr_yml_path, settings_yml_path):
        if not p.is_file():
            print(f"ERROR: {p} not found")
            sys.exit(2)

    recyclarr_yml = yaml.load(recyclarr_yml_path.read_text(), Loader=_RecyclarrLoader)
    settings_yml = yaml.safe_load(settings_yml_path.read_text())

    referenced = find_local_trash_ids_by_service(recyclarr_yml)
    registered_providers = find_registered_providers(settings_yml)

    errors = []

    for service, trash_ids in sorted(referenced.items()):
        print(f"[{service}] {len(trash_ids)} local-* trash_id(s) referenced: {sorted(trash_ids)}")

        # Check 1: resource_providers has an entry for this service
        if service not in registered_providers:
            errors.append(
                f"[{service}] no resource_providers entry with service: {service} in "
                f"settings.yml — local-* custom formats for this service will silently "
                f"fail to load (recyclarr reports 'Invalid trash_id', not an error)"
            )
        else:
            print(f"  OK: resource_providers registered ({registered_providers[service]})")

        # Check 2: every referenced trash_id has a JSON file defining it
        available = find_available_trash_ids(custom_formats_dir, service)
        for trash_id in sorted(trash_ids):
            if trash_id in available:
                print(f"  OK: {trash_id} -> {available[trash_id]}")
            else:
                errors.append(
                    f"[{service}] {trash_id} is referenced in recyclarr.yml but no JSON "
                    f"file under custom-formats/{service}/ defines a matching trash_id"
                )

    print()
    if errors:
        print(f"FAILED: {len(errors)} issue(s) found:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)

    print("OK: all local-* custom formats have both a JSON definition and a registered resource_provider.")
    sys.exit(0)


if __name__ == '__main__':
    main()
