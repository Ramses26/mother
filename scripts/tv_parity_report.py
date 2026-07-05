#!/usr/bin/env python3
"""
TV Library Parity Report — Synology vs Unraid
Generates an HTML report categorizing every episode discrepancy.

Categories:
  A. Missing from Unraid (Synology has it, Unraid doesn't) — gap scanner handles these
  B. Unraid-only (Unraid has it, Synology doesn't):
     - Filtered (720p/x265-no-HDR): Upgraderr will upgrade Synology; dedup cleans Unraid over time
     - Passable (1080p+): Unexpected — may need investigation
  C. Version mismatch (both have episode, different file — version reconcile handles these)

Usage:
  python3 /opt/mother/scripts/tv_parity_report.py
  OUTPUT=/tmp/tv_parity.html python3 /opt/mother/scripts/tv_parity_report.py
"""
import os
import re
import sys
import json
import time
import datetime
import requests
from collections import defaultdict

UNRAID_AGENT_URL = os.environ.get('UNRAID_AGENT_URL', 'http://192.168.1.10:8100')
UNRAID_AGENT_API_KEY = os.environ.get('UNRAID_AGENT_API_KEY', '')
SYNOLOGY_TV_ROOT = '/mnt/synology/rs-tv'
OUTPUT = os.environ.get('OUTPUT', '/opt/mother/reports/tv_parity_report.html')

EP_RE = re.compile(r'[Ss](\d{1,2})[Ee](\d{1,4})')
VIDEO_EXTS = ('.mkv', '.mp4', '.avi', '.ts', '.m4v', '.m2ts')
SKIP_NAMES = {'#recycle', '@eaDir', '.DS_Store'}


def ep_key(fname):
    m = EP_RE.search(fname)
    if m:
        return f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
    return None


def should_sync(filename):
    """Quality filter — same logic as _should_sync_tv_episode in app.py"""
    name = filename.lower()
    if re.search(r'\b(480p|576p|720p|sd)\b', name):
        return False, '720p/SD'
    if re.search(r'\b(hdtv|webrip|webdl|bluray|bdrip)[-\[]?720p\b', name):
        return False, '720p/SD'
    is_hevc = bool(re.search(r'\b(x265|h265|hevc|x\.265)\b', name))
    has_hdr = bool(re.search(r'\b(hdr10\+?|hdr10|hdr|dv|dovi|dolby\.?vision|hlg|pq)\b', name))
    if is_hevc and not has_hdr:
        return False, 'x265-no-HDR'
    return True, 'ok'


def scan_synology():
    """Returns dict: {(show_folder, ep_key): {'fname': ..., 'size': ..., 'path': ..., 'season': ...}}"""
    print("Scanning Synology rs-tv...", flush=True)
    eps = {}
    show_count = 0
    for show_entry in sorted(os.scandir(SYNOLOGY_TV_ROOT), key=lambda e: e.name):
        if not show_entry.is_dir() or show_entry.name in SKIP_NAMES:
            continue
        show_count += 1
        show_name = show_entry.name
        try:
            for season_entry in os.scandir(show_entry.path):
                if not season_entry.is_dir() or season_entry.name in SKIP_NAMES:
                    continue
                for f_entry in os.scandir(season_entry.path):
                    if not f_entry.is_file():
                        continue
                    fname = f_entry.name
                    if not fname.lower().endswith(VIDEO_EXTS):
                        continue
                    key = ep_key(fname)
                    if not key:
                        continue
                    k = (show_name, key)
                    stat = f_entry.stat()
                    # Keep largest file per (show, ep_key)
                    if k not in eps or stat.st_size > eps[k]['size']:
                        eps[k] = {
                            'fname': fname,
                            'size': stat.st_size,
                            'path': f_entry.path,
                            'season': season_entry.name,
                        }
        except PermissionError:
            pass
    print(f"  Synology: {show_count} shows, {len(eps)} episodes total", flush=True)
    return eps


