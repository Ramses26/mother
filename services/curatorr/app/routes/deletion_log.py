"""Deletion log endpoint."""
from fastapi import APIRouter, Depends, Query
from app.auth import require_auth
from app.database import get_db

router = APIRouter()


@router.get('/deletion-log')
async def get_deletion_log(
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=200),
    _auth=Depends(require_auth),
):
    async for db in get_db():
        async with db.execute("SELECT COUNT(*) FROM deletion_log") as cur:
            total = (await cur.fetchone())[0]
        offset = (page - 1) * per_page
        async with db.execute(
            "SELECT * FROM deletion_log ORDER BY deleted_at DESC LIMIT ? OFFSET ?",
            (per_page, offset)
        ) as cur:
            items = [dict(r) for r in await cur.fetchall()]
        return {
            'items': items,
            'total': total,
            'page': page,
            'per_page': per_page,
            'pages': max(1, (total + per_page - 1) // per_page),
        }
