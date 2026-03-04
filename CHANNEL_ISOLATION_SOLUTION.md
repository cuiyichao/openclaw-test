# 🧩 渠道隔离解决方案

**问题**: 不同渠道（Feishu/Discord/Telegram）和不同 session 之间记忆不共享

**创建时间**: 2026-03-04

---

## 📋 问题描述

### 渠道隔离现状

```
Session A (Feishu - 主 session)
├── MEMORY.md ✅ 可访问
├── memory/2026-03-04.md ✅
└── .learnings/ ✅

Session B (Feishu - 子 session/其他渠道)
├── MEMORY.md ❌ 不加载（安全限制）
├── memory/2026-03-04.md ❌ 可能缺失
└── .learnings/ ❌ 可能无法访问
```

### 导致的问题

1. **记忆丢失**: 昨天的对话在另一个 session，今天想不起来
2. **重复工作**: 不同 session 重复解决同样的问题
3. **上下文断裂**: 用户提到之前的对话，但当前 session 没有记录

---

## 🔧 解决方案：中央记忆库

### CENTRAL_MEMORY.md

创建一个**所有渠道共享**的记忆文件：

**位置**: `/root/.openclaw/workspace/CENTRAL_MEMORY.md`

**特点**:
- ✅ 所有 session 都可以读写
- ✅ 不受渠道隔离限制
- ✅ 包含最新记忆和待办事项
- ✅ 包含系统配置和重要文档位置

### 使用规范

#### 每次 Session 开始时

```bash
# 1. 读取中央记忆库
read CENTRAL_MEMORY.md

# 2. 了解最新状态
- 最新记忆 (Latest Memory)
- 待办事项 (Pending Tasks)
- 系统配置 (System Config)

# 3. 记录 session 开始
更新 CENTRAL_MEMORY.md:
- Session 开始时间
- 渠道信息
- 当前任务
```

#### 每次 Session 结束时

```bash
# 1. 更新中央记忆库
更新 CENTRAL_MEMORY.md:
- 本次完成的工作
- 新学到的东西
- 新发现的问题
- 更新待办事项状态

# 2. 重要记忆同步（main session only）
- 将重要记忆归档到 MEMORY.md
- 将经验记录到 .learnings/
```

---

## 📝 记忆层级结构

```
CENTRAL_MEMORY.md          ← 所有渠道共享（最新状态）
    ↓
MEMORY.md                  ← 主 session 专用（长期记忆）
    ↓
memory/YYYY-MM-DD.md       ← 每日记忆（详细日志）
    ↓
.learnings/                ← 自我改进记录（标准化格式）
```

### 各层级用途

| 文件 | 用途 | 访问范围 | 更新频率 |
|------|------|----------|----------|
| CENTRAL_MEMORY.md | 跨渠道共享记忆 | 所有 session | 每次 session |
| MEMORY.md | 长期记忆 | 主 session only | 每周/重要事件 |
| memory/YYYY-MM-DD.md | 每日详细日志 | 主 session | 每天 |
| .learnings/ | 标准化经验记录 | 所有 session | 随时 |

---

## 🔄 记忆同步流程

### 主 Session (Main Session)

```
Session 开始:
1. 读取 CENTRAL_MEMORY.md (获取最新状态)
2. 读取 MEMORY.md (获取长期记忆)
3. 读取 memory/YYYY-MM-DD.md (获取昨日/今日记忆)
4. 开始工作

Session 结束:
1. 更新 memory/YYYY-MM-DD.md (记录今日工作)
2. 更新 CENTRAL_MEMORY.md (同步最新状态)
3. 如有重要记忆，更新 MEMORY.md
4. 如有新经验，更新 .learnings/
```

### 子 Session / 其他渠道

```
Session 开始:
1. 读取 CENTRAL_MEMORY.md (获取最新状态)
2. 读取 SOUL.md, USER.md (基本信息)
3. 开始工作

Session 结束:
1. 更新 CENTRAL_MEMORY.md (同步完成的工作)
2. 如有重要经验，更新 .learnings/
```

---

## 🛠️ 自动化工具

### memory-maintenance.sh

```bash
#!/bin/bash
# 自动检查记忆系统状态

# 检查 CENTRAL_MEMORY.md 是否存在
# 检查今日记忆文件是否存在
# 检查昨日记忆文件是否存在
# 统计待办事项

bash scripts/memory-maintenance.sh
```

### HEARTBEAT.md 集成

```markdown
## 每次 Session 开始时
- [ ] 读取 CENTRAL_MEMORY.md
- [ ] 更新 CENTRAL_MEMORY.md 记录 session 开始
- [ ] 检查 memory/YYYY-MM-DD.md 是否存在
```

---

## 📊 实际示例

### 示例 1: 跨天记忆

**Day 1 (2026-03-03) - Session A**:
```
用户：帮我写个登录页面
AI: 完成！已推送到 GitHub

更新 CENTRAL_MEMORY.md:
- 2026-03-03 15:00: 完成登录页面项目
- GitHub: https://github.com/.../login-page
```

**Day 2 (2026-03-04) - Session B**:
```
AI: 读取 CENTRAL_MEMORY.md
AI: 看到昨天完成了登录页面

用户：昨天的登录页面做的怎么样了？
AI: 昨天已完成并推送到 GitHub，链接是...
```

### 示例 2: 跨渠道记忆

**Feishu Session**:
```
用户：我要做个登录页面
AI: 好的，开始实现...

更新 CENTRAL_MEMORY.md:
- 2026-03-04 10:00: 开始登录页面项目
```

**Discord Session** (同一用户，不同渠道):
```
AI: 读取 CENTRAL_MEMORY.md
AI: 看到 Feishu session 开始了登录页面项目

用户：继续早上的登录页面
AI: 好的，继续登录页面项目，目前进展是...
```

---

## ⚠️ 注意事项

### 安全限制

1. **MEMORY.md 只在主 session 加载**
   - 包含个人敏感信息
   - 不在子 session 或群聊中加载

2. **CENTRAL_MEMORY.md 不包含敏感信息**
   - 只记录工作任务和公开信息
   - 可以安全地在所有渠道共享

### 冲突处理

如果多个 session 同时更新 CENTRAL_MEMORY.md：

1. **使用追加方式**，不要覆盖
2. **标记时间戳**，便于追踪
3. **定期归档**，避免文件过大

---

## 📈 效果对比

### 实施前

```
❌ Session A: 用户提到昨天的事 → AI: 我不记得了
❌ Session B: 用户继续之前的话题 → AI: 请重新说明
❌ 跨渠道：每个渠道都是全新的开始
```

### 实施后

```
✅ Session A: 用户提到昨天的事 → AI: 读取 CENTRAL_MEMORY.md → 我记得！
✅ Session B: 用户继续之前的话题 → AI: 查看最新状态 → 继续处理
✅ 跨渠道：所有渠道共享最新记忆
```

---

## 🚀 下一步优化

- [ ] 自动在 session 开始时读取 CENTRAL_MEMORY.md
- [ ] 自动在 session 结束时更新 CENTRAL_MEMORY.md
- [ ] 定期（每周）归档 CENTRAL_MEMORY.md 到 MEMORY.md
- [ ] 添加记忆过期机制（删除 30 天前的临时记忆）
- [ ] 支持记忆搜索功能

---

_此文档基于 2026-03-04 渠道隔离问题创建_
_所有 session 应该遵循此规范_
