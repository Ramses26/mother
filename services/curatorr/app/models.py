"""Pydantic models for request/response validation."""
from typing import Optional, List, Any
from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class SetupRequest(BaseModel):
    username: str
    password: str


class SyncTriggerRequest(BaseModel):
    source: str = 'all'  # 'all', 'plex', 'radarr', 'sonarr', 'tautulli', 'ratings'


class DeleteRequest(BaseModel):
    confirm: bool = False


class UnmonitorRequest(BaseModel):
    pass


class RuleCondition(BaseModel):
    field: str
    operator: str
    value: Any


class RuleCreate(BaseModel):
    name: str
    enabled: int = 1
    media_type: Optional[str] = None
    condition_logic: str = 'AND'
    conditions: List[RuleCondition] = []
    action: str = 'stage'
    schedule: str = 'manual'
    notify: int = 1


class RuleUpdate(RuleCreate):
    pass


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str
