"""Curatorr auth — JWT dual-token, bcrypt, rate limiting."""
import time
import logging
import threading
from datetime import datetime, timedelta
from typing import Optional

import bcrypt
from jose import jwt, JWTError
from fastapi import Request, HTTPException, Depends
from fastapi.responses import JSONResponse

from app.config import SECRET_KEY, JWT_ACCESS_TTL, JWT_REFRESH_TTL, ADMIN_PASSWORD
from app.database import get_config, set_config

log = logging.getLogger('curatorr.auth')

ALGORITHM = 'HS256'

# ── Password helpers ──────────────────────────────────────────────────────────

def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()


def check_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode(), hashed.encode())
    except Exception:
        return False


# ── JWT helpers ───────────────────────────────────────────────────────────────

def make_access_token() -> str:
    return jwt.encode({
        'sub': 'admin', 'type': 'access',
        'exp': datetime.utcnow() + timedelta(seconds=JWT_ACCESS_TTL),
        'iat': datetime.utcnow(),
    }, SECRET_KEY, algorithm=ALGORITHM)


def make_refresh_token() -> str:
    return jwt.encode({
        'sub': 'admin', 'type': 'refresh',
        'exp': datetime.utcnow() + timedelta(seconds=JWT_REFRESH_TTL),
        'iat': datetime.utcnow(),
    }, SECRET_KEY, algorithm=ALGORITHM)


def verify_token(token: str, token_type: str = 'access') -> Optional[dict]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        if payload.get('type') == token_type:
            return payload
    except JWTError:
        pass
    return None


def get_token_from_request(request: Request) -> Optional[str]:
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return auth[7:]
    return request.cookies.get('access_token')


# ── Rate limiter ──────────────────────────────────────────────────────────────

_login_attempts: dict[str, list] = {}
_login_lock = threading.Lock()


def check_login_rate(ip: str) -> bool:
    with _login_lock:
        now = time.time()
        attempts = [t for t in _login_attempts.get(ip, []) if now - t < 60]
        if len(attempts) >= 5:
            return False
        attempts.append(now)
        _login_attempts[ip] = attempts
        return True


# ── Password config ───────────────────────────────────────────────────────────

async def get_password_hash() -> Optional[str]:
    """Return stored hash: env password has priority, then DB config."""
    if ADMIN_PASSWORD:
        return hash_password(ADMIN_PASSWORD)
    return await get_config('admin_password_hash')


async def is_setup_required() -> bool:
    """True if no password is configured anywhere."""
    if ADMIN_PASSWORD:
        return False
    h = await get_config('admin_password_hash')
    return not h


async def verify_login(password: str) -> bool:
    """Verify a login attempt against configured password."""
    if ADMIN_PASSWORD:
        return password == ADMIN_PASSWORD
    h = await get_config('admin_password_hash')
    if not h:
        return False
    return check_password(password, h)


# ── FastAPI dependency ────────────────────────────────────────────────────────

async def require_auth(request: Request):
    """FastAPI dependency — raises 401 if not authenticated."""
    token = get_token_from_request(request)
    if token:
        payload = verify_token(token, 'access')
        if payload:
            return payload

    refresh = request.cookies.get('refresh_token')
    if refresh:
        payload = verify_token(refresh, 'refresh')
        if payload:
            # Will attach new cookie in route handler
            request.state.needs_refresh = True
            return payload

    raise HTTPException(status_code=401, detail='Unauthorized')
