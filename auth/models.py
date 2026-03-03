from dataclasses import dataclass, field
from typing import Optional
from datetime import datetime


@dataclass
class TokenPayload:
    """JWT Payload 数据模型"""
    sub: str                    # Subject: 用户 ID
    iat: datetime               # Issued At: 签发时间
    exp: datetime               # Expiration: 过期时间
    jti: str                    # JWT ID: 唯一标识
    type: str                   # Token 类型: "access" | "refresh"
    roles: list[str] = field(default_factory=list)


@dataclass
class LoginResponse:
    """登录响应数据模型"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 1800      # 单位：秒


@dataclass
class User:
    """用户数据模型（与数据库实体对应）"""
    id: str
    username: str
    email: str
    hashed_password: str
    roles: list[str]
    is_active: bool = True
    created_at: Optional[datetime] = None
