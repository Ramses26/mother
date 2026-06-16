"""Curatorr rules engine — evaluate conditions and execute actions."""
import json
import logging
from datetime import datetime, timezone
from typing import Any
from app.log_events import log_event

log = logging.getLogger('curatorr.rules_engine')

# Direct DB column fields — (column_name, python_type)
FIELD_MAP_MOVIES = {
    'composite_score':      ('composite_score', float),
    'imdb_rating':          ('imdb_rating', float),
    'rt_critics':           ('rt_critics', int),
    'metacritic':           ('metacritic', int),
    'tmdb_rating':          ('tmdb_rating', float),
    'mdblist_score':        ('mdblist_score', int),
    'purge_score':          ('purge_score', int),
    'ali_play_count':       ('ali_play_count', int),
    'chris_play_count':     ('chris_play_count', int),
    'file_size_gb':         ('file_size_bytes', float),   # converted below
    'resolution':           ('resolution', str),
    'year':                 ('year', int),
    'monitored':            ('monitored', int),
    'hdr_format':           ('hdr_format', str),
    'audio_codec':          ('audio_codec', str),
    'genre':                ('genres', str),              # JSON contains check
}

FIELD_MAP_TV = {
    'composite_score':      ('composite_score', float),
    'imdb_rating':          ('imdb_rating', float),
    'rt_critics':           ('rt_critics', int),
    'metacritic':           ('metacritic', int),
    'tmdb_rating':          ('tmdb_rating', float),
    'mdblist_score':        ('mdblist_score', int),
    'purge_score':          ('purge_score', int),
    'ali_play_count':       ('ali_play_count', int),
    'chris_play_count':     ('chris_play_count', int),
    'year':                 ('year', int),
    'monitored':            ('monitored', int),
    'status':               ('status', str),
    'season_completion_pct': ('season_completion_pct', float),
}

# Computed fields — derived at evaluation time (not direct DB columns)
# These are handled separately in _evaluate_condition before the field_map lookup.
COMPUTED_FIELDS = {
    'days_since_added',
    'days_since_last_watched',
    'never_watched',
    'total_plays',
    'has_overseerr_request',   # populated externally by evaluate_rule
}


def _days_ago(date_str: str | None) -> int | None:
    """Return integer days since a date string, or None if not parseable."""
    if not date_str:
        return None
    try:
        dt = datetime.fromisoformat(str(date_str).replace('Z', '+00:00'))
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return (datetime.now(timezone.utc) - dt).days
    except Exception:
        return None


def _enrich_item(item: dict, media_type: str) -> dict:
    """Add computed fields to an item dict before condition evaluation."""
    # days_since_added — plex_added_at first, then radarr/sonarr added_at, then last_synced
    added_at = (item.get('plex_added_at') or
                item.get('radarr_added_at') or
                item.get('last_synced'))
    item['days_since_added'] = _days_ago(added_at)

    # days_since_last_watched — max of ali + chris last_watched
    ali_lw = item.get('ali_last_watched')
    chris_lw = item.get('chris_last_watched')
    last_watched = max(
        ali_lw or '', chris_lw or ''
    ) or None  # empty string if both None
    item['days_since_last_watched'] = _days_ago(last_watched) if last_watched else None

    # never_watched — True when both play counts are 0
    ali = item.get('ali_play_count') or 0
    chris = item.get('chris_play_count') or 0
    item['never_watched'] = 1 if (ali == 0 and chris == 0) else 0

    # total_plays — combined
    item['total_plays'] = ali + chris

    return item


