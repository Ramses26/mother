"""Curatorr rules engine — evaluate conditions and execute actions."""
import json
import logging
from typing import Any
from app.log_events import log_event

log = logging.getLogger('curatorr.rules_engine')

FIELD_MAP_MOVIES = {
    'composite_score': ('composite_score', float),
    'imdb_rating': ('imdb_rating', float),
    'rt_critics': ('rt_critics', int),
    'metacritic': ('metacritic', int),
    'tmdb_rating': ('tmdb_rating', float),
    'mdblist_score': ('mdblist_score', int),
    'purge_score': ('purge_score', int),
    'ali_play_count': ('ali_play_count', int),
    'chris_play_count': ('chris_play_count', int),
    'file_size_gb': ('file_size_bytes', float),  # special: convert
    'resolution': ('resolution', str),
    'year': ('year', int),
    'monitored': ('monitored', int),
    'hdr_format': ('hdr_format', str),
    'audio_codec': ('audio_codec', str),
    'genre': ('genres', str),  # JSON contains check
}

FIELD_MAP_TV = {
    'composite_score': ('composite_score', float),
    'imdb_rating': ('imdb_rating', float),
    'rt_critics': ('rt_critics', int),
    'metacritic': ('metacritic', int),
    'tmdb_rating': ('tmdb_rating', float),
    'mdblist_score': ('mdblist_score', int),
    'purge_score': ('purge_score', int),
    'ali_play_count': ('ali_play_count', int),
    'chris_play_count': ('chris_play_count', int),
    'year': ('year', int),
    'monitored': ('monitored', int),
    'status': ('status', str),
    'season_completion_pct': ('season_completion_pct', float),
}


def _evaluate_condition(item: dict, condition: dict, media_type: str) -> tuple[bool, str]:
    """Evaluate a single condition against an item. Returns (matches, reason)."""
    field = condition.get('field', '')
    operator = condition.get('operator', 'eq')
    value = condition.get('value')

    field_map = FIELD_MAP_MOVIES if media_type == 'movie' else FIELD_MAP_TV
    if field not in field_map:
        return False, f"Unknown field: {field}"

    col_name, col_type = field_map[field]
    item_val = item.get(col_name)

    # Special case: file_size_gb
    if field == 'file_size_gb' and item_val is not None:
        item_val = item_val / 1_073_741_824.0

    # Convert value to expected type
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

    # Evaluate operator
    if operator == 'eq':
        result = item_val == value
    elif operator == 'ne':
        result = item_val != value
    elif operator == 'gt':
        result = item_val > value
    elif operator == 'gte':
        result = item_val >= value
    elif operator == 'lt':
        result = item_val < value
    elif operator == 'lte':
        result = item_val <= value
    elif operator == 'contains':
        result = str(value).lower() in str(item_val).lower()
    elif operator == 'not_contains':
        result = str(value).lower() not in str(item_val).lower()
    elif operator == 'is_null':
        result = item_val is None
    elif operator == 'is_not_null':
        result = item_val is not None
    else:
        result = False

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
            cols = "id, title, year, composite_score, imdb_rating, rt_critics, metacritic, " \
                   "tmdb_rating, mdblist_score, purge_score, ali_play_count, chris_play_count, " \
                   "file_size_bytes, resolution, monitored, hdr_format, audio_codec, genres"
        else:
            cols = "id, title, year, composite_score, imdb_rating, rt_critics, metacritic, " \
                   "tmdb_rating, mdblist_score, purge_score, ali_play_count, chris_play_count, " \
                   "monitored, status, season_completion_pct"

        async with db.execute(f"SELECT {cols} FROM {table} LIMIT 5000") as cur:
            items = await cur.fetchall()

        for row in items:
            item = dict(row)
            item['media_type'] = mt
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
                # Already staged, nothing more to do
                await db.execute(
                    "UPDATE rule_matches SET action_taken='staged', acted_at=CURRENT_TIMESTAMP WHERE id=?",
                    (match['id'],)
                )
            elif action == 'unmonitor':
                media_type = match['media_type']
                media_id = match['media_id']
                if media_type == 'movie':
                    async with db.execute("SELECT radarr_id, radarr_instance FROM movies WHERE id=?", (media_id,)) as cur:
                        row = await cur.fetchone()
                    if row:
                        from app.routes.movies import unmonitor_movie
                        # Direct DB update
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
                # For delete/notify, require separate manual confirmation via UI
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
            # Stage matches — preserve matched_at/action_taken for continuing matches
            new_ids = {m['id'] for m in matches}
            async with db.execute(
                "SELECT media_id FROM rule_matches WHERE rule_id=? AND excluded_by_user=0",
                (rule['id'],)
            ) as _cur:
                existing_ids = {row[0] for row in await _cur.fetchall()}
            # Remove stale matches no longer in result set
            for stale_id in existing_ids - new_ids:
                await db.execute(
                    "DELETE FROM rule_matches WHERE rule_id=? AND media_id=? AND excluded_by_user=0",
                    (rule['id'], stale_id)
                )
            # Insert only new matches (skip already-tracked ones to preserve history)
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
