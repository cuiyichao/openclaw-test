# auto-dev 完整流程指南

**创建时间**: 2026-03-04  
**测试项目**: 登录页面 (login-page)

---

## 📋 完整流程

```
用户需求 → 技术文档 → 代码实现 → 代码审查 → Git 提交 → 推送 GitHub → ZIP 发送
```

---

## 1️⃣ 生成技术文档

创建 `TECH_DOC.md`，包含：
- 功能描述
- 技术方案
- 文件结构
- 关键实现点

**示例**：
```markdown
# 项目名称 - 技术文档

## 功能描述
...

## 技术方案
...

## 文件结构
...

## 关键实现点
...
```

---

## 2️⃣ 实现代码

根据技术文档创建项目文件：

```bash
# 创建项目目录
mkdir -p /root/.openclaw/workspace/projects/<project-name>
cd /root/.openclaw/workspace/projects/<project-name>

# 初始化 Git
git init
git config user.email "openclaw@local"
git config user.name "OpenClaw"

# 创建文件结构
mkdir -p css js
```

**典型文件**：
- `index.html` - 主页面
- `css/style.css` - 样式文件
- `js/app.js` - 交互逻辑
- `README.md` - 项目说明

---

## 3️⃣ 代码审查

检查代码质量：
- 代码规范
- 潜在 bug
- 性能问题
- 安全漏洞

**简单项目可跳过此步骤**，复杂项目可 spawn 子 agent 审查。

---

## 4️⃣ Git 提交

```bash
cd /root/.openclaw/workspace/projects/<project-name>

git add -A
git commit -m "feat: 项目描述

详细说明：
- 功能 1
- 功能 2
- 技术亮点"
```

---

## 5️⃣ 推送到 GitHub

```bash
# 添加远程仓库（使用 token 认证）
git remote add origin https://github.com/cuiyichao/openclaw-test.git
# 推送时 Git 会提示输入 token，或提前配置 git credential

# 推送到新分支
git branch -m master <project-name>
git push -u origin <project-name>
```

**成功输出**：
```
remote: Create a pull request for '<branch>' on GitHub by visiting:
remote: https://github.com/cuiyichao/openclaw-test/pull/new/<branch>
```

---

## 6️⃣ 打包项目 ZIP

```bash
# 打包（排除.git 目录）
cd /root/.openclaw/workspace/projects
zip -r /tmp/<project-name>-project.zip <project-name>/ -x "*.git*"

# 复制到工作区（Feishu 可访问）
cp /tmp/<project-name>-project.zip /root/.openclaw/workspace/

# 检查文件
ls -lh /root/.openclaw/workspace/<project-name>-project.zip
```

---

## 7️⃣ 发送 ZIP 文件（Feishu）

**✅ 正确方式**：
```javascript
message(
  action: "send",
  filePath: "/root/.openclaw/workspace/<project-name>-project.zip",
  target: "ou_xxx"  // 可省略，默认当前会话
)
```

**❌ 错误方式**：
- 不要用 `/tmp/` 路径 - Feishu 无法访问
- 不要用 `buffer` 参数 - 容易失败
- 不要用 `path` 参数 - 可能只发送路径字符串

**关键点**：
1. 文件必须在 `/root/.openclaw/workspace/` 目录下
2. 使用 `filePath` 参数
3. Feishu 会自动处理文件上传

---

## 📊 完整示例（登录页面）

### 项目结构
```
login-page/
├── index.html        # 主页面
├── css/
│   └── style.css     # 样式
├── js/
│   └── login.js      # 逻辑
├── TECH_DOC.md       # 技术文档
└── README.md         # 说明
```

### Git 命令
```bash
cd /root/.openclaw/workspace/projects/login-page
git init
git config user.email "openclaw@local"
git config user.name "OpenClaw"
git add -A
git commit -m "feat: 登录页面"
git remote add origin https://github.com/cuiyichao/openclaw-test.git
git branch -m master login-page
git push -u origin login-page
```

### 打包发送
```bash
cd /root/.openclaw/workspace/projects
zip -r /tmp/login-page-project.zip login-page/ -x "*.git*"
cp /tmp/login-page-project.zip /root/.openclaw/workspace/
# 然后用 message 工具发送
```

---

## 🔗 GitHub 访问

**仓库**: https://github.com/cuiyichao/openclaw-test  
**分支**: `<project-name>`  
**直接下载**: https://github.com/cuiyichao/openclaw-test/archive/refs/heads/<project-name>.zip

---

## ⚠️ 注意事项

1. **Git 冲突**: 如果远程已有内容，用新分支推送
2. **文件大小**: ZIP 文件不要太大（建议 < 50MB）
3. **Feishu 限制**: 文件必须在工作区目录
4. **Token 安全**: GitHub token 不要泄露

---

## 📝 待优化

- [ ] 自动化脚本（一键执行全流程）
- [ ] 代码审查自动化（集成 ESLint/Prettier）
- [ ] 自动创建 GitHub Release
- [ ] 支持多个 Git 远程仓库

---

_此文档基于 2026-03-04 登录页面项目测试总结_
