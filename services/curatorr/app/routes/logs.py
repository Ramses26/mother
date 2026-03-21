"""Event log API."""
import logging
from fastapi import APIRouter, Depends, Query
from app.auth import require_auth
from app.database import get_db
from app.log_events import log_event  # re-export for backwards compat

router = APIRouter()
log = logging.getLogger('curatorr.routes.logs')

__all__ = ['router', 'log_event']


@router.get('/logs')
async def get_logs(
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=200),
    event_type: str = Query('', alias='type'),
    level: str = Query(''),
    source: str = Query(''),
    _auth=Depends(require_auth),
):
    """Return paginated event log entries."""
    offset = (page - 1) * per_page
    where_clauses = []
    args = []

    if event_type:
        where_clauses.append("event_type = ?")
        args.append(event_type)
    if level:
        where_clauses.append("level = ?")
        args.append(level)
    if source:
        where_clauses.append("source LIKE ?")
        args.append(f'%{source}%')

    where = ("WHERE " + " AND ".join(where_clauses)) if where_clauses else ""

    async for db in get_db():
        async with db.execute(
            f"SELECT COUNT(*) FROM event_log {where}", args
        ) as cur:
            total = (await cur.fetchone())[0]

        async with db.execute(
            f"SELECT * FROM event_log {where} ORDER BY id DESC LIMIT ? OFFSET ?",
            args + [per_page, offset]
        ) as cur:
            rows = [dict(r) for r in await cur.fetchall()]

        return {
            'items': rows,
            'total': total,
            'page': page,
            'pages': max(1, (total + per_page - 1) // per_page),
        }