def scan_unraid():
    """Returns dict: {(show_folder, ep_key): {'fname': ..., 'size': ..., 'path': ...}}"""
    print("Fetching Unraid Agent inventory (may take ~60s)...", flush=True)
    resp = requests.get(
        f"{UNRAID_AGENT_URL}/inventory",
        params={'path': '/mnt/user/Media/TV Shows', 'refresh': 'true'},
        headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
        timeout=240,
    )
    resp.raise_for_status()
    data = resp.json()
    items = data.get('items', [])
    print(f"  Agent returned {len(items)} items", flush=True)

    eps = {}
    for item in items:
        path = item.get('path', '')
        parts = path.split('/')
        # /mnt/user/Media/TV Shows/<show>/<season>/<file>
        if len(parts) < 8:
            continue
        show_folder = parts[5]
        fname = parts[-1]
        if not fname.lower().endswith(VIDEO_EXTS):
            continue
        key = ep_key(fname)
        if not key:
            continue
        k = (show_folder, key)
        size = item.get('size_bytes', 0)
        if k not in eps or size > eps[k]['size']:
            eps[k] = {
                'fname': fname,
                'size': size,
                'path': path,
            }
    # Count unique shows
    shows = {k[0] for k in eps}
    print(f"  Unraid: {len(shows)} shows, {len(eps)} episodes total", flush=True)
    return eps


def fmt_size(b):
    if b >= 1_099_511_627_776:
        return f"{b/1_099_511_627_776:.1f} TB"
    if b >= 1_073_741_824:
        return f"{b/1_073_741_824:.1f} GB"
    if b >= 1_048_576:
        return f"{b/1_048_576:.0f} MB"
    return f"{b:,} B"


def quality_badge(fname, reason=None):
    if reason == '720p/SD':
        return '<span class="badge bad">720p/SD</span>'
    if reason == 'x265-no-HDR':
        return '<span class="badge warn">x265 no-HDR</span>'
    name = fname.lower()
    badges = []
    if 'remux' in name:
        badges.append('<span class="badge best">Remux</span>')
    elif 'bluray' in name or 'bdmv' in name:
        badges.append('<span class="badge good">BluRay</span>')
    elif 'web-dl' in name or 'webdl' in name:
        badges.append('<span class="badge ok">WEB-DL</span>')
    elif 'webrip' in name:
        badges.append('<span class="badge warn">WEBRip</span>')
    if re.search(r'\b(hdr10\+|hdr10|hdr|dv|dolby.vision)\b', name):
        badges.append('<span class="badge hdr">HDR</span>')
    if re.search(r'\b(2160p|4k|uhd)\b', name):
        badges.append('<span class="badge res4k">4K</span>')
    elif '1080p' in name:
        badges.append('<span class="badge res">1080p</span>')
    elif '720p' in name:
        badges.append('<span class="badge bad">720p</span>')
    return ' '.join(badges) or '<span class="badge ok">Unknown</span>'


