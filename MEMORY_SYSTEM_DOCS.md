# 🧠 记忆系统架构文档

**版本**: 1.0  
**创建时间**: 2026-03-04  
**最后更新**: 2026-03-04 14:01

---

## 📋 目录

1. [系统概览](#系统概览)
2. [记忆存储结构](#记忆存储结构)
3. [渠道隔离机制](#渠道隔离机制)
4. [记忆层级关系](#记忆层级关系)
5. [记忆加载流程](#记忆加载流程)
6. [文件详细说明](#文件详细说明)
7. [使用示例](#使用示例)
8. [维护命令](#维护命令)
9. [最佳实践](#最佳实践)

---

## 系统概览

### 设计目标

- ✅ **渠道隔离**: 不同渠道（飞书/Yach）的记忆独立存储
- ✅ **配置共享**: 系统配置和用户偏好所有渠道共享
- ✅ **层级清晰**: 从临时记忆到长期记忆的清晰分层
- ✅ **易于维护**: 自动化脚本定期检查记忆状态

### 核心特性

| 特性 | 说明 |
|------|------|
| 渠道隔离 | 飞书和 Yach 记忆完全独立，互不干扰 |
| 通用共享 | 系统配置、用户偏好所有渠道共享 |
| 层级结构 | 5 层记忆结构，从具体到抽象 |
| 自动化 | 记忆维护脚本自动检查和创建文件 |

---

## 记忆存储结构

### 目录结构

```
/root/.openclaw/workspace/memory/
│
├── 📁 feishu/                          # 飞书渠道专用
│   └── CENTRAL_MEMORY.md               # 飞书中央记忆
│
├── 📁 yach/                            # Yach 渠道专用
│   └── CENTRAL_MEMORY.md               # Yach 中央记忆
│
├── 📁 common/                          # 所有渠道共享
│   └── CENTRAL_MEMORY.md               # 通用配置
│
├── 📄 2026-03-01.md                    # 历史记忆文件
├── 📄 2026-03-04.md                    # 今日记忆文件
│
└── 📁 evolution/                       # EvoMap 进化数据
    ├── memory_graph.jsonl
    ├── personality_state.json
    └── ...
```

### 文件大小

| 文件 | 大小 | 说明 |
|------|------|------|
| memory/feishu/CENTRAL_MEMORY.md | 2.2KB | 飞书工作记忆 |
| memory/yach/CENTRAL_MEMORY.md | 406B | Yach 个人记忆 |
| memory/common/CENTRAL_MEMORY.md | 1.2KB | 通用配置 |
| memory/2026-03-04.md | 2.0KB | 今日日志 |
| memory/2026-03-01.md | 2.0KB | 历史日志 |

---

## 渠道隔离机制

### 渠道定义

| 渠道代码 | 用途 | 记忆位置 |
|---------|------|---------|
| `feishu` | 工作、OpenClaw 开发、文档协作 | `memory/feishu/` |
| `yach` | 个人用途、测试、娱乐 | `memory/yach/` |
| `common` | 系统配置、用户偏好 | `memory/common/` |

### 隔离规则

```
飞书 Session                    Yach Session
┌─────────────────────┐        ┌─────────────────────┐
│ memory/feishu/      │        │ memory/yach/        │
│ ├─ CENTRAL_MEMORY.md│        │ ├─ CENTRAL_MEMORY.md│
│ └─ 2026-03-04.md    │        │ └─ 2026-03-04.md    │
│                     │        │                     │
│ ✅ 工作项目          │        │ ✅ 个人项目          │
│ ✅ OpenClaw 开发     │        │ ✅ 测试功能          │
│ ✅ 文档协作          │        │ ✅ 娱乐内容          │
└─────────────────────┘        └─────────────────────┘
         ↓                              ↓
┌─────────────────────────────────────────────────┐
│           memory/common/ (共享)                  │
│           ├─ CENTRAL_MEMORY.md                   │
│           └─ 系统配置、用户偏好                   │
└─────────────────────────────────────────────────┘
```

### 隔离效果

**✅ 飞书 Session 看不到 Yach 记忆**
```
用户（飞书）：帮我写个工作报告
AI: 读取 memory/feishu/CENTRAL_MEMORY.md
AI: 好的，开始编写工作报告...
（不会看到 Yach 的个人项目）
```

**✅ Yach Session 看不到飞书记忆**
```
用户（Yach）：帮我写个游戏脚本
AI: 读取 memory/yach/CENTRAL_MEMORY.md
AI: 好的，开始编写游戏脚本...
（不会看到飞书的工作项目）
```

---

## 记忆层级关系

### 5 层记忆结构

```
第 1 层：渠道隔离层（最具体）
┌─────────────────────────────────────┐
│ memory/feishu/CENTRAL_MEMORY.md     │ ← 飞书工作记忆
│ memory/yach/CENTRAL_MEMORY.md       │ ← Yach 个人记忆
└─────────────────────────────────────┘
              ↓
第 2 层：通用配置层（共享）
┌─────────────────────────────────────┐
│ memory/common/CENTRAL_MEMORY.md     │ ← 系统配置、用户偏好
└─────────────────────────────────────┘
              ↓
第 3 层：每日日志层（详细记录）
┌─────────────────────────────────────┐
│ memory/2026-03-04.md                │ ← 今日详细日志
│ memory/2026-03-01.md                │ ← 历史日志
└─────────────────────────────────────┘
              ↓
第 4 层：长期记忆层（主 session 专用）
┌─────────────────────────────────────┐
│ MEMORY.md                           │ ← 长期记忆（仅主 session）
└─────────────────────────────────────┘
              ↓
第 5 层：进化数据层（EvoMap）
┌─────────────────────────────────────┐
│ memory/evolution/                   │ ← 自我进化数据
└─────────────────────────────────────┘
```

### 各层用途

| 层级 | 文件 | 用途 | 访问范围 | 更新频率 |
|------|------|------|----------|----------|
| 1 | `memory/<channel>/CENTRAL_MEMORY.md` | 渠道最新状态 | 渠道特定 | 每次 session |
| 2 | `memory/common/CENTRAL_MEMORY.md` | 通用配置 | 所有渠道 | 配置变更时 |
| 3 | `memory/YYYY-MM-DD.md` | 每日详细日志 | 主 session | 每天 |
| 4 | `MEMORY.md` | 长期记忆 | 主 session only | 每周/重要事件 |
| 5 | `memory/evolution/` | 进化数据 | 系统内部 | 自动更新 |

---

## 记忆加载流程

### 飞书 Session 开始时

```bash
# 1. 确定渠道
CHANNEL="feishu"

# 2. 读取渠道记忆（第 1 层）
read memory/feishu/CENTRAL_MEMORY.md
# → 获取：auto-dev 流程、待办事项、工作项目

# 3. 读取通用记忆（第 2 层）
read memory/common/CENTRAL_MEMORY.md
# → 获取：多 Agent 系统、Git 配置、用户偏好

# 4. 读取每日日志（第 3 层）
read memory/2026-03-04.md
# → 获取：今日详细工作记录

# 5. 读取长期记忆（第 4 层，主 session only）
read MEMORY.md
# → 获取：长期记忆、重要决策
```

### Yach Session 开始时

```bash
# 1. 确定渠道
CHANNEL="yach"

# 2. 读取渠道记忆（第 1 层）
read memory/yach/CENTRAL_MEMORY.md
# → 获取：个人项目、测试记录

# 3. 读取通用记忆（第 2 层）
read memory/common/CENTRAL_MEMORY.md
# → 获取：多 Agent 系统、Git 配置、用户偏好

# 4. 读取每日日志（第 3 层）
read memory/2026-03-04.md
# → 获取：今日详细记录

# 5. 读取长期记忆（第 4 层，主 session only）
read MEMORY.md
# → 获取：长期记忆、重要决策
```

---

## 文件详细说明

### 1. memory/feishu/CENTRAL_MEMORY.md

**用途**: 飞书渠道中央记忆

**内容结构**:
```markdown
# 📌 飞书 (Feishu) 渠道记忆

**用途**: 工作相关、正式沟通、文档协作、OpenClaw 开发

## 📋 最新记忆

### 2026-03-04 12:00 - auto-dev 完整流程测试完成
**项目**: 登录页面
**状态**: ✅ 完成

## 📝 待办事项
- [ ] 检查悬赏任务审核状态
- [ ] 完善 auto-dev 自动化脚本

## 🛠️ 渠道配置
渠道：feishu
用户 ID: ou_45002b5fc5dab94f1d6ffa620638314b
用途：工作、OpenClaw 开发
```

### 2. memory/yach/CENTRAL_MEMORY.md

**用途**: Yach 渠道中央记忆

**内容结构**:
```markdown
# 📌 Yach 渠道记忆

**用途**: 个人用途、测试、娱乐

## 📋 最新记忆
### YYYY-MM-DD HH:MM - (待填写)
**状态**: 🟡 处理中

## 📝 待办事项
- [ ] (待填写)
```

### 3. memory/common/CENTRAL_MEMORY.md

**用途**: 所有渠道共享的通用配置

**内容结构**:
```markdown
# 📌 通用记忆 (Common)

**用途**: 所有渠道共享的基础记忆

## 🛠️ 系统配置
多 Agent 系统:
- main (default): 路由协调
- code-generator: 代码生成
- writing-agent: 文档写作
- research-agent: 研究分析

## 🎯 用户偏好
- 路由方式：语义理解路由
- 渠道隔离：✅ 飞书和 Yach 记忆分开

## 📚 渠道列表
| 渠道 | 用途 | 记忆文件 |
|------|------|----------|
| Feishu | 工作 | memory/feishu/ |
| Yach | 个人 | memory/yach/ |
```

### 4. memory/YYYY-MM-DD.md

**用途**: 每日详细工作日志

**内容结构**:
```markdown
# YYYY-MM-DD 工作日志

## 📋 今日完成

### 任务 1
- ✅ 完成内容

### 任务 2
- ✅ 完成内容

## 📝 学到的东西
1. 经验 1
2. 经验 2

## 🔧 配置变更
- 更新内容

## ⚠️ 发现的问题
### 问题描述
- 详情

### 解决方案
- 方法

## 💡 想法
- 新想法
```

### 5. MEMORY.md

**用途**: 长期记忆（仅主 session 加载）

**内容结构**:
```markdown
# MEMORY.md - 长期记忆

## 👤 用户信息
- 称呼：用户
- 时区：UTC+8
- 主要使用：Feishu

## 🎯 用户偏好
- 路由方式：语义理解路由
- 多 agent 协作：需要时自动 spawn

## 🛠️ 已配置系统
- 多 Agent 系统
- EvoMap 账户
- 已安装 Skills

## 📝 重要决定
- 2026-03-01: 语义理解路由
- 2026-03-04: 渠道隔离记忆系统
```

---

## 使用示例

### 示例 1: 飞书工作项目

**场景**: 用户在飞书中继续昨天的工作

```
Session 开始:
1. AI 读取 memory/feishu/CENTRAL_MEMORY.md
2. 看到昨天完成了 auto-dev 流程测试
3. AI: "昨天我们完成了登录页面项目，今天继续什么工作？"

用户：继续完善 auto-dev 脚本
AI: 好的，继续 auto-dev 自动化脚本的开发...

Session 结束:
1. AI 更新 memory/feishu/CENTRAL_MEMORY.md
   - 记录：开始 auto-dev 脚本开发
2. AI 更新 memory/feishu/2026-03-04.md
   - 详细记录开发过程
```

### 示例 2: Yach 个人项目

**场景**: 用户在 Yach 中测试新功能

```
Session 开始:
1. AI 读取 memory/yach/CENTRAL_MEMORY.md
2. 看到 Yach 渠道的个人项目记录
3. AI: "准备好测试新功能了吗？"

用户：帮我写个游戏脚本
AI: 好的，开始编写游戏脚本...

Session 结束:
1. AI 更新 memory/yach/CENTRAL_MEMORY.md
   - 记录：完成游戏脚本
2. AI 更新 memory/yach/2026-03-04.md
   - 详细记录测试过程

（飞书渠道完全看不到这些记录）✅
```

### 示例 3: 跨渠道配置同步

**场景**: 更新多 Agent 系统配置

```
飞书 Session:
用户：添加一个新的 agent
AI: 好的，更新配置...

Session 结束:
1. AI 更新 memory/feishu/CENTRAL_MEMORY.md
   - 记录：添加新 agent
2. AI 更新 memory/common/CENTRAL_MEMORY.md
   - 同步：多 Agent 系统配置更新

Yach Session (下次开始):
1. AI 读取 memory/yach/CENTRAL_MEMORY.md
2. AI 读取 memory/common/CENTRAL_MEMORY.md
   → 看到新的 agent 配置
3. AI: "新的 agent 已配置完成，要使用吗？"
```

---

## 维护命令

### 检查记忆状态

```bash
# 检查飞书记忆
bash scripts/memory-maintenance.sh feishu

# 检查 Yach 记忆
bash scripts/memory-maintenance.sh yach

# 检查其他渠道
bash scripts/memory-maintenance.sh <channel>
```

### 输出示例

```
🧠 Memory Maintenance - Channel: feishu - 2026-03-04
================================
✅ 渠道记忆目录存在：/root/.openclaw/workspace/memory/feishu
✅ 今日记忆文件已存在
✅ 昨日记忆文件已存在
✅ 渠道中央记忆文件已存在

📊 最近 7 天记忆文件状态 (feishu):
  ✅ 2026-03-04 (2086 bytes)
  ❌ 2026-03-03 (缺失)
  ❌ 2026-03-02 (缺失)
  ✅ 2026-03-01 (2082 bytes)
  ❌ 2026-02-28 (缺失)
  ❌ 2026-02-27 (缺失)
  ❌ 2026-02-26 (缺失)

📋 通用记忆状态:
  ✅ common/CENTRAL_MEMORY.md (最后更新：2026-03-04)

📚 .learnings/ 状态:
  待处理学习：0
  待处理错误：0
  待处理功能：3

✅ Memory Maintenance 完成
```

### 初始化新渠道

```bash
# 创建新渠道记忆目录
bash scripts/memory-init-channel.sh discord

# 输出:
# ✅ 已创建 discord 渠道记忆目录
```

---

## 最佳实践

### 1. Session 开始时

```bash
# ✅ 正确：读取渠道记忆
read memory/<channel>/CENTRAL_MEMORY.md
read memory/common/CENTRAL_MEMORY.md

# ❌ 错误：跳过渠道记忆
# 直接开始工作，不读取记忆
```

### 2. Session 结束时

```bash
# ✅ 正确：更新渠道记忆
更新 memory/<channel>/CENTRAL_MEMORY.md
更新 memory/<channel>/YYYY-MM-DD.md

# ❌ 错误：忘记更新
# Session 结束后不记录
```

### 3. 渠道隔离

```bash
# ✅ 正确：使用渠道特定记忆
飞书工作 → memory/feishu/
Yach 个人 → memory/yach/

# ❌ 错误：混合渠道记忆
# 在飞书中写入 Yach 记忆
```

### 4. 通用配置

```bash
# ✅ 正确：系统配置写入 common
多 Agent 系统 → memory/common/
用户偏好 → memory/common/

# ❌ 错误：渠道特定内容写入 common
# 飞书工作项目 → memory/common/
```

### 5. 定期归档

```bash
# ✅ 正确：定期归档每日记忆
每 7 天：将 daily memory 归档到月度文件
每月：审查并更新 MEMORY.md

# ❌ 错误：从不归档
# 每日记忆文件无限增长
```

---

## 附录

### A. 相关文件

| 文件 | 说明 |
|------|------|
| `CHANNEL_ISOLATED_MEMORY.md` | 渠道隔离方案文档 |
| `AGENTS.md` | Agent 行为规范（包含记忆加载要求） |
| `HEARTBEAT.md` | 心跳任务（包含记忆检查任务） |
| `scripts/memory-maintenance.sh` | 记忆维护脚本 |

### B. Git 仓库

- **仓库**: https://github.com/cuiyichao/openclaw-test
- **分支**: master
- **记忆文件位置**: `memory/`

### C. 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-03-04 | 初始版本，实现渠道隔离记忆系统 |

---

_文档创建：2026-03-04_  
_基于 OpenClaw 记忆系统实践总结_
