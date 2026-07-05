#!/usr/bin/env python3
"""
Verify Upgraderr Scoring Migration - Project Mother

Compares the old private scoring module (scripts/lib/quality_scoring.py) against
the new shared-JSON-backed module (scripts/lib/trash_scoring_json.py) over real
production filenames pulled from the live Upgraderr DB, before the app.py import
swap is deployed.

Reports:
  - Field mismatches (resolution/source/hdr/audio/codec differing between old and
    new parse) — should be zero, or fully explained by the documented DVDRip gap
    (which the parser can never actually produce, per code comments).
  - Tier 6 threshold flips (old_score < MIN_SCORE vs new_score < MIN_SCORE
    disagreeing) — the one decision-relevant metric; each flip changes whether a
    real movie/episode enters the "needs upgrade search" tier.
  - Raw score delta distribution, for general sanity.

Usage:
    python3 scripts/verify_upgraderr_scoring_migration.py
    python3 scripts/verify_upgraderr_scoring_migration.py --db /path/to/upgraderr.db
"""

import argparse
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from scripts.lib.quality_scoring import (
    parse_quality_from_filename as old_parse,
    calculate_quality_score as old_score,
)
from scripts.lib.trash_scoring_json import (
    parse_quality_from_filename as new_parse,
    calculate_quality_score as new_score,
)

MIN_SCORE = 200  # UPGRADERR_MIN_SCORE default; override below if config table says otherwise


def load_samples(con):
    rows = []
    for r in con.execute("""
        SELECT instance, media_type, after_quality AS fn
        FROM upgrade_history WHERE after_quality IS NOT NULL AND after_quality != ''
    """):
        rows.append(r)
    for r in con.execute("""
        SELECT instance, media_type, before_quality AS fn
        FROM upgrade_queue WHERE before_quality IS NOT NULL AND before_quality != ''
    """):
        rows.append(r)
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--db', default='/opt/mother/data/upgraderr/upgraderr.db')
    args = parser.parse_args()

    con = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row

    min_score = MIN_SCORE
    row = con.execute("SELECT value FROM config WHERE key='min_score'").fetchone()
    if row:
        min_score = int(row['value'])
        print(f"Using live-configured min_score={min_score} (not the {MIN_SCORE} default)")

    samples = load_samples(con)
    print(f"Loaded {len(samples)} real filenames from upgrade_history + upgrade_queue\n")

    field_mismatches = []
    tier6_flips = []
    deltas = []
    dvdrip_related = 0

    for row in samples:
        fn = row['fn']
        is_4k = '4k' in (row['instance'] or '').lower()
        mtype = 'tv' if row['media_type'] != 'movie' else 'movie'

        old_q, new_q = old_parse(fn), new_parse(fn)
        row_mismatch = False
        for field in ('resolution', 'source', 'hdr', 'audio', 'codec'):
            if old_q.get(field) != new_q.get(field):
                field_mismatches.append((fn, field, old_q.get(field), new_q.get(field)))
                row_mismatch = True
        if row_mismatch and (old_q.get('source') == 'DVDRip' or new_q.get('source') == 'DVDRip'):
            dvdrip_related += 1

        old_s = old_score(resolution=old_q['resolution'] or 'Unknown', source=old_q['source'] or 'Unknown',
                           hdr=old_q['hdr'] or '', audio=old_q['audio'] or '', codec=old_q['codec'] or '',
                           size_gb=0, is_4k=is_4k, media_type=mtype)
        new_s = new_score(resolution=new_q['resolution'] or 'Unknown', source=new_q['source'] or 'Unknown',
                           hdr=new_q['hdr'] or '', audio=new_q['audio'] or '', codec=new_q['codec'] or '',
                           size_gb=0, is_4k=is_4k, media_type=mtype)
        deltas.append(new_s - old_s)
        if (old_s < min_score) != (new_s < min_score):
            tier6_flips.append((fn, old_s, new_s))

    print(f"=== Field mismatches: {len(field_mismatches)} ({dvdrip_related} DVDRip-related) ===")
    for fn, field, old_v, new_v in field_mismatches[:30]:
        print(f"  [{field}] old={old_v!r} new={new_v!r}  <- {fn}")
    if len(field_mismatches) > 30:
        print(f"  ... and {len(field_mismatches) - 30} more")

    print(f"\n=== Tier 6 threshold flips (score < {min_score}): {len(tier6_flips)} ===")
    for fn, old_s, new_s in tier6_flips:
        print(f"  old={old_s} new={new_s}  <- {fn}")

    if deltas:
        print(f"\n=== Score delta (new - old): min={min(deltas)} max={max(deltas)} "
              f"mean={sum(deltas)/len(deltas):.1f} ===")

    print()
    if field_mismatches and field_mismatches != [] and len(field_mismatches) > dvdrip_related:
        print("RESULT: field mismatches found beyond the documented DVDRip gap — investigate before deploying.")
        sys.exit(1)
    if tier6_flips:
        print("RESULT: Tier 6 threshold flips found — review each one individually before deploying.")
        sys.exit(1)
    print("RESULT: clean — no unexplained field mismatches, no Tier 6 flips. Safe to deploy.")
    sys.exit(0)


if __name__ == '__main__':
    main()