def build_html(missing_from_unraid, unraid_only_filtered, unraid_only_passable, version_mismatch, ts):
    now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')

    def count_eps(d):
        return sum(len(v) for v in d.values())

    def total_size(items):
        return sum(ep['size'] for ep in items)

    def show_table_missing(by_show, title, desc, color):
        rows = []
        for show in sorted(by_show):
            eps = sorted(by_show[show], key=lambda e: e['ep_key'])
            rows.append(f'<tr class="show-header"><td colspan="4"><strong>{show}</strong> <span class="ep-count">({len(eps)} episode{"s" if len(eps)!=1 else ""})</span></td></tr>')
            for ep in eps:
                sync_ok, reason = should_sync(ep.get('fname', ep.get('syn_fname', '')))
                fname = ep.get('fname', ep.get('syn_fname', ''))
                rows.append(f'<tr><td class="ep-key">{ep["ep_key"]}</td><td class="fname">{fname}</td><td>{quality_badge(fname)}</td><td class="size">{fmt_size(ep["size"])}</td></tr>')
        if not rows:
            return ''
        return f'''
        <section>
          <h2 style="border-left:4px solid {color};padding-left:12px">{title}</h2>
          <p class="desc">{desc}</p>
          <table>
            <thead><tr><th>Episode</th><th>File</th><th>Quality</th><th>Size</th></tr></thead>
            <tbody>{"".join(rows)}</tbody>
          </table>
        </section>'''

    def show_table_unraid_only(by_show, title, desc, color):
        rows = []
        for show in sorted(by_show):
            eps = sorted(by_show[show], key=lambda e: e['ep_key'])
            rows.append(f'<tr class="show-header"><td colspan="4"><strong>{show}</strong> <span class="ep-count">({len(eps)} episode{"s" if len(eps)!=1 else ""})</span></td></tr>')
            for ep in eps:
                rows.append(f'<tr><td class="ep-key">{ep["ep_key"]}</td><td class="fname">{ep["fname"]}</td><td>{quality_badge(ep["fname"], ep.get("filter_reason"))}</td><td class="size">{fmt_size(ep["size"])}</td></tr>')
        if not rows:
            return ''
        return f'''
        <section>
          <h2 style="border-left:4px solid {color};padding-left:12px">{title}</h2>
          <p class="desc">{desc}</p>
          <table>
            <thead><tr><th>Episode</th><th>File</th><th>Quality</th><th>Size</th></tr></thead>
            <tbody>{"".join(rows)}</tbody>
          </table>
        </section>'''

    # Mismatch table shows both filenames
    def show_table_mismatch(by_show, title, desc):
        rows = []
        for show in sorted(by_show):
            eps = sorted(by_show[show], key=lambda e: e['ep_key'])
            rows.append(f'<tr class="show-header"><td colspan="3"><strong>{show}</strong> <span class="ep-count">({len(eps)} episode{"s" if len(eps)!=1 else ""})</span></td></tr>')
            for ep in eps:
                rows.append(f'''<tr>
                  <td class="ep-key">{ep["ep_key"]}</td>
                  <td>
                    <div class="fname syn">SYN: {ep["syn_fname"]}</div>
                    <div class="fname raid">RAID: {ep["unraid_fname"]}</div>
                  </td>
                  <td>
                    {quality_badge(ep["syn_fname"])}<br>
                    {quality_badge(ep["unraid_fname"])}
                  </td>
                </tr>''')
        if not rows:
            return ''
        return f'''
        <section>
          <h2 style="border-left:4px solid #9b59b6;padding-left:12px">{title}</h2>
          <p class="desc">{desc}</p>
          <table>
            <thead><tr><th>Episode</th><th>Files (Syn → Raid)</th><th>Quality</th></tr></thead>
            <tbody>{"".join(rows)}</tbody>
          </table>
        </section>'''

    # Aggregate stats
    total_missing = count_eps(missing_from_unraid)
    total_filtered = count_eps(unraid_only_filtered)
    total_passable = count_eps(unraid_only_passable)
    total_mismatch = count_eps(version_mismatch)
    size_filtered = sum(total_size(v) for v in unraid_only_filtered.values())
    size_passable = sum(total_size(v) for v in unraid_only_passable.values())

    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>TV Parity Report — {now}</title>
