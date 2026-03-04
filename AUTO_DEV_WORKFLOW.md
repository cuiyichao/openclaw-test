# 🚀 auto-dev 自动化开发流程

**版本**: 1.0  
**创建时间**: 2026-03-04  
**测试项目**: 登录页面 (login-page)  
**GitHub 仓库**: https://github.com/cuiyichao/openclaw-test

---

## 📋 流程概览

```
1️⃣ 需求 → 2️⃣ 技术文档 → 3️⃣ 代码实现 → 4️⃣ 代码审查 → 5️⃣ Git 提交 → 6️⃣ 推送 GitHub → 7️⃣ ZIP 发送
```

**预计耗时**: 5-10 分钟（简单项目）

---

## 1️⃣ 生成技术文档

### 创建 TECH_DOC.md

```bash
mkdir -p /root/.openclaw/workspace/projects/<project-name>
cd /root/.openclaw/workspace/projects/<project-name>
```

### 文档模板

```markdown
# <项目名称> - 技术文档

## 功能描述
- 核心功能 1
- 核心功能 2
- 用户场景

## 技术方案
- 前端：HTML/CSS/JavaScript
- 后端：（如需要）
- 依赖库：（如需要）

## 文件结构
```
project-name/
├── index.html
├── css/
│   └── style.css
├── js/
│   └── app.js
└── README.md
```

## 关键实现点
1. 功能点 1 的实现细节
2. 功能点 2 的实现细节
3. 注意事项
```

---

## 2️⃣ 实现代码

### 初始化项目

```bash
# 创建项目目录
cd /root/.openclaw/workspace/projects/<project-name>

# 初始化 Git
git init
git config user.email "openclaw@local"
git config user.name "OpenClaw"

# 创建文件结构
mkdir -p css js
```

### 创建核心文件

**index.html** - 主页面
**css/style.css** - 样式文件
**js/app.js** - 交互逻辑
**README.md** - 项目说明

---

## 3️⃣ 代码审查

### 检查清单

- [ ] 代码规范（命名、缩进、注释）
- [ ] 潜在 bug（空值检查、边界条件）
- [ ] 性能问题（循环、DOM 操作）
- [ ] 安全漏洞（XSS、注入）
- [ ] 响应式设计（移动端适配）

### 简单项目
可跳过此步骤，直接进入 Git 提交。

### 复杂项目
```bash
# 使用子 agent 审查
sessions_spawn(
  agentId: "code-generator",
  task: "审查代码质量，找出问题和改进建议"
)
```

---

## 4️⃣ Git 提交

### 提交命令

```bash
cd /root/.openclaw/workspace/projects/<project-name>

# 添加所有文件
git add -A

# 提交（使用规范的 commit message）
git commit -m "feat: 项目描述

详细说明：
- 功能 1
- 功能 2
- 技术亮点

技术栈：
- HTML/CSS/JavaScript"
```

### Commit Message 规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式（不影响功能）
refactor: 重构
test: 测试相关
chore: 构建/工具配置
```

---

## 5️⃣ 推送到 GitHub

### 配置远程仓库

```bash
# 添加远程仓库（不要包含 token！）
git remote add origin https://github.com/<user>/<repo>.git
```

### ⚠️ Token 安全配置

**❌ 错误方式**（不要这样做）：
```bash
git remote add origin https://ghp_xxx@github.com/user/repo.git
```

**✅ 正确方式**：

**方式 1: 推送时输入**
```bash
git push -u origin <branch>
# Git 会提示输入 token
```

**方式 2: 配置 credential helper**
```bash
# 配置 credential 缓存（1 小时）
git config --global credential.helper 'cache --timeout=3600'

# 或者永久存储
git config --global credential.helper store
```

### 推送到新分支

```bash
# 重命名分支（避免与 master 冲突）
git branch -m master <project-name>

# 推送
git push -u origin <project-name>
```

### 成功输出

```
remote: Create a pull request for '<branch>' on GitHub by visiting:
remote: https://github.com/cuiyichao/openclaw-test/pull/new/<branch>
To https://github.com/cuiyichao/openclaw-test.git
 * [new branch]      <branch> -> <branch>
```

---

## 6️⃣ 打包项目 ZIP

### 打包命令

```bash
# 进入项目父目录
cd /root/.openclaw/workspace/projects

# 打包（排除 .git 目录）
zip -r /tmp/<project-name>-project.zip <project-name>/ -x "*.git*"
```

### 复制到工作区

```bash
# Feishu 只能访问工作区目录
cp /tmp/<project-name>-project.zip /root/.openclaw/workspace/

# 检查文件
ls -lh /root/.openclaw/workspace/<project-name>-project.zip
```

### 排除大文件（可选）

```bash
# 排除 .git、node_modules、videos/frames
zip -r /tmp/project.zip project/ \
  -x "*.git*" \
  -x "node_modules/*" \
  -x "videos/frames/*"
