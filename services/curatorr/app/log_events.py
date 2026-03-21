"""Standalone event log helper — no FastAPI imports to avoid circular deps."""
import json
import logging

log = logging.getLogger('curatorr.log_events')


async def log_event(db, event_type: str, source: str, message: str,
                    detail=None, level: str = 'info'):
    """Insert an event log entry. Call from sync/action code."""
    try:
        detail_str = json.dumps(detail) if detail is not None and not isinstance(detail, str) else detail
        await db.execute(
            "INSERT INTO event_log (event_type, source, message, detail, level) VALUES (?,?,?,?,?)",
            (event_type, source, message, detail_str, level)
        )
        # Auto-purge: keep last 2000 rows
        await db.execute(
            "DELETE FROM event_log WHERE id NOT IN "
            "(SELECT id FROM event_log ORDER BY id DESC LIMIT 2000)"
        )
    except Exception as e:
        log.debug(f"log_event failed (non-fatal): {e}")
