"""Curatorr — FastAPI main application."""
import os
import logging
import asyncio
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Request, Response, HTTPException, Depends
from fastapi.responses import JSONResponse, FileResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from app.config import VERSION, DB_PATH
from app.database import init_database, get_db, get_movie_count, get_tv_count
from app.auth import (
    require_auth, check_login_rate, verify_login,
    make_access_token, make_refresh_token,
    is_setup_required, set_config, hash_password,
    JWT_ACCESS_TTL, JWT_REFRESH_TTL,
)
from app.models import LoginRequest, SetupRequest

log = logging.getLogger('curatorr')
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
)

# Persistent log file (survives container restarts)
try:
    from logging.handlers import RotatingFileHandler as _RFH
    _log_dir = Path('/logs')
    _log_dir.mkdir(parents=True, exist_ok=True)
    _fh = _RFH(_log_dir / 'curatorr.log', maxBytes=20 * 1024 * 1024, backupCount=10)
    _fh.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s'))
    logging.getLogger().addHandler(_fh)
except Exception as _e:
    log.warning(f'Could not set up file logging: {_e}')

STATIC_DIR = Path(__file__).parent / 'static'


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup / shutdown."""
    await init_database()
    log.info("Database ready")

    # Import scheduler here to avoid circular imports
    try:
        from app.scheduler import start_scheduler, trigger_initial_sync
        start_scheduler()
        # Trigger initial sync if DB is empty (use scheduler thread to avoid DB contention)
        movie_count = await get_movie_count()
        tv_count = await get_tv_count()
        if movie_count == 0 and tv_count == 0:
            log.info("Database empty — scheduling immediate initial sync")
            import threading
            def _initial_sync_thread():
                import asyncio as _asyncio
                loop = _asyncio.new_event_loop()
                try:
                    loop.run_until_complete(trigger_initial_sync())
                finally:
                    loop.close()
            t = threading.Thread(target=_initial_sync_thread, daemon=True)
            t.start()
    except Exception as e:
        log.error(f"Scheduler startup error: {e}")

    yield

    # Shutdown
    try:
        from app.scheduler import stop_scheduler
        stop_scheduler()
    except Exception:
        pass


app = FastAPI(title='Curatorr', version=VERSION, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=['http://mother:9707', 'http://localhost:9707', 'http://10.0.0.162:9707'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


# ── Health ────────────────────────────────────────────────────────────────────

@app.get('/health')
async def health():
    db_status = 'ok'
    movies = 0
    tv_shows = 0
    try:
        movies = await get_movie_count()
        tv_shows = await get_tv_count()
    except Exception as e:
        db_status = f'error: {e}'
    return {
        'status': 'healthy',
        'version': VERSION,
        'db': db_status,
        'synced': {'movies': movies, 'tv_shows': tv_shows},
    }


# ── Auth ──────────────────────────────────────────────────────────────────────

@app.post('/api/login')
async def login(request: Request, body: LoginRequest):
    ip = request.client.host if request.client else '0.0.0.0'
    if not check_login_rate(ip):
        raise HTTPException(status_code=429, detail='Too many login attempts')

    setup_required = await is_setup_required()
    if setup_required:
        raise HTTPException(status_code=403, detail='Setup required')

    if not await verify_login(body.username, body.password):
        raise HTTPException(status_code=401, detail='Invalid username or password')

    access_token = make_access_token()
    refresh_token = make_refresh_token()

    resp = JSONResponse({'ok': True, 'message': 'Logged in'})
    resp.set_cookie('access_token', access_token, httponly=True,
                    samesite='Lax', max_age=JWT_ACCESS_TTL)
    resp.set_cookie('refresh_token', refresh_token, httponly=True,
                    samesite='Lax', max_age=JWT_REFRESH_TTL)
    return resp


@app.post('/api/logout')
async def logout():
    resp = JSONResponse({'ok': True})
    resp.delete_cookie('access_token')
    resp.delete_cookie('refresh_token')
    return resp


@app.post('/api/refresh')
async def refresh(request: Request):
    refresh_tok = request.cookies.get('refresh_token')
    if not refresh_tok:
        raise HTTPException(status_code=401, detail='No refresh token')
    from app.auth import verify_token
    payload = verify_token(refresh_tok, 'refresh')
    if not payload:
        raise HTTPException(status_code=401, detail='Invalid refresh token')
    new_token = make_access_token()
    resp = JSONResponse({'ok': True})
    resp.set_cookie('access_token', new_token, httponly=True,
                    samesite='Lax', max_age=JWT_ACCESS_TTL)
    return resp


@app.get('/api/auth/status')
async def auth_status(request: Request):
    """Check if authenticated and setup state."""
    setup_required = await is_setup_required()
    if setup_required:
        return {'authenticated': False, 'setup_required': True}

    from app.auth import get_token_from_request, verify_token
    token = get_token_from_request(request)
    if token and verify_token(token, 'access'):
        return {'authenticated': True, 'setup_required': False}

    refresh = request.cookies.get('refresh_token')
    if refresh and verify_token(refresh, 'refresh'):
        return {'authenticated': True, 'setup_required': False}

    return {'authenticated': False, 'setup_required': False}


# ── First-run setup ───────────────────────────────────────────────────────────

@app.post('/api/setup')
async def setup(body: SetupRequest):
    """First-run: set admin username + password. Only works if not yet configured."""
    if not await is_setup_required():
        raise HTTPException(status_code=403, detail='Setup already complete')
    if not body.username or len(body.username.strip()) < 2:
        raise HTTPException(status_code=400, detail='Username must be at least 2 characters')
    if len(body.password) < 8:
        raise HTTPException(status_code=400, detail='Password must be at least 8 characters')
    hashed = hash_password(body.password)
    await set_config('admin_username', body.username.strip().lower())
    await set_config('admin_password_hash', hashed)
    log.info(f"Admin credentials set via /api/setup (username: {body.username.strip().lower()})")

    access_token = make_access_token()
    refresh_token = make_refresh_token()
    resp = JSONResponse({'ok': True, 'message': 'Setup complete'})
    resp.set_cookie('access_token', access_token, httponly=True,
                    samesite='Lax', max_age=JWT_ACCESS_TTL)
    resp.set_cookie('refresh_token', refresh_token, httponly=True,
                    samesite='Lax', max_age=JWT_REFRESH_TTL)
    return resp


# ── Poster proxy ──────────────────────────────────────────────────────────────

@app.get('/api/poster')
async def poster_proxy(url: str, server: str = 'chris', _auth=Depends(require_auth)):
    """Proxy Plex poster images to avoid CORS/token exposure."""
    import httpx
    from app.config import CHRIS_PLEX_URL, CHRIS_PLEX_TOKEN, ALI_PLEX_URL, ALI_PLEX_TOKEN
    if server == 'ali':
        base_url = ALI_PLEX_URL
        token = ALI_PLEX_TOKEN
    else:
        base_url = CHRIS_PLEX_URL
        token = CHRIS_PLEX_TOKEN

    # Build full URL with token
    if url.startswith('/'):
        full_url = f"{base_url}/photo/:/transcode?url={url}&width=300&height=450&X-Plex-Token={token}"
    else:
        full_url = url

    try:
        async with httpx.AsyncClient(timeout=10, limits=httpx.Limits(max_response_size=5_242_880)) as client:
            r = await client.get(full_url)
            r.raise_for_status()
            content_type = r.headers.get('content-type', 'image/jpeg')
            if not any(t in content_type for t in ('image/jpeg', 'image/png', 'image/webp', 'image/gif')):
                raise HTTPException(status_code=400, detail='Invalid image type')
            return Response(content=r.content, media_type=content_type)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=404, detail='Poster not found')


# ── Import route modules ──────────────────────────────────────────────────────
from app.routes import sync, movies, tv, stats, collections, duplicates, rules, deletion_log, settings, actions, logs

app.include_router(sync.router, prefix='/api')
app.include_router(movies.router, prefix='/api')
app.include_router(tv.router, prefix='/api')
app.include_router(stats.router, prefix='/api')
app.include_router(collections.router, prefix='/api')
app.include_router(duplicates.router, prefix='/api')
app.include_router(rules.router, prefix='/api')
app.include_router(deletion_log.router, prefix='/api')
app.include_router(settings.router, prefix='/api')
app.include_router(actions.router, prefix='/api')
app.include_router(logs.router, prefix='/api')


# ── SPA catch-all ─────────────────────────────────────────────────────────────
# Mount static AFTER routes so API routes take priority

if STATIC_DIR.exists():
    # Mount /assets for hashed Vite assets
    assets_dir = STATIC_DIR / 'assets'
    if assets_dir.exists():
        app.mount('/assets', StaticFiles(directory=str(assets_dir)), name='assets')

    @app.get('/favicon.svg')
    async def favicon():
        f = STATIC_DIR / 'favicon.svg'
        if f.exists():
            return FileResponse(str(f), media_type='image/svg+xml')
        raise HTTPException(status_code=404)

    @app.get('/{full_path:path}')
    async def spa_catch_all(full_path: str):
        """Serve index.html for all non-API routes (Vue SPA routing)."""
        index = STATIC_DIR / 'index.html'
        if index.exists():
            return FileResponse(str(index))
        return JSONResponse({'error': 'Frontend not built'}, status_code=503)