<style>
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{ font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; background:#0f1117; color:#e0e0e0; padding:24px; }}
  h1 {{ font-size:1.6rem; margin-bottom:6px; color:#fff; }}
  .sub {{ color:#888; font-size:0.85rem; margin-bottom:28px; }}
  .summary {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin-bottom:32px; }}
  .card {{ background:#1a1d27; border-radius:8px; padding:18px 20px; border:1px solid #2a2d3a; }}
  .card .num {{ font-size:2rem; font-weight:700; }}
  .card .lbl {{ font-size:0.8rem; color:#888; margin-top:2px; }}
  .card.green .num {{ color:#27ae60; }}
  .card.red .num {{ color:#e74c3c; }}
  .card.amber .num {{ color:#f39c12; }}
  .card.blue .num {{ color:#3498db; }}
  .card.purple .num {{ color:#9b59b6; }}
  section {{ margin-bottom:40px; }}
  h2 {{ font-size:1.1rem; margin-bottom:8px; color:#fff; }}
  .desc {{ font-size:0.82rem; color:#888; margin-bottom:14px; line-height:1.5; }}
  table {{ width:100%; border-collapse:collapse; font-size:0.82rem; }}
  th {{ background:#1a1d27; color:#aaa; text-align:left; padding:7px 10px; border-bottom:1px solid #2a2d3a; }}
  td {{ padding:5px 10px; border-bottom:1px solid #1e2130; vertical-align:top; }}
  tr.show-header td {{ background:#1a1d27; color:#ccc; font-size:0.83rem; padding:8px 10px; border-top:2px solid #2a2d3a; }}
  .ep-key {{ font-family:monospace; color:#888; white-space:nowrap; width:70px; }}
  .ep-count {{ color:#666; font-weight:normal; font-size:0.78rem; }}
  .fname {{ font-family:monospace; font-size:0.75rem; color:#bbb; word-break:break-all; }}
  .fname.syn {{ color:#27ae60; }}
  .fname.raid {{ color:#e74c3c; }}
  .size {{ white-space:nowrap; color:#888; }}
  .badge {{ display:inline-block; font-size:0.65rem; padding:2px 6px; border-radius:3px; margin:1px; font-weight:600; text-transform:uppercase; }}
  .badge.best {{ background:#1a4a2e; color:#27ae60; }}
  .badge.good {{ background:#1a3a50; color:#3498db; }}
  .badge.ok {{ background:#1a3040; color:#5dade2; }}
  .badge.warn {{ background:#3d2e1a; color:#f39c12; }}
  .badge.bad {{ background:#3d1a1a; color:#e74c3c; }}
  .badge.hdr {{ background:#2d1a4a; color:#9b59b6; }}
  .badge.res {{ background:#1a2a3a; color:#7fb3d3; }}
  .badge.res4k {{ background:#2a1a3a; color:#a89de0; }}
</style>
</head>
<body>
<h1>TV Library Parity Report</h1>
<p class="sub">Generated {now} &nbsp;|&nbsp; Synology rs-tv ↔ Unraid /mnt/user/Media/TV Shows</p>

<div class="summary">
  <div class="card red"><div class="num">{total_missing}</div><div class="lbl">Missing from Unraid<br>(gap scanner queues these)</div></div>
  <div class="card amber"><div class="num">{total_filtered:,}</div><div class="lbl">Unraid-only — 720p / x265-no-HDR<br>{fmt_size(size_filtered)} &nbsp;•&nbsp; Dedup cleans over time</div></div>
  <div class="card blue"><div class="num">{total_passable:,}</div><div class="lbl">Unraid-only — 1080p+ passable<br>{fmt_size(size_passable)} &nbsp;•&nbsp; Needs investigation</div></div>
  <div class="card purple"><div class="num">{total_mismatch:,}</div><div class="lbl">Version mismatch<br>(version reconcile handles)</div></div>
</div>

{show_table_missing(missing_from_unraid,
    "A. Missing from Unraid",
    "Episodes present on Synology but absent from Unraid. The nightly TV gap scanner queues these automatically.",
    "#e74c3c")}

{show_table_unraid_only(unraid_only_passable,
    f"B1. Unraid-only — 1080p+ Passable ({total_passable:,} episodes, {fmt_size(size_passable)})",
    "Episodes present on Unraid but NOT on Synology, that WOULD pass the quality filter. These are unexpected — likely deleted from Synology by Sonarr (import of better version) but not yet removed from Unraid by dedup.",
    "#3498db")}

{show_table_unraid_only(unraid_only_filtered,
    f"B2. Unraid-only — 720p/x265-no-HDR ({total_filtered:,} episodes, {fmt_size(size_filtered)})",
    "Episodes on Unraid that don't exist on Synology OR exist only in lower-quality form, filtered by the sync quality gate (720p/SD or x265 without HDR/DV). These were batch-synced before quality filters existed. Upgraderr will upgrade Synology copies over time → webhook propagates → nightly dedup removes these.",
    "#f39c12")}

{show_table_mismatch(version_mismatch,
    f"C. Version Mismatch ({total_mismatch:,} episodes)",
    "Both sides have the episode but different file versions. The TV version reconcile (11:15 PM nightly, capped at 20/run) scores both and syncs Synology→Unraid only when Synology scores higher.")}

</body>
</html>'''
    return html


def main():
    global UNRAID_AGENT_API_KEY
    t0 = time.time()

    if not UNRAID_AGENT_API_KEY:
        env_path = '/opt/mother/.env'
        if os.path.exists(env_path):
            with open(env_path) as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('UNRAID_AGENT_API_KEY='):
                        UNRAID_AGENT_API_KEY = line.split('=', 1)[1].strip('"\'')
                        break

    syn_eps = scan_synology()
    unraid_eps = scan_unraid()

    print("Comparing...", flush=True)

    # Build show→[ep] maps for each category
    missing_from_unraid = defaultdict(list)     # on Syn, not on Unraid
    unraid_only_filtered = defaultdict(list)    # on Unraid, not on Syn (filtered quality)
    unraid_only_passable = defaultdict(list)    # on Unraid, not on Syn (passable quality)
    version_mismatch = defaultdict(list)        # both have it, different file

    # Episodes on Synology
    for (show, epk), syn_info in syn_eps.items():
        sync_ok, reason = should_sync(syn_info['fname'])
        if not sync_ok:
            continue  # Synology has 720p/x265 — gap scanner already filters; skip in this report
        if (show, epk) not in unraid_eps:
            missing_from_unraid[show].append({
                'ep_key': epk,
                'fname': syn_info['fname'],
                'size': syn_info['size'],
                'season': syn_info.get('season', ''),
            })
        else:
            # Both have it — check if filenames differ
            unraid_fname = unraid_eps[(show, epk)]['fname']
            if syn_info['fname'] != unraid_fname:
                version_mismatch[show].append({
                    'ep_key': epk,
                    'syn_fname': syn_info['fname'],
                    'unraid_fname': unraid_fname,
                    'syn_size': syn_info['size'],
                    'unraid_size': unraid_eps[(show, epk)]['size'],
                })

    # Episodes on Unraid not on Synology (by episode key)
    syn_keys = set(syn_eps.keys())
    for (show, epk), unraid_info in unraid_eps.items():
        if (show, epk) not in syn_keys:
            sync_ok, reason = should_sync(unraid_info['fname'])
            entry = {
                'ep_key': epk,
                'fname': unraid_info['fname'],
                'size': unraid_info['size'],
                'filter_reason': reason if not sync_ok else None,
            }
            if sync_ok:
                unraid_only_passable[show].append(entry)
            else:
                unraid_only_filtered[show].append(entry)

    # Stats
    print(f"\n=== RESULTS ===")
    print(f"Missing from Unraid (gap scanner): {sum(len(v) for v in missing_from_unraid.values())} eps across {len(missing_from_unraid)} shows")
    print(f"Unraid-only passable (1080p+):     {sum(len(v) for v in unraid_only_passable.values())} eps across {len(unraid_only_passable)} shows")
    print(f"Unraid-only filtered (720p/x265):  {sum(len(v) for v in unraid_only_filtered.values())} eps across {len(unraid_only_filtered)} shows")
    print(f"Version mismatch:                  {sum(len(v) for v in version_mismatch.values())} eps across {len(version_mismatch)} shows")
    print(f"Elapsed: {time.time()-t0:.0f}s", flush=True)

    html = build_html(missing_from_unraid, unraid_only_filtered, unraid_only_passable, version_mismatch, time.time()-t0)
    with open(OUTPUT, 'w') as f:
        f.write(html)
    print(f"\nReport written to: {OUTPUT}")


if __name__ == '__main__':
    main()
