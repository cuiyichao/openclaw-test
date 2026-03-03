from datetime import datetime, timezone

from passlib.context import CryptContext

from .config import settings
from .exceptions import InvalidCredentialsError, InvalidTokenError
from .models import LoginResponse
from .token_manager import TokenManager

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
token_manager = TokenManager()


class AuthService:
    """认证服务：处理登录、登出业务逻辑"""

    def login(self, username: str, password: str, db) -> LoginResponse:
        """
        用户登录。

        Args:
            username: 用户名或邮箱
            password: 明文密码
            db: 数据库会话

        Returns:
            LoginResponse: 包含 access_token 和 refresh_token

        Raises:
            InvalidCredentialsError: 用户名或密码错误时抛出
        """
        from database import UserDB  # 延迟导入，避免循环依赖

        # 1. 查询用户
        user_db = db.query(UserDB).filter(UserDB.username == username).first()
        if not user_db:
            raise InvalidCredentialsError("Invalid username or password")

        # 2. 验证密码（恒定时间比较，防止时序攻击）
        if not pwd_context.verify(password, user_db.hashed_password):
            raise InvalidCredentialsError("Invalid username or password")

        # 3. 检查账户状态
        if not user_db.is_active:
            raise InvalidCredentialsError("Account is disabled")

        # 4. 生成 Token 对
        access_token = token_manager.create_access_token(
            user_id=str(user_db.id),
            extra_claims={"roles": user_db.roles or []},
        )
        refresh_token = token_manager.create_refresh_token(user_id=str(user_db.id))

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    def logout(self, token: str) -> None:
        """
        用户登出：吊销当前 Access Token。

        Args:
            token: 请求头中的 Bearer Token

        Raises:
            InvalidTokenError: Token 无效或缺少 jti 声明
        """
        # 1. 解码 Token（即使已过期也要获取 jti）
        payload = token_manager.decode_token(token, verify_exp=False)

        jti = payload.get("jti")
        exp = payload.get("exp")

        if not jti:
            raise InvalidTokenError("Token missing jti claim")

        # 2. 计算剩余有效时间
        now = datetime.now(timezone.utc).timestamp()
        ttl = max(int(exp - now), 0) if exp else 0

        # 3. 加入黑名单
        if ttl > 0:
            token_manager.blacklist.revoke(jti=jti, expire_seconds=ttl)

    def refresh_tokens(self, refresh_token: str) -> LoginResponse:
        """
        使用 Refresh Token 换取新的 Token 对（Refresh Token 轮换）。

        Args:
            refresh_token: 有效的 Refresh Token

        Returns:
            LoginResponse: 新的 Token 对

        Raises:
            TokenExpiredError: Refresh Token 已过期
            InvalidTokenError: Refresh Token 无效
            TokenRevokedError: Refresh Token 已被吊销
        """
        # 1. 验证 Refresh Token
        payload = token_manager.decode_token(refresh_token, expected_type="refresh")

        user_id = payload.get("sub")
        jti = payload.get("jti")
        exp = payload.get("exp")

        if not user_id:
            raise InvalidTokenError("Refresh token missing subject claim")

        # 2. 吊销旧 Refresh Token（防止重放攻击）
        if jti and exp:
            now = datetime.now(timezone.utc).timestamp()
            ttl = max(int(exp - now), 0)
            if ttl > 0:
                token_manager.blacklist.revoke(jti=jti, expire_seconds=ttl)

        # 3. 签发新 Token 对
        new_access_token = token_manager.create_access_token(user_id=user_id)
        new_refresh_token = token_manager.create_refresh_token(user_id=user_id)

        return LoginResponse(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )
