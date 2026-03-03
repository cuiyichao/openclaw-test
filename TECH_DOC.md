# Python JWT 用户认证模块技术文档

**版本**: 1.0.0
**日期**: 2026-03-03
**作者**: 技术团队

---

## 目录

1. [概述](#概述)
2. [依赖与安装](#依赖与安装)
3. [模块架构](#模块架构)
4. [核心功能](#核心功能)
   - [登录 (Login)](#登录-login)
   - [登出 (Logout)](#登出-logout)
   - [Token 验证 (Token Verification)](#token-验证-token-verification)
5. [数据模型](#数据模型)
6. [错误处理](#错误处理)
7. [安全考量](#安全考量)
8. [完整示例](#完整示例)
9. [API 参考](#api-参考)

---

## 概述

本模块基于 **JSON Web Token (JWT)** 标准实现无状态用户认证，适用于 RESTful API 服务。JWT 由三部分组成：Header（头部）、Payload（载荷）、Signature（签名），通过点号（`.`）连接，格式为：

```
xxxxx.yyyyy.zzzzz
```

### 认证流程

```
客户端                          服务端
  │                               │
  │  POST /auth/login             │
  │  {username, password}  ────►  │
  │                               │  验证凭据
  │                               │  生成 Access Token + Refresh Token
  │  ◄────  {access_token,        │
  │           refresh_token}      │
  │                               │
  │  GET /api/resource            │
  │  Authorization: Bearer <tok>  │
  │  ─────────────────────────►   │
  │                               │  验证 Token 签名 & 过期时间
  │  ◄────  {data}                │
  │                               │
  │  POST /auth/logout            │
  │  Authorization: Bearer <tok>  │
  │  ─────────────────────────►   │
  │                               │  将 Token 加入黑名单
  │  ◄────  {message: "OK"}       │
  │                               │
```

---

## 依赖与安装

### 依赖包

| 包名 | 版本 | 用途 |
|------|------|------|
| `PyJWT` | >= 2.8.0 | JWT 编码/解码 |
| `cryptography` | >= 41.0.0 | RS256 算法支持 |
| `redis` | >= 5.0.0 | Token 黑名单存储 |
| `passlib[bcrypt]` | >= 1.7.4 | 密码哈希 |
| `python-dotenv` | >= 1.0.0 | 环境变量管理 |

### 安装

```bash
pip install PyJWT cryptography redis passlib[bcrypt] python-dotenv
```

### 环境变量配置

创建 `.env` 文件：

```env
# JWT 配置
JWT_SECRET_KEY=your-256-bit-secret-key-here
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# Redis 配置（用于 Token 黑名单）
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=

# 应用配置
APP_ENV=production
```

---

## 模块架构

```
auth/
├── __init__.py
├── config.py          # 配置加载
├── models.py          # 数据模型 (User, TokenPayload)
├── token_manager.py   # Token 生成、验证、吊销
├── auth_service.py    # 登录、登出业务逻辑
├── dependencies.py    # FastAPI 依赖注入（可选）
└── exceptions.py      # 自定义异常
```

---

## 核心功能

### 登录 (Login)

#### 功能描述

验证用户凭据，成功后签发 Access Token 和 Refresh Token。

- **Access Token**: 短期有效（默认 30 分钟），用于 API 请求认证
- **Refresh Token**: 长期有效（默认 7 天），用于无感刷新 Access Token

#### 实现代码

```python
# auth/token_manager.py
import jwt
import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional
from .config import settings
from .exceptions import TokenCreationError


class TokenManager:
    """JWT Token 管理器"""

    def create_access_token(
        self,
        user_id: str,
        extra_claims: Optional[dict] = None
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
            "sub": str(user_id),        # Subject: 用户 ID
            "iat": now,                  # Issued At: 签发时间
            "exp": expire,               # Expiration: 过期时间
            "jti": str(uuid.uuid4()),   # JWT ID: 唯一标识，用于黑名单
            "type": "access",
        }

        if extra_claims:
            payload.update(extra_claims)

        try:
            return jwt.encode(
                payload,
                settings.SECRET_KEY,
                algorithm=settings.ALGORITHM
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

        return jwt.encode(
            payload,
            settings.SECRET_KEY,
            algorithm=settings.ALGORITHM
        )
```

```python
# auth/auth_service.py
from passlib.context import CryptContext
from .token_manager import TokenManager
from .models import User, LoginResponse, TokenPair
from .exceptions import InvalidCredentialsError

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
        # 1. 查询用户
        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise InvalidCredentialsError("Invalid username or password")

        # 2. 验证密码（恒定时间比较，防止时序攻击）
        if not pwd_context.verify(password, user.hashed_password):
            raise InvalidCredentialsError("Invalid username or password")

        # 3. 检查账户状态
        if not user.is_active:
            raise InvalidCredentialsError("Account is disabled")

        # 4. 生成 Token 对
        access_token = token_manager.create_access_token(
            user_id=str(user.id),
            extra_claims={"roles": user.roles}
        )
        refresh_token = token_manager.create_refresh_token(user_id=str(user.id))

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )
```

#### 请求/响应示例

**请求**
```http
POST /auth/login
Content-Type: application/json

{
  "username": "alice",
  "password": "S3cur3P@ssw0rd"
}
```

**响应 (200 OK)**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 1800
}
```

**响应 (401 Unauthorized)**
```json
{
  "detail": "Invalid username or password"
}
```

---

### 登出 (Logout)

#### 功能描述

将当前 Token 加入 Redis 黑名单，使其在过期前立即失效。无状态 JWT 本身无法主动吊销，黑名单机制是实现登出的标准方案。

#### 实现代码

```python
# auth/token_manager.py（续）
import redis
from .config import settings


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
            value="revoked"
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
```

```python
# auth/auth_service.py（续）
from datetime import datetime, timezone

blacklist = TokenBlacklist()


class AuthService:
    def logout(self, token: str) -> None:
        """
        用户登出：吊销当前 Access Token。

        Args:
            token: 请求头中的 Bearer Token

        Raises:
            InvalidTokenError: Token 无效或已过期
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
            blacklist.revoke(jti=jti, expire_seconds=ttl)
```

#### 请求/响应示例

**请求**
```http
POST /auth/logout
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**响应 (200 OK)**
```json
{
  "message": "Successfully logged out"
}
```

---

### Token 验证 (Token Verification)

#### 功能描述

验证 Token 的合法性，包含以下检查项：

| 检查项 | 说明 |
|--------|------|
| 签名验证 | 确认 Token 未被篡改 |
| 过期时间 | 确认 Token 在有效期内 (`exp`) |
| 签发时间 | 防止时钟偏差导致的问题 (`iat`) |
| 黑名单检查 | 确认 Token 未被主动吊销 |
| Token 类型 | 区分 access/refresh token，防止滥用 |

#### 实现代码

```python
# auth/token_manager.py（续）
from .exceptions import (
    TokenExpiredError,
    InvalidTokenError,
    TokenRevokedError,
)


class TokenManager:
    def __init__(self):
        self.blacklist = TokenBlacklist()

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
        """
        payload = self.decode_token(token, expected_type="access")
        user_id = payload.get("sub")
        if not user_id:
            raise InvalidTokenError("Token missing subject claim")
        return user_id
```

```python
# auth/dependencies.py（FastAPI 依赖注入示例）
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from .token_manager import TokenManager
from .exceptions import TokenExpiredError, InvalidTokenError, TokenRevokedError

security = HTTPBearer()
token_manager = TokenManager()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db=Depends(get_db),
):
    """
    FastAPI 路由依赖：验证 Token 并返回当前用户。

    Usage:
        @app.get("/api/me")
        def get_me(user = Depends(get_current_user)):
            return user
    """
    token = credentials.credentials

    try:
        user_id = token_manager.get_current_user_id(token)
    except TokenExpiredError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except TokenRevokedError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = db.query(User).filter(User.id == user_id).first()
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    return user
```

---

## 数据模型

```python
# auth/models.py
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
```

---

## 错误处理

### 自定义异常

```python
# auth/exceptions.py

class AuthError(Exception):
    """认证模块基础异常"""
    pass

class InvalidCredentialsError(AuthError):
    """用户名或密码错误"""
    http_status = 401

class TokenExpiredError(AuthError):
    """Token 已过期"""
    http_status = 401

class InvalidTokenError(AuthError):
    """Token 无效（格式错误、签名不匹配等）"""
    http_status = 401

class TokenRevokedError(AuthError):
    """Token 已被吊销"""
    http_status = 401

class TokenCreationError(AuthError):
    """Token 创建失败"""
    http_status = 500
```

### HTTP 错误码对照

| HTTP 状态码 | 场景 |
|-------------|------|
| `200 OK` | 操作成功 |
| `401 Unauthorized` | 凭据无效、Token 过期/吊销/无效 |
| `403 Forbidden` | 权限不足（Token 有效但无权访问资源） |
| `422 Unprocessable Entity` | 请求体格式错误 |
| `500 Internal Server Error` | Token 生成失败等内部错误 |

---

## 安全考量

### 1. 密钥管理
- **绝对不要**将 `JWT_SECRET_KEY` 硬编码在代码中
- 生产环境密钥长度至少 **256 位**（32 字节），使用密码学安全随机数生成：
  ```bash
  python -c "import secrets; print(secrets.token_hex(32))"
  ```
- 考虑使用 **RS256**（非对称加密）替代 HS256，私钥签发、公钥验证

### 2. 过期时间设置
| Token 类型 | 推荐有效期 | 理由 |
|------------|-----------|------|
| Access Token | 15 ~ 30 分钟 | 短期，降低泄露风险 |
| Refresh Token | 7 ~ 30 天 | 长期，需配合 Refresh Token 轮换机制 |

### 3. 传输安全
- 所有接口**必须**通过 HTTPS 传输
- 不得将 Token 存储在 `localStorage`（XSS 风险），推荐使用 `httpOnly` Cookie

### 4. 防止常见攻击
| 攻击类型 | 防护措施 |
|----------|----------|
| 暴力破解 | 登录接口限速（Rate Limiting） |
| 时序攻击 | 使用 `passlib` 的恒定时间密码比较 |
| Token 重放 | Redis 黑名单 + `jti` 唯一标识 |
| 算法混淆 | 解码时显式指定 `algorithms` 参数，拒绝 `none` 算法 |

### 5. Refresh Token 轮换

每次使用 Refresh Token 时，应签发新的 Refresh Token 并吊销旧的，防止 Token 泄露后被长期滥用。

---

## 完整示例

以下展示基于 FastAPI 的完整集成示例：

```python
# main.py
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel
from auth.auth_service import AuthService
from auth.dependencies import get_current_user
from auth.exceptions import InvalidCredentialsError

app = FastAPI(title="JWT Auth Demo")
auth_service = AuthService()


class LoginRequest(BaseModel):
    username: str
    password: str


@app.post("/auth/login")
def login(request: LoginRequest, db=Depends(get_db)):
    try:
        return auth_service.login(request.username, request.password, db)
    except InvalidCredentialsError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@app.post("/auth/logout")
def logout(
    credentials=Depends(HTTPBearer()),
    current_user=Depends(get_current_user)
):
    auth_service.logout(credentials.credentials)
    return {"message": "Successfully logged out"}


@app.get("/api/me")
def get_me(current_user=Depends(get_current_user)):
    return {
        "id": current_user.id,
        "username": current_user.username,
        "roles": current_user.roles,
    }
```

---

## API 参考

### `POST /auth/login`

| 项目 | 描述 |
|------|------|
| **功能** | 用户登录，获取 Token |
| **认证** | 无需认证 |
| **请求体** | `{"username": str, "password": str}` |
| **成功响应** | `200` `{"access_token", "refresh_token", "token_type", "expires_in"}` |
| **失败响应** | `401` 凭据无效 |

### `POST /auth/logout`

| 项目 | 描述 |
|------|------|
| **功能** | 用户登出，吊销当前 Token |
| **认证** | `Bearer <access_token>` |
| **请求体** | 无 |
| **成功响应** | `200` `{"message": "Successfully logged out"}` |
| **失败响应** | `401` Token 无效或已过期 |

### `GET /api/me`（受保护路由示例）

| 项目 | 描述 |
|------|------|
| **功能** | 获取当前登录用户信息 |
| **认证** | `Bearer <access_token>` |
| **请求体** | 无 |
| **成功响应** | `200` `{"id", "username", "roles"}` |
| **失败响应** | `401` Token 无效、过期或已吊销 |

---

*文档生成日期: 2026-03-03 | 遵循 JWT RFC 7519 标准*
