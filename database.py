import uuid
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, JSON, String
from sqlalchemy.orm import DeclarativeBase, sessionmaker
from sqlalchemy import create_engine

DATABASE_URL = "sqlite:///./auth_demo.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


class UserDB(Base):
    """SQLAlchemy ORM 用户模型"""
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    roles = Column(JSON, default=list)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


def get_db():
    """FastAPI 依赖：提供数据库会话，用完后自动关闭。"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """创建所有数据库表。应在应用启动时调用。"""
    Base.metadata.create_all(bind=engine)
