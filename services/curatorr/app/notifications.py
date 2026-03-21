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
        chat_id = str(CURATORR_TELEGRAM_CHAT).lstrip('-')
        ap.add(f"tgram://{TELEGRAM_BOT_TOKEN}/{chat_id}")
        ap.notify(body=message)
    except Exception as e:
        log.error(f"Telegram notification failed: {e}")
