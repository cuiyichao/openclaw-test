# MEMORY.md - 长期记忆

_这是主 agent（main）的长期记忆，只在直接对话中加载。_

**⚠️ 重要**: 此文件仅在主 session（与用户的直接对话）中读取。子 agent 不应访问此文件。

---

## 👤 用户信息

- **称呼**: 用户
- **时区**: UTC+8 (中国)
- **主要使用**: Feishu (飞书)

## 🎯 用户偏好

- **路由方式**: 语义理解路由，不要关键词匹配
- **多 agent 协作**: 需要时自动 spawn 子 agent
- **输出格式**: 结构化笔记，优先输出到 Notion
- **透明度**: 调用子 agent 时要告知用户

## 🛠️ 已配置系统

### 多 Agent 系统
```
- main (default): 路由协调 + 通用对话
- code-generator: 代码生成 (qwen3-coder-plus)
- writing-agent (文心 ✒️): 文档写作
- research-agent (知更 🔍): 研究分析
```

### EvoMap 账户
```
- Node ID: node_95f58cbdceae438a
- Claim Code: 2745-2VAU
- Claim URL: https://evomap.ai/claim/2745-2VAU
- 初始积分：500 credits
- 心跳间隔：15 分钟 (900000ms)
- 状态：已注册，等待用户绑定
```

### 已安装 Skills
- YouTube/B 站视频学习全套
- Notion 集成
- Feishu 集成

### 认证配置
- **B 站**: 已登录，Cookie 保存在 `bilibili_cookie.txt`
- **Notion**: API key 已配置 `~/.config/notion/api_key`

## 📚 重要项目

### 视频学习流程
- 完整流程已文档化并同步到 Notion
- 支持 B 站和 YouTube（YouTube 需要 VPN）
- 流程：登录 → 下载 → 提取帧 → 分析 → 输出笔记

### 多 Agent 路由
- 采用语义理解而非关键词匹配
- 支持显式指定 (@agent 或 /command)
- 路由逻辑在 `skills/router/SKILL.md`

## 📝 重要决定

- 2026-03-01: 确定使用语义理解路由，不用关键词匹配
- 2026-03-01: 安装视频学习技能组合
- 2026-03-01: 配置 Notion 输出

## 🔐 安全配置

- Feishu groupPolicy 当前为 "open"（需要改为 allowlist）
- 云服务器 IP 被 YouTube 限制（需要 VPN）
- B 站 Cookie 已保存，可长期使用

## 📂 重要文件位置

```
工作区：~/.openclaw/workspace/
配置文件：~/.openclaw/openclaw.json
Notion key: ~/.config/notion/api_key
B 站 Cookie: ~/.openclaw/workspace/bilibili_cookie.txt
视频文件：~/.openclaw/workspace/videos/
```

## 📝 成功流程记录 (2026-03-04)

### auto-dev 完整流程（需求→代码→Git→ZIP 发送）

```
1. 📝 生成技术文档 → 写入 TECH_DOC.md
2. 💻 实现代码 → index.html + css/style.css + js/login.js
3. 🔍 代码审查 → 检查代码质量（可 spawn 子 agent）
4. 📦 Git 提交 → git add -A && git commit -m "feat: xxx"
5. 🚀 推送到 GitHub → git push -u origin <branch-name>
6. 📬 发送 ZIP → 用 message 工具发送文件
```

### ✅ Feishu 文件发送方式

**正确方式**（已验证成功）：
```javascript
message(
  action: "send",
  filePath: "/root/.openclaw/workspace/xxx.zip",  // 必须是工作区路径
  target: "ou_xxx"  // 用户 ID，可省略（默认当前会话）
)
```

**关键点**：
1. 文件必须放在 `/root/.openclaw/workspace/` 目录下
2. 使用 `filePath` 参数（不是 `path` 或 `buffer`）
3. 先用 `cp` 把文件复制到工作区
4. Feishu 会自动处理文件发送

**错误方式**（不要用）：
- ❌ `path` 参数 - 可能只发送路径字符串
- ❌ `buffer` 参数 - 需要 message 参数配合，容易失败
- ❌ 绝对路径 `/tmp/xxx` - Feishu 可能无法访问

### ✅ Git 推送流程

```bash
# 1. 初始化项目 git
cd /root/.openclaw/workspace/projects/<project-name>
git init
git config user.email "openclaw@local"
git config user.name "OpenClaw"

# 2. 提交代码
git add -A
git commit -m "feat: 项目描述"

# 3. 推送到 GitHub（使用 token 认证）
git remote add origin https://<TOKEN>@github.com/<user>/<repo>.git
git push -u origin <branch-name>
```

**GitHub Token**: 已配置在 git credential 中
**仓库地址**: https://github.com/cuiyichao/openclaw-test

### ✅ 项目打包方式

```bash
# 打包项目（排除.git 目录）
cd /root/.openclaw/workspace/projects
zip -r /tmp/<project-name>-project.zip <project-name>/ -x "*.git*"

# 复制到工作区（Feishu 可访问）
cp /tmp/<project-name>-project.zip /root/.openclaw/workspace/

# 发送
message(action="send", filePath="/root/.openclaw/workspace/<project-name>-project.zip")
```

### 📋 测试项目示例

**登录页面项目** (login-page)：
- 技术文档：TECH_DOC.md
- 文件：index.html, css/style.css, js/login.js
- GitHub: https://github.com/cuiyichao/openclaw-test/tree/login-page
- 测试账号：test@example.com / 123456

---

_最后更新：2026-03-04_
