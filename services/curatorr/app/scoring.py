"""Curatorr scoring — composite ratings and purge score."""
from typing import Optional


def compute_composite_score(
    imdb: Optional[float] = None,
    rt_critics: Optional[int] = None,
    metacritic: Optional[int] = None,
    tmdb: Optional[float] = None,
    mdblist: Optional[int] = None,
) -> Optional[float]:
    """Weighted average of available rating sources. Returns 0-10 float."""
    weights = {
        'imdb': 0.35,
        'rt': 0.25,
        'mdblist': 0.20,
        'metacritic': 0.15,
        'tmdb': 0.05,
    }
    values = {}
    if imdb is not None and imdb > 0:
        values['imdb'] = float(imdb)
    if rt_critics is not None and rt_critics > 0:
        values['rt'] = rt_critics / 10.0
    if metacritic is not None and metacritic > 0:
        values['metacritic'] = metacritic / 10.0
    if tmdb is not None and tmdb > 0:
        values['tmdb'] = float(tmdb)
    if mdblist is not None and mdblist > 0:
        values['mdblist'] = mdblist / 10.0

    if not values:
        return None

    total_w = sum(weights[k] for k in values)
    score = sum(values[k] * weights[k] for k in values) / total_w
    return round(score, 2)


def compute_purge_score(item: dict) -> int:
    """Returns 0-100. Higher = stronger purge candidate."""
    score = 0
    composite = item.get('composite_score') or 0

    if composite > 0:
        score += max(0, (5.0 - composite) * 10)  # up to +50 for score=0

    ali_plays = item.get('ali_play_count', 0) or 0
    chris_plays = item.get('chris_play_count', 0) or 0
    total_plays = ali_plays + chris_plays

    if ali_plays == 0 and chris_plays == 0:
        score += 20
    elif total_plays <= 1:
        score += 10

    res = (item.get('resolution') or '').upper()
    if res in ('720P', 'SD', '480P'):
        score += 15

    tv_status = item.get('status') or item.get('tv_status') or ''
    if tv_status == 'Cancelled' and ali_plays > 0 and chris_plays > 0:
        score += 10

    # Protect high-rated content
    if composite >= 8.5:
        score -= 20

    return max(0, min(100, int(score)))


def purge_score_color(score: int) -> str:
    """Returns tailwind color class based on purge score."""
    if score < 30:
        return 'green-500'
    elif score < 55:
        return 'yellow-500'
    elif score < 75:
        return 'orange-500'
    else:
        return 'red-500'
