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

---

_最后更新：2026-03-01_
