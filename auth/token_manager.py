import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional

import jwt
import redis

from .config import settings
from .exceptions import (
    InvalidTokenError,
    TokenCreationError,
    TokenExpiredError,
    TokenRevokedError,
)


class TokenBlacklist:
    """基于 Redis 的 Token 黑名单"""

    def __init__(self):
        self.redis_client = redis.Redis(
            host=settings.REDIS_HOST,
            port=settings.REDIS_PORT,
            db=settings.REDIS_DB,
            password=settings.REDIS_PASSWORD,
            decode_responses=True,
        )

    def revoke(self, jti: str, expire_seconds: int) -> None:
        """
        将 Token 加入黑名单。

        Args:
            jti: JWT 的唯一 ID (jti claim)
            expire_seconds: 黑名单条目的过期时间（与 Token 过期时间一致）
        """
        # 使用 jti 作为 key，设置与 token 相同的过期时间，避免内存泄漏
        self.redis_client.setex(
            name=f"blacklist:{jti}",
            time=expire_seconds,
            value="revoked",
        )

    def is_revoked(self, jti: str) -> bool:
        """
        检查 Token 是否已被吊销。

        Args:
            jti: JWT 的唯一 ID

        Returns:
            True 如果 Token 已在黑名单中，否则 False
        """
        return self.redis_client.exists(f"blacklist:{jti}") > 0


class TokenManager:
    """JWT Token 管理器"""

    def __init__(self):
        self.blacklist = TokenBlacklist()

    def create_access_token(
        self,
        user_id: str,
        extra_claims: Optional[dict] = None,
    ) -> str:
        """
        生成 Access Token。

        Args:
            user_id: 用户唯一标识符
            extra_claims: 附加到 payload 的额外声明

        Returns:
            已签名的 JWT 字符串

        Raises:
            TokenCreationError: Token 生成失败时抛出
        """
        now = datetime.now(timezone.utc)
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

        payload = {
            "sub": str(user_id),       # Subject: 用户 ID
            "iat": now,                 # Issued At: 签发时间
            "exp": expire,             # Expiration: 过期时间
            "jti": str(uuid.uuid4()), # JWT ID: 唯一标识，用于黑名单
            "type": "access",
        }

        if extra_claims:
            payload.update(extra_claims)

        try:
            return jwt.encode(
                payload,
                settings.SECRET_KEY,
                algorithm=settings.ALGORITHM,
            )
        except Exception as e:
            raise TokenCreationError(f"Failed to create access token: {e}") from e

    def create_refresh_token(self, user_id: str) -> str:
        """
        生成 Refresh Token。

        Args:
            user_id: 用户唯一标识符

        Returns:
            已签名的 Refresh Token 字符串

        Raises:
            TokenCreationError: Token 生成失败时抛出
        """
        now = datetime.now(timezone.utc)
        expire = now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

        payload = {
            "sub": str(user_id),
            "iat": now,
            "exp": expire,
            "jti": str(uuid.uuid4()),
            "type": "refresh",
        }

        try:
            return jwt.encode(
                payload,
                settings.SECRET_KEY,
                algorithm=settings.ALGORITHM,
            )
        except Exception as e:
            raise TokenCreationError(f"Failed to create refresh token: {e}") from e

    def decode_token(
        self,
        token: str,
        expected_type: str = "access",
        verify_exp: bool = True,
    ) -> dict:
        """
        解码并验证 JWT Token。

        Args:
            token: JWT 字符串
            expected_type: 期望的 Token 类型 ("access" 或 "refresh")
            verify_exp: 是否验证过期时间，登出时设为 False

        Returns:
            解码后的 payload 字典

        Raises:
            TokenExpiredError: Token 已过期
            InvalidTokenError: Token 签名无效或格式错误
            TokenRevokedError: Token 已被吊销（在黑名单中）
        """
        try:
            options = {"verify_exp": verify_exp}
            payload = jwt.decode(
                token,
                settings.SECRET_KEY,
                algorithms=[settings.ALGORITHM],
                options=options,
            )
        except jwt.ExpiredSignatureError:
            raise TokenExpiredError("Token has expired")
        except jwt.InvalidTokenError as e:
            raise InvalidTokenError(f"Invalid token: {e}") from e

        # 验证 Token 类型
        if payload.get("type") != expected_type:
            raise InvalidTokenError(
                f"Expected '{expected_type}' token, got '{payload.get('type')}'"
            )

        # 检查黑名单
        jti = payload.get("jti")
        if jti and self.blacklist.is_revoked(jti):
            raise TokenRevokedError("Token has been revoked")

        return payload

    def get_current_user_id(self, token: str) -> str:
        """
        从 Token 中提取当前用户 ID。

        Args:
            token: Bearer Token 字符串（不含 "Bearer " 前缀）

        Returns:
            用户 ID 字符串

        Raises:
            InvalidTokenError: Token 缺少 sub 声明
        """
        payload = self.decode_token(token, expected_type="access")
        user_id = payload.get("sub")
        if not user_id:
            raise InvalidTokenError("Token missing subject claim")
        return user_id
