import uuid
from contextlib import asynccontextmanager
from dataclasses import asdict

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPBearer
from passlib.context import CryptContext
from pydantic import BaseModel
from sqlalchemy.orm import Session

from auth.auth_service import AuthService
from auth.dependencies import get_current_user
from auth.exceptions import InvalidCredentialsError, TokenCreationError
from database import UserDB, get_db, init_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
auth_service = AuthService()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用启动时初始化数据库表。"""
    init_db()
    yield


app = FastAPI(
    title="JWT Auth Demo",
    description="基于 PyJWT + Redis 的无状态用户认证 API",
    version="1.0.0",
    lifespan=lifespan,
)


# ── 请求体模型 ────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str


class LoginRequest(BaseModel):
    username: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


# ── 路由 ──────────────────────────────────────────────────────────────────────

@app.post("/auth/register", status_code=201, summary="注册新用户")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    """注册新用户（演示接口，生产环境应限制访问）。"""
    existing = db.query(UserDB).filter(
        (UserDB.username == request.username) | (UserDB.email == request.email)
    ).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username or email already registered",
        )

    user = UserDB(
        id=str(uuid.uuid4()),
        username=request.username,
        email=request.email,
        hashed_password=pwd_context.hash(request.password),
        roles=["user"],
    )
    db.add(user)
    db.commit()
    return {"message": "User registered successfully", "user_id": user.id}


@app.post("/auth/login", summary="用户登录")
def login(request: LoginRequest, db: Session = Depends(get_db)):
    """验证用户凭据，签发 Access Token 和 Refresh Token。"""
    try:
        result = auth_service.login(request.username, request.password, db)
        return asdict(result)
    except InvalidCredentialsError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))
    except TokenCreationError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e)
        )


@app.post("/auth/logout", summary="用户登出")
def logout(
    credentials=Depends(HTTPBearer()),
    current_user=Depends(get_current_user),
):
    """将当前 Access Token 加入黑名单，使其立即失效。"""
    auth_service.logout(credentials.credentials)
    return {"message": "Successfully logged out"}


@app.post("/auth/refresh", summary="刷新 Token")
def refresh(request: RefreshRequest):
    """使用 Refresh Token 换取新的 Token 对（Refresh Token 轮换）。"""
    try:
        result = auth_service.refresh_tokens(request.refresh_token)
        return asdict(result)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@app.get("/api/me", summary="获取当前用户信息")
def get_me(current_user=Depends(get_current_user)):
    """返回当前已认证用户的基本信息。"""
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "roles": current_user.roles,
    }


# ── 入口 ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
