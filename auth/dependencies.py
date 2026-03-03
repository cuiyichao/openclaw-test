from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from database import UserDB, get_db

from .exceptions import InvalidTokenError, TokenExpiredError, TokenRevokedError
from .token_manager import TokenManager

security = HTTPBearer()
token_manager = TokenManager()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
):
    """
    FastAPI 路由依赖：验证 Token 并返回当前用户。

    Usage:
        @app.get("/api/me")
        def get_me(user = Depends(get_current_user)):
            return user

    Raises:
        HTTPException 401: Token 无效、过期或已吊销
        HTTPException 401: 用户不存在或已禁用
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

    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    return user