```

---

## 7️⃣ 发送 ZIP 文件（Feishu）

### ✅ 正确方式

```javascript
message(
  action: "send",
  filePath: "/root/.openclaw/workspace/<project-name>-project.zip",
  target: "ou_xxx"  // 可省略，默认当前会话
)
```

### ❌ 错误方式

- `filePath: "/tmp/xxx.zip"` - Feishu 无法访问
- `buffer: "base64..."` - 需要 message 参数，容易失败
- `path: "..."` - 可能只发送路径字符串

### 关键点

1. **文件位置**: 必须在 `/root/.openclaw/workspace/` 目录
2. **参数**: 使用 `filePath` 参数
3. **Feishu**: 会自动处理文件上传

---

## 📊 完整示例（登录页面）

### 项目结构

```
login-page/
├── index.html          # 主页面（2.9KB）
├── css/
│   └── style.css       # 样式（4.3KB）
├── js/
│   └── login.js        # 逻辑（4.7KB）
├── TECH_DOC.md         # 技术文档（1.4KB）
└── README.md           # 说明（1.0KB）
```

### 完整命令序列

```bash
# 1. 创建项目
mkdir -p /root/.openclaw/workspace/projects/login-page
cd /root/.openclaw/workspace/projects/login-page

# 2. 初始化 Git
git init
git config user.email "openclaw@local"
git config user.name "OpenClaw"

# 3. 创建文件（略，使用 write 工具）

# 4. 提交
git add -A
git commit -m "feat: 登录页面

功能：
- 邮箱和密码表单验证
- 密码显示/隐藏切换
- 记住我功能
- 响应式设计

技术栈：
- HTML5/CSS3/JavaScript"

# 5. 推送
git remote add origin https://github.com/cuiyichao/openclaw-test.git
git branch -m master login-page
git push -u origin login-page

# 6. 打包
cd /root/.openclaw/workspace/projects
zip -r /tmp/login-page-project.zip login-page/ -x "*.git*"
cp /tmp/login-page-project.zip /root/.openclaw/workspace/

# 7. 发送
message(action="send", filePath="/root/.openclaw/workspace/login-page-project.zip")
```

---

## 🔗 GitHub 访问

**仓库主页**: https://github.com/cuiyichao/openclaw-test  
**分支列表**: https://github.com/cuiyichao/openclaw-test/branches  
**直接下载**: https://github.com/cuiyichao/openclaw-test/archive/refs/heads/<branch>.zip

### 示例

**登录页面项目**:
- 分支：`login-page`
- 下载：https://github.com/cuiyichao/openclaw-test/archive/refs/heads/login-page.zip
- 查看：https://github.com/cuiyichao/openclaw-test/tree/login-page

---

## ⚠️ 常见问题

### 1. Git 推送被拒绝

**错误**: `remote: Repository not found.`

**解决**: 检查仓库地址和权限

**错误**: `Updates were rejected because the remote contains work`

**解决**: 使用新分支推送
```bash
git branch -m master <new-branch>
git push -u origin <new-branch>
```

### 2. GitHub Secret Scanning 阻止推送

**错误**: `GH013: Repository rule violations found`

**原因**: 提交中包含明文 token

**解决**:
1. 从文件中移除 token
2. 使用 `git commit --amend` 修改提交
3. 重新推送

**预防**: 不要使用 `https://<TOKEN>@github.com/...` 格式

### 3. Feishu 文件发送失败

**错误**: 用户收到路径字符串而不是文件

**原因**: 文件不在工作区目录

**解决**:
```bash
cp /tmp/xxx.zip /root/.openclaw/workspace/
message(action="send", filePath="/root/.openclaw/workspace/xxx.zip")
```

### 4. Git 嵌套仓库警告

**错误**: `warning: adding embedded git repository`

**原因**: 子目录包含独立的 .git 目录

**解决**:
```bash
# 方式 1: 排除子目录
git add --all -- ':!projects/*'

# 方式 2: 移除子目录的 .git
rm -rf projects/<project>/.git
```

---

## 📝 最佳实践

### Commit Message

```bash
# ✅ 好的 commit message
git commit -m "feat: 添加用户登录功能

- 实现邮箱验证
- 实现密码加密
- 添加记住我功能

Closes #123"

# ❌ 不好的 commit message
git commit -m "update"
git commit -m "fix stuff"
```

### 分支命名

```bash
# ✅ 好的分支名
feature/login-page
fix/auth-bug
docs/api-update

# ❌ 不好的分支名
test
new-stuff
fix
```

### 文件大小

- ZIP 文件建议 < 50MB
- 排除不必要的文件（node_modules、videos/frames）
- 大文件考虑使用 Git LFS

---

## 🚀 自动化脚本（待实现）

### auto-dev.sh

```bash
#!/bin/bash
# 一键执行 auto-dev 流程

PROJECT_NAME="$1"
TASK_DESC="$2"

# 1. 创建项目
mkdir -p /root/.openclaw/workspace/projects/$PROJECT_NAME
cd /root/.openclaw/workspace/projects/$PROJECT_NAME

# 2. 生成技术文档
# ... (调用 code-generator)

# 3. 实现代码
# ... (调用 code-generator)

# 4. Git 提交
git init
git add -A
git commit -m "feat: $TASK_DESC"

# 5. 推送
git remote add origin https://github.com/cuiyichao/openclaw-test.git
git branch -m master $PROJECT_NAME
git push -u origin $PROJECT_NAME

# 6. 打包发送
cd ..
zip -r /tmp/$PROJECT_NAME.zip $PROJECT_NAME/ -x "*.git*"
cp /tmp/$PROJECT_NAME.zip /root/.openclaw/workspace/
# 调用 message 工具发送

echo "✅ 完成！"
```

---

## 📚 相关文档

- **MEMORY.md** - 快速参考（主 session）
- **.learnings/LEARNINGS.md** - 经验记录
- **.learnings/ERRORS.md** - 错误日志
- **.learnings/FEATURE_REQUESTS.md** - 功能请求

---

_最后更新：2026-03-04_  
_基于登录页面项目测试总结_
