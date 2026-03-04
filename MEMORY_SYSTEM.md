# 记忆系统说明

## 📂 记忆结构

```
~/.openclaw/workspace/
├── MEMORY.md              # 长期记忆（仅主 agent 读取）
├── memory/
│   ├── 2026-03-01.md      # 每日日志（仅主 agent 读取）
│   └── YYYY-MM-DD.md
└── agents/
    ├── main/
    │   └── sessions/      # 主 agent 会话历史
    ├── writing-agent/
    │   └── sessions/      # writing-agent 会话历史
    ├── research-agent/
    │   └── sessions/      # research-agent 会话历史
    └── code-generator/
        └── sessions/      # code-generator 会话历史
```

---

## 🔒 记忆隔离规则

### 主 Agent (main)
**可以访问**:
- ✅ `MEMORY.md` - 长期记忆
- ✅ `memory/YYYY-MM-DD.md` - 每日日志
- ✅ `SOUL.md`, `USER.md`, `IDENTITY.md` - 身份配置
- ✅ 自己的工作区文件
- ✅ 自己的会话历史

**职责**:
- 维护 MEMORY.md（添加重要事件、决策、偏好）
- 维护 memory/YYYY-MM-DD.md（每日工作总结）
- 路由决策时参考长期记忆
- 协调子 agent 时不泄露个人隐私信息

### 子 Agent (writing-agent, research-agent, code-generator 等)
**可以访问**:
- ✅ 自己的工作区文件
- ✅ 自己的会话历史
- ✅ 任务相关的技能文件

**不应访问**:
- ❌ `MEMORY.md` - 这是主 agent 的私有记忆
- ❌ `memory/YYYY-MM-DD.md` - 这是主 agent 的工作日志
- ❌ 主 agent 的会话历史
- ❌ 用户的个人隐私信息（除非任务需要）

---

## 🎯 设计原则

### 1. 最小权限原则
子 agent 只获取完成任务所需的最少信息。

**示例**:
```
✅ 正确：spawn writing-agent 时只传递任务描述
❌ 错误：spawn writing-agent 时传递 MEMORY.md 内容
```

### 2. 任务隔离
每个子 agent 有独立的会话历史和 workspace。

**好处**:
- 避免记忆污染
- 便于调试和审计
- 子 agent 可以被 kill 而不影响主 agent

### 3. 结果汇总
子 agent 完成任务后，结果返回给主 agent，由主 agent 决定是否写入长期记忆。

**流程**:
```
主 agent → spawn 子 agent → 执行任务 → 返回结果 → 主 agent 评估 → 可选写入 MEMORY.md
```

---

## 📝 记忆更新指南

### 什么时候更新 MEMORY.md？

**应该写入**:
- 用户明确说"记住这个"
- 重要的配置变更
- 用户的偏好和习惯
- 重大决策和决定
- 学到的关键教训

**不应该写入**:
- 临时性的对话内容
- 子 agent 的中间执行结果
- 可能过期的信息
- 敏感个人信息（密码、密钥等）

### 什么时候创建 memory/YYYY-MM-DD.md？

- 每天第一次对话时检查并创建
- 记录当日完成的主要任务
- 记录遇到的问题和解决方案
- 定期（每周）回顾并提炼到 MEMORY.md

---

## 🔧 技术实现

### 主 agent 读取记忆
```python
# 在会话开始时自动加载
- Read SOUL.md
- Read USER.md
- Read MEMORY.md (仅主 session)
- Read memory/YYYY-MM-DD.md (今日 + 昨日)
```

### 子 agent 隔离
```python
# spawn 子 agent 时
sessions_spawn(
    agentId="writing-agent",
    task="写一份文档",
    # 不传递 memory 相关参数
    # 子 agent 有自己的 workspace 和 sessions
)
```

---

## ⚠️ 安全注意事项

1. **MEMORY.md 包含个人隐私**
   - 不要在群聊中加载
   - 不要传递给子 agent
   - 不要输出到公开渠道

2. **子 agent 可能是其他模型**
   - 不要假设子 agent 有相同的安全策略
   - 只传递任务所需的最少信息
   - 敏感操作在主 agent 完成

3. **会话历史可能包含敏感信息**
   - 定期清理过期的 sessions
   - 不要在日志中暴露 session 内容
   - 使用 trash 而不是 rm 删除文件

---

## 📊 记忆维护计划

### 每日（Heartbeat）
- 检查并更新 memory/YYYY-MM-DD.md
- 记录当日完成的任务

### 每周
- 回顾 memory/*.md 文件
- 提炼重要内容到 MEMORY.md
- 清理过期的每日日志

### 每月
- 审查 MEMORY.md，移除过期信息
- 检查记忆系统是否正常工作
- 优化记忆结构和分类

---

_最后更新：2026-03-01_
