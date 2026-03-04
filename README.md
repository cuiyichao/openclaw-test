# 登录页面

一个简洁、现代的登录页面，包含完整的表单验证和交互功能。

## ✨ 功能特性

- 📧 邮箱格式验证
- 🔒 密码强度验证（最少 6 位）
- 👁️ 密码显示/隐藏切换
- ✅ 实时表单验证反馈
- 💾 记住我功能（本地存储）
- 📱 响应式设计（支持移动端）
- 🎨 现代渐变设计
- ⏳ 加载状态指示

## 🚀 快速开始

### 方法 1: 直接打开
```bash
# 直接在浏览器中打开
open index.html
```

### 方法 2: 使用本地服务器
```bash
# Python 3
python -m http.server 8000

# 然后访问 http://localhost:8000
```

## 📁 项目结构

```
login-page/
├── index.html        # 主页面
├── css/
│   └── style.css     # 样式文件
├── js/
│   └── login.js      # 交互逻辑
├── TECH_DOC.md       # 技术文档
└── README.md         # 项目说明
```

## 🧪 测试账号

- **邮箱**: test@example.com
- **密码**: 123456

## 🎨 自定义

### 修改颜色
编辑 `css/style.css` 中的渐变颜色：
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### 修改验证规则
编辑 `js/login.js` 中的验证函数：
```javascript
// 修改密码最小长度
if (password.length < 6) {  // 改为你想要的长度
```

## 📦 技术栈

- HTML5
- CSS3 (Flexbox, Animations)
- JavaScript (ES6+)
- Font Awesome (图标)

## 🔐 安全说明

⚠️ **这是一个演示项目**，仅用于测试 auto-dev 流程。

实际生产环境需要：
- 后端 API 验证
- HTTPS 加密传输
- CSRF 保护
- 密码加密存储
- 速率限制

## 📝 License

MIT
