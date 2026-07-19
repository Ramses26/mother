"""Curatorr Telegram notifications via Apprise."""
import logging
import apprise
from app.config import TELEGRAM_BOT_TOKEN, CURATORR_TELEGRAM_CHAT

log = logging.getLogger('curatorr.notify')


def send_notification(message: str):
    """Send Telegram notification via Apprise."""
    if not TELEGRAM_BOT_TOKEN or not CURATORR_TELEGRAM_CHAT:
        log.debug("Telegram not configured, skipping notification")
        return
    try:
        ap = apprise.Apprise()
        # CURATORR_TELEGRAM_CHAT_ID is a negative group-chat ID (e.g. -5111169388).
        # Stripping the leading '-' here used to turn it into a different, nonexistent
        # chat ID — every Curatorr Telegram notification silently failed with "chat
        # not found" as a result (confirmed 2026-07-19: every single Synology dedup
        # summary for at least a week). Other services (sync-webhook, upgraderr) pass
        # their chat IDs through unmodified — match that pattern.
        ap.add(f"tgram://{TELEGRAM_BOT_TOKEN}/{CURATORR_TELEGRAM_CHAT}")
        ap.notify(body=message)
    except Exception as e:
        log.error(f"Telegram notification failed: {e}")
