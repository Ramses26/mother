"""Rules CRUD + run + preview + execute + staged matches."""
import json
import logging
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth
from app.database import get_db
from app.models import RuleCreate, RuleUpdate

router = APIRouter()
log = logging.getLogger('curatorr.routes.rules')


@router.get('/rules')
async def list_rules(_auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT * FROM rules ORDER BY created_at DESC") as cur:
            return [dict(r) for r in await cur.fetchall()]


@router.post('/rules')
async def create_rule(body: RuleCreate, _auth=Depends(require_auth)):
    conditions_json = json.dumps([c.model_dump() for c in body.conditions])
    async for db in get_db():
        cur = await db.execute("""
            INSERT INTO rules (name, enabled, media_type, condition_logic, conditions, action, schedule, notify)
            VALUES (?,?,?,?,?,?,?,?)
        """, (body.name, body.enabled, body.media_type, body.condition_logic,
              conditions_json, body.action, body.schedule, body.notify))
        rule_id = cur.lastrowid
        await db.commit()
        async with db.execute("SELECT * FROM rules WHERE id=?", (rule_id,)) as cur2:
            row = await cur2.fetchone()
        return dict(row)


@router.put('/rules/{rule_id}')
async def update_rule(rule_id: int, body: RuleUpdate, _auth=Depends(require_auth)):
    conditions_json = json.dumps([c.model_dump() for c in body.conditions])
    async for db in get_db():
        await db.execute("""
            UPDATE rules SET name=?, enabled=?, media_type=?, condition_logic=?,
            conditions=?, action=?, schedule=?, notify=?
            WHERE id=?
        """, (body.name, body.enabled, body.media_type, body.condition_logic,
              conditions_json, body.action, body.schedule, body.notify, rule_id))
        await db.commit()
        async with db.execute("SELECT * FROM rules WHERE id=?", (rule_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Rule not found')
        return dict(row)


@router.delete('/rules/{rule_id}')
async def delete_rule(rule_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        await db.execute("DELETE FROM rule_matches WHERE rule_id=?", (rule_id,))
        await db.execute("DELETE FROM rules WHERE id=?", (rule_id,))
        await db.commit()
    return {'ok': True}


@router.post('/rules/{rule_id}/preview')
async def preview_rule(rule_id: int, _auth=Depends(require_auth)):
    """Dry run — returns match count + items."""
    from app.rules_engine import evaluate_rule
    async for db in get_db():
        async with db.execute("SELECT * FROM rules WHERE id=?", (rule_id,)) as cur:
            rule = await cur.fetchone()
        if not rule:
            raise HTTPException(status_code=404, detail='Rule not found')
        matches = await evaluate_rule(dict(rule), db, dry_run=True)
    return {'count': len(matches), 'items': matches[:50]}


@router.post('/rules/{rule_id}/run')
async def run_rule(rule_id: int, _auth=Depends(require_auth)):
    """Stage matches (no action taken yet)."""
    from app.rules_engine import evaluate_rule
    async for db in get_db():
        async with db.execute("SELECT * FROM rules WHERE id=?", (rule_id,)) as cur:
            rule = await cur.fetchone()
        if not rule:
            raise HTTPException(status_code=404, detail='Rule not found')
        matches = await evaluate_rule(dict(rule), db, dry_run=False)

        # Clear old non-excluded matches
        await db.execute(
            "DELETE FROM rule_matches WHERE rule_id=? AND excluded_by_user=0",
            (rule_id,)
        )
        # Insert new
        for m in matches:
            await db.execute("""
                INSERT OR IGNORE INTO rule_matches
                (rule_id, media_type, media_id, title, match_reason)
                VALUES (?,?,?,?,?)
            """, (rule_id, m['media_type'], m['id'], m['title'], json.dumps(m.get('reasons', []))))

        await db.execute(
            "UPDATE rules SET last_run=CURRENT_TIMESTAMP, last_match_count=? WHERE id=?",
            (len(matches), rule_id)
        )
        await db.commit()

    return {'count': len(matches), 'items': matches[:50]}


@router.get('/rules/{rule_id}/matches')
async def get_rule_matches(rule_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute(
            "SELECT * FROM rule_matches WHERE rule_id=? ORDER BY matched_at DESC",
            (rule_id,)
        ) as cur:
            return [dict(r) for r in await cur.fetchall()]


@router.post('/rules/{rule_id}/matches/{match_id}/exclude')
async def exclude_match(rule_id: int, match_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        await db.execute(
            "UPDATE rule_matches SET excluded_by_user=1 WHERE id=? AND rule_id=?",
            (match_id, rule_id)
        )
        await db.commit()
    return {'ok': True}


@router.post('/rules/{rule_id}/execute')
async def execute_rule(rule_id: int, _auth=Depends(require_auth)):
    """Execute action on all non-excluded staged matches."""
    from app.rules_engine import execute_rule_matches
    async for db in get_db():
        async with db.execute("SELECT * FROM rules WHERE id=?", (rule_id,)) as cur:
            rule = await cur.fetchone()
        if not rule:
            raise HTTPException(status_code=404, detail='Rule not found')
        result = await execute_rule_matches(dict(rule), db)
    return result