def _evaluate_condition(item: dict, condition: dict, media_type: str) -> tuple[bool, str]:
    """Evaluate a single condition against an item. Returns (matches, reason)."""
    field = condition.get('field', '')
    operator = condition.get('operator', 'eq')
    value = condition.get('value')

    # --- Computed fields (not in field_map) ---
    if field in COMPUTED_FIELDS:
        item_val = item.get(field)

        if operator == 'is_null':
            return item_val is None, f"{field} is null (actual: {item_val})"
        if operator == 'is_not_null':
            return item_val is not None, f"{field} is not null (actual: {item_val})"

        # never_watched is boolean — eq/ne with 1/0
        if field == 'never_watched':
            try:
                cmp = int(value) if value is not None else 1
            except (ValueError, TypeError):
                cmp = 1
            if operator in ('eq', 'is_true'):
                result = item_val == cmp
            elif operator in ('ne', 'is_false'):
                result = item_val != cmp
            else:
                result = False
            return result, f"{field} {operator} {cmp} (actual: {item_val})"

        # days_since_* and total_plays — numeric
        if item_val is None:
            return False, f"{field} is null (no date)"
        try:
            cmp = int(value) if value is not None else 0
        except (ValueError, TypeError):
            return False, f"Invalid value for {field}: {value}"

        if operator == 'eq':    result = item_val == cmp
        elif operator == 'ne':  result = item_val != cmp
        elif operator == 'gt':  result = item_val > cmp
        elif operator == 'gte': result = item_val >= cmp
        elif operator == 'lt':  result = item_val < cmp
        elif operator == 'lte': result = item_val <= cmp
        else:                   result = False
        return result, f"{field} {operator} {cmp} (actual: {item_val})"

    # --- Standard DB column fields ---
    field_map = FIELD_MAP_MOVIES if media_type == 'movie' else FIELD_MAP_TV
    if field not in field_map:
        return False, f"Unknown field: {field}"

    col_name, col_type = field_map[field]
    item_val = item.get(col_name)

    # file_size_gb: convert bytes → GB
    if field == 'file_size_gb' and item_val is not None:
        item_val = item_val / 1_073_741_824.0

    # Type-coerce the rule value
    try:
        if col_type == float and value is not None:
            value = float(value)
        elif col_type == int and value is not None:
            value = int(value)
        elif col_type == str and value is not None:
            value = str(value)
    except (ValueError, TypeError):
        return False, f"Invalid value type for {field}"

    if item_val is None:
        if operator in ('is_null', 'is_empty'):
            return True, f"{field} is null"
        return False, f"{field} is null"

    if operator == 'eq':            result = item_val == value
    elif operator == 'ne':          result = item_val != value
    elif operator == 'gt':          result = item_val > value
    elif operator == 'gte':         result = item_val >= value
    elif operator == 'lt':          result = item_val < value
    elif operator == 'lte':         result = item_val <= value
    elif operator == 'contains':    result = str(value).lower() in str(item_val).lower()
    elif operator == 'not_contains': result = str(value).lower() not in str(item_val).lower()
    elif operator == 'is_null':     result = False  # item_val is not None here
    elif operator == 'is_not_null': result = True
    else:                           result = False

    reason = f"{field} {operator} {value} (actual: {item_val})"
    return result, reason


def _item_matches_rule(item: dict, rule: dict, media_type: str) -> tuple[bool, list[str]]:
    """Check if item matches all/any rule conditions."""
    try:
        conditions = json.loads(rule.get('conditions', '[]'))
    except Exception:
        conditions = []

    if not conditions:
        return False, []

    logic = rule.get('condition_logic', 'AND').upper()
    matched_reasons = []
    failed_reasons = []

    for cond in conditions:
        matches, reason = _evaluate_condition(item, cond, media_type)
        if matches:
            matched_reasons.append(reason)
        else:
            failed_reasons.append(reason)

    if logic == 'AND':
        result = len(failed_reasons) == 0
    else:  # OR
        result = len(matched_reasons) > 0

    return result, matched_reasons


async def evaluate_rule(rule: dict, db, dry_run: bool = True) -> list[dict]:
    """Evaluate rule against all matching media. Returns list of matching items."""
    media_type = rule.get('media_type')
    types_to_check = []

    if media_type == 'movie':
        types_to_check = [('movie', 'movies')]
    elif media_type == 'tv':
        types_to_check = [('tv', 'tv_shows')]
    else:
        types_to_check = [('movie', 'movies'), ('tv', 'tv_shows')]

    matches = []

    for mt, table in types_to_check:
        if table == 'movies':
            cols = ("id, title, year, composite_score, imdb_rating, rt_critics, metacritic, "
                    "tmdb_rating, mdblist_score, purge_score, ali_play_count, chris_play_count, "
                    "file_size_bytes, resolution, monitored, hdr_format, audio_codec, genres, "
                    "plex_added_at, radarr_added_at, last_synced, ali_last_watched, chris_last_watched")
        else:
            cols = ("id, title, year, composite_score, imdb_rating, rt_critics, metacritic, "
                    "tmdb_rating, mdblist_score, purge_score, ali_play_count, chris_play_count, "
                    "monitored, status, season_completion_pct, "
                    "plex_added_at, last_synced, ali_last_watched, chris_last_watched")

        async with db.execute(f"SELECT {cols} FROM {table} LIMIT 10000") as cur:
            items = await cur.fetchall()

        # Build Overseerr tmdb_id lookup for this table
        overseerr_tmdb_ids: set = set()
        try:
            async with db.execute(
                "SELECT DISTINCT tmdb_id FROM overseerr_requests "
                "WHERE tmdb_id IS NOT NULL AND status IN (1,2,5)"  # pending/approved/processing
            ) as cur:
                overseerr_tmdb_ids = {r[0] for r in await cur.fetchall()}
        except Exception:
            pass

        for row in items:
            item = dict(row)
            item['media_type'] = mt
            _enrich_item(item, mt)   # add computed fields
            item['has_overseerr_request'] = 1 if item.get('tmdb_id') in overseerr_tmdb_ids else 0
            matched, reasons = _item_matches_rule(item, rule, mt)
            if matched:
                item['reasons'] = reasons
                matches.append(item)

    return matches


