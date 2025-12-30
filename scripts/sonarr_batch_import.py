#!/usr/bin/env python3
"""
Batch-import existing TV shows into Sonarr.

Scans a local directory for series folders, looks up each show via the Sonarr API,
adds it with the desired profiles/root path, and triggers a rescan in 50-show batches.
"""

from __future__ import annotations

import argparse
import os
import sys
import textwrap
from pathlib import Path
from typing import Dict, List, Sequence

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Batch import existing series folders into Sonarr.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """
            Example:
              python3 sonarr_batch_import.py \\
                --url http://10.0.0.162:8989 \\
                --api-key 14aefefaaa8840e2bfd40e7056319b8f \\
                --local-path /mnt/synology/rs-tv \\
                --root-path /tv \\
                --quality-profile "Web-1080p" \\
                --batch-size 50
            """
        ),
    )
    parser.add_argument("--url", required=True, help="Base Sonarr URL (e.g. http://host:8989)")
    parser.add_argument("--api-key", required=True, help="Sonarr API key")
    parser.add_argument(
        "--local-path",
        required=True,
        help="Local path on Mother that contains the series folders to import",
    )
    parser.add_argument(
        "--root-path",
        required=True,
        help="Root folder path as seen by Sonarr inside the container (e.g. /tv)",
    )
    parser.add_argument(
        "--quality-profile",
        required=True,
        help="Quality profile name to apply to imported shows (case sensitive)",
    )
    parser.add_argument(
        "--language-profile",
        default=None,
        help="Language profile name to apply (defaults to Sonarr's first profile)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=50,
        help="Number of series to add per batch before triggering a rescan",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List the series that would be added without calling the API",
    )
    return parser.parse_args()


class SonarrClient:
    def __init__(self, base_url: str, api_key: str) -> None:
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers.update({"X-Api-Key": api_key})

    def _request(self, method: str, path: str, **kwargs):
        url = f"{self.base_url}/api/v3{path}"
        resp = self.session.request(method, url, timeout=60, **kwargs)
        resp.raise_for_status()
        if resp.content:
            return resp.json()
        return None

    def get(self, path: str):
        return self._request("GET", path)

    def post(self, path: str, json=None):
        return self._request("POST", path, json=json)


def lookup_series(client: SonarrClient, term: str):
    results = client.get(f"/series/lookup?term={requests.utils.quote(term)}")
    return results[0] if results else None


def fetch_profiles(client: SonarrClient, quality_name: str, lang_name: str | None):
    quality_profiles = client.get("/profile")
    quality_map = {p["name"]: p["id"] for p in quality_profiles}
    if quality_name not in quality_map:
        raise SystemExit(
            f"Quality profile '{quality_name}' not found. "
            f"Available: {', '.join(sorted(quality_map))}"
        )
    quality_id = quality_map[quality_name]

    lang_profiles = client.get("/languageprofile")
    if lang_name:
        lang_map = {p["name"]: p["id"] for p in lang_profiles}
        if lang_name not in lang_map:
            raise SystemExit(
                f"Language profile '{lang_name}' not found. "
                f"Available: {', '.join(sorted(lang_map))}"
            )
        lang_id = lang_map[lang_name]
    else:
        lang_id = lang_profiles[0]["id"]

    return quality_id, lang_id


def fetch_existing_series(client: SonarrClient) -> Dict[str, int]:
    existing = client.get("/series")
    return {Path(series["path"]).name.lower(): series["id"] for series in existing}


def chunked(seq: Sequence[str], size: int) -> List[List[str]]:
    return [list(seq[i : i + size]) for i in range(0, len(seq), size)]


def main():
    args = parse_args()
    local_root = Path(args.local_path)
    if not local_root.exists():
        raise SystemExit(f"Local path {local_root} does not exist.")

    client = SonarrClient(args.url, args.api_key)

    quality_id, language_id = fetch_profiles(client, args.quality_profile, args.language_profile)
    existing_series = fetch_existing_series(client)

    candidate_folders = [
        d.name
        for d in sorted(local_root.iterdir())
        if d.is_dir() and d.name.lower() not in existing_series
    ]

    if not candidate_folders:
        print("No new series folders found to import.")
        return

    print(f"Found {len(candidate_folders)} series folders not yet in Sonarr.")
    batches = chunked(candidate_folders, args.batch_size)

    for idx, batch in enumerate(batches, start=1):
        print(f"\n--- Batch {idx}/{len(batches)} ({len(batch)} series) ---")
        new_ids: List[int] = []
        for folder in batch:
            lookup = lookup_series(client, folder)
            if not lookup:
                print(f"  [SKIP] No lookup result for '{folder}'")
                continue

            payload = {
                "title": lookup["title"],
                "titleSlug": lookup["titleSlug"],
                "qualityProfileId": quality_id,
                "languageProfileId": language_id,
                "images": lookup.get("images", []),
                "seasons": lookup.get("seasons", []),
                "monitored": True,
                "seasonFolder": True,
                "seriesType": lookup.get("seriesType", "standard"),
                "path": os.path.join(args.root_path, folder),
                "rootFolderPath": args.root_path,
                "addOptions": {"searchForMissingEpisodes": False},
            }

            if args.dry_run:
                print(f"  [DRY-RUN] Would add {lookup['title']} -> {payload['path']}")
                continue

            # Sonarr expects tvdbId/imdbId in payload when available
            for key in ("tvdbId", "tvMazeId", "tmdbId", "imdbId"):
                if lookup.get(key):
                    payload[key] = lookup[key]

            result = client.post("/series", json=payload)
            new_ids.append(result["id"])
            print(f"  [ADDED] {result['title']} -> {payload['path']}")

        if new_ids and not args.dry_run:
            client.post("/command", json={"name": "RescanSeries", "seriesIds": new_ids})
            print(f"  Triggered rescan for {len(new_ids)} series in this batch.")

    print("\nDone.")


if __name__ == "__main__":
    try:
        main()
    except requests.HTTPError as exc:
        print(f"HTTP error: {exc} -> {exc.response.text}", file=sys.stderr)
        sys.exit(1)
