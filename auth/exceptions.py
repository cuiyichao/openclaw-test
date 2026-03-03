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