async def execute_rule_matches(rule: dict, db) -> dict:
    """Execute the rule's action on all non-excluded staged matches."""
    async with db.execute(
        "SELECT * FROM rule_matches WHERE rule_id=? AND excluded_by_user=0 AND action_taken IS NULL",
        (rule['id'],)
    ) as cur:
        pending = await cur.fetchall()

    action = rule.get('action', 'stage')
    executed = 0
    errors = 0

    for match in pending:
        match = dict(match)
        try:
            if action == 'stage':
                await db.execute(
                    "UPDATE rule_matches SET action_taken='staged', acted_at=CURRENT_TIMESTAMP WHERE id=?",
                    (match['id'],)
                )
            elif action == 'unmonitor':
                media_type = match['media_type']
                media_id = match['media_id']
                if media_type == 'movie':
                    await db.execute(
                        "UPDATE movies SET monitored=0, updated_at=CURRENT_TIMESTAMP WHERE id=?",
                        (media_id,)
                    )
                else:
                    await db.execute(
                        "UPDATE tv_shows SET monitored=0, updated_at=CURRENT_TIMESTAMP WHERE id=?",
                        (media_id,)
                    )
                await db.execute(
                    "UPDATE rule_matches SET action_taken='unmonitored', acted_at=CURRENT_TIMESTAMP WHERE id=?",
                    (match['id'],)
                )
            elif action in ('delete', 'notify'):
                await db.execute(
                    "UPDATE rule_matches SET action_taken='staged_for_delete', acted_at=CURRENT_TIMESTAMP WHERE id=?",
                    (match['id'],)
                )
            executed += 1
        except Exception as e:
            log.error(f"Error executing match {match['id']}: {e}")
            errors += 1

    await db.commit()

    if rule.get('notify'):
        from app.notifications import send_notification
        send_notification(
            f"Curatorr Rule '{rule['name']}' executed\n"
            f"Action: {action} | Items: {executed} | Errors: {errors}"
        )

    return {'executed': executed, 'errors': errors, 'action': action}


async def run_all_scheduled_rules(db):
    """Run all enabled rules with daily/weekly schedule."""
    async with db.execute(
        "SELECT * FROM rules WHERE enabled=1 AND schedule IN ('daily', 'weekly')"
    ) as cur:
        rules = await cur.fetchall()

    for rule in rules:
        rule = dict(rule)
        try:
            matches = await evaluate_rule(rule, db, dry_run=False)
            log.info(f"Rule '{rule['name']}' matched {len(matches)} items")
            new_ids = {m['id'] for m in matches}
            async with db.execute(
                "SELECT media_id FROM rule_matches WHERE rule_id=? AND excluded_by_user=0",
                (rule['id'],)
            ) as _cur:
                existing_ids = {row[0] for row in await _cur.fetchall()}
            for stale_id in existing_ids - new_ids:
                await db.execute(
                    "DELETE FROM rule_matches WHERE rule_id=? AND media_id=? AND excluded_by_user=0",
                    (rule['id'], stale_id)
                )
            for m in matches:
                if m['id'] not in existing_ids:
                    await db.execute("""
                        INSERT INTO rule_matches
                        (rule_id, media_type, media_id, title, match_reason)
                        VALUES (?,?,?,?,?)
                    """, (rule['id'], m['media_type'], m['id'], m['title'],
                          json.dumps(m.get('reasons', []))))
            await db.execute(
                "UPDATE rules SET last_run=CURRENT_TIMESTAMP, last_match_count=? WHERE id=?",
                (len(matches), rule['id'])
            )
            await log_event(db, 'rule', rule['name'], f"Rule matched {len(matches)} items")
            await db.commit()

            if rule.get('notify') and matches:
                from app.notifications import send_notification
                titles = [m['title'] for m in matches[:10]]
                extra = f"\n...and {len(matches) - 10} more" if len(matches) > 10 else ""
                send_notification(
                    f"Curatorr Rule '{rule['name']}' matched {len(matches)} items:\n"
                    + "\n".join(f"• {t}" for t in titles) + extra
                )
        except Exception as e:
            log.error(f"Error running rule '{rule.get('name', '?')}': {e}")
