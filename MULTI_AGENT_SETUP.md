# 多 Agent 系统配置文档

## 架构概览

```
                    用户消息
                       │
                       ▼
              ┌─────────────────┐
              │  main (Router)  │ ← 入口协调器
              │   🤖 默认 Agent  │
              └────────┬────────┘
                       │
          ┌────────────┼────────────┬──────────┐
          ▼            ▼            ▼          ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────┐
    │  Coding  │ │ Writing  │ │ Research │ │ 临时子 Agent │
    │  Agent   │ │  Agent   │ │  Agent   │ │ (sessions_  │
    │  👨‍💻     │ │  ✒️ 文心  │ │  🔍 知更  │ │   spawn)    │
    └──────────┘ └──────────┘ └──────────┘ └─────────────┘
```

## 已配置 Agent

| ID | 名称 | 专长 | 模型 | Emoji |
|----|------|------|------|-------|
| `main` | 默认 Agent | 通用对话 + 路由协调 | qwen3.5-plus | 🤖 |
| `code-generator` | 代码生成专家 | 编程、代码生成 | qwen3-coder-plus | 👨‍💻 |
| `writing-agent` | 文心 | 文档写作、文案创作 | qwen3.5-plus | ✒️ |
| `research-agent` | 知更 | 信息搜集、研究分析 | qwen3.5-plus | 🔍 |

## 路由规则

### 智能意图路由（非关键词匹配）

**核心原则**：main agent 通过**语义理解**判断意图，不是机械匹配关键词。

| 任务类型 | 判断依据 | 负责 Agent |
|---------|---------|-----------|
| 编程开发 | 需要代码实现、技术方案、调试、API 调用 | `code-generator` |
| 写作创作 | 需要产出自然语言文本、文档、文案、润色 | `writing-agent` |
| 研究分析 | 需要搜集外部信息、调研、对比、查证 | `research-agent` |
| 通用对话 | 闲聊、咨询、多步骤复杂任务 | `main` (自动协调) |

### 上下文感知示例

```
场景 1: 之前讨论代码
用户："这个怎么实现？"
→ 理解：编程问题 → code-generator

场景 2: 之前讨论文档
用户："这个怎么实现？"
→ 理解：文档撰写 → writing-agent
```

### 显式指定（优先级最高）

用户可以通过以下方式强制指定 agent：

- **@提及**: `@writing-agent 帮我写文档`
- **命令**: `/writing 帮我写报告`、`/coding 写代码`、`/research 查资料`

## 使用示例

### 1. 语义理解路由（非关键词）

```
用户："这段代码怎么写？"
❌ 错误：看到"写"→ routing-agent
✅ 正确：理解是编程问题 → code-generator
```

### 2. 上下文感知路由

```
[之前讨论产品文档]
用户："帮我优化一下第二段"
→ 理解：文档优化 → writing-agent

[之前讨论 Python 脚本]
用户："帮我优化一下"
→ 理解：代码优化 → code-generator
```

### 3. 单任务 - 代码生成
```
用户：帮我写一个 Python 脚本来处理 Excel 文件

→ main 理解意图 → spawn code-generator
→ code-generator 生成代码
→ main 汇总并返回给用户
```

### 4. 单任务 - 文档写作
```
用户：帮我写一份项目周报

→ main 理解意图 → spawn writing-agent (文心)
→ writing-agent 撰写周报
→ main 汇总并返回给用户
```

### 5. 单任务 - 研究分析
```
用户：帮我查一下最近 AI 行业的融资情况

→ main 理解意图 → spawn research-agent (知更)
→ research-agent 搜索并整理信息
→ main 汇总并返回给用户
```

### 6. 多 Agent 协作
```
用户：帮我做一个竞品分析报告，包括技术对比和文案建议

→ main 分解任务：
   1. spawn research-agent 调研竞品技术
   2. spawn writing-agent 撰写报告文案
→ main 汇总两份结果
→ 整合为完整报告 → 返回用户
```

### 7. 显式指定
```
用户：@writing-agent 帮我写个邀请函
→ 直接路由给 writing-agent（跳过意图判断）

用户：/research 查一下这个公司背景
→ 直接路由给 research-agent
```

### 8. 模糊请求澄清
```
用户："帮我处理一下这个"

→ main 追问："具体想怎么处理？
   - 代码实现？
   - 文档整理？
   - 还是信息调研？"
```

## 配置详情

### Agent 工具权限

```json
{
  "code-generator": {
    "profile": "coding",
    "alsoAllow": ["message", "feishu_doc", "feishu_wiki", "sessions_spawn"]
  },
  "writing-agent": {
    "profile": "messaging",
    "alsoAllow": ["message", "feishu_doc", "feishu_wiki", "web_search", "web_fetch"]
  },
  "research-agent": {
    "profile": "messaging",
    "alsoAllow": ["message", "web_search", "web_fetch", "feishu_doc", "feishu_wiki"]
  }
}
```

### Agent 间协作

- `tools.agentToAgent.enabled`: true
- `tools.agentToAgent.allow`: [code-generator, writing-agent, research-agent]
- `main.subagents.allowAgents`: [code-generator, writing-agent, research-agent]

## 管理命令

```bash
# 查看所有 agent 及绑定
openclaw agents list --bindings

# 查看 agent 状态
openclaw agents status

# 查看子 agent 状态
openclaw subagents list

# 重启 gateway (配置变更后)
openclaw gateway restart
```

## 路由技能

路由逻辑定义在：`skills/router/SKILL.md`

主要功能：
- 意图识别
- 任务分解
- Agent 选择
- 结果汇总

## 下一步优化

- [x] 实现基于语义理解的路由（非关键词匹配）
- [ ] 添加路由日志和可观测性（记录路由决策原因）
- [ ] 支持显式指定 agent（@agent 或 /command）
- [ ] 添加 agent 负载均衡
- [ ] 实现任务队列和优先级
- [ ] 添加路由效果评估和反馈循环

---

_最后更新：2026-03-01_
