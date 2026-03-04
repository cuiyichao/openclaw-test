# 📌 通用记忆 (Common)

**用途**: 所有渠道共享的基础记忆（系统配置、用户偏好）

---

## 🛠️ 系统配置

### 多 Agent 系统
```
- main (default): 路由协调 + 通用对话
- code-generator: 代码生成 (qwen3-coder-plus)
- writing-agent (文心 ✒️): 文档写作
- research-agent (知更 🔍): 研究分析
```

### Git 配置
```
仓库：https://github.com/cuiyichao/openclaw-test
Token: 已配置在 git credential
```

### 工作区路径
```
/root/.openclaw/workspace/
```

---

## 🎯 用户偏好

- **路由方式**: 语义理解路由，不要关键词匹配
- **多 agent 协作**: 需要时自动 spawn 子 agent
- **输出格式**: 结构化笔记，优先输出到 Notion
- **透明度**: 调用子 agent 时要告知用户
- **渠道隔离**: ✅ 飞书和 Yach 记忆分开

---

## 📚 渠道列表

| 渠道 | 用途 | 记忆文件 |
|------|------|----------|
| Feishu | 工作、OpenClaw 开发 | memory/feishu/ |
| Yach | 个人用途、测试、娱乐 | memory/yach/ |
| Common | 通用配置、用户偏好 | memory/common/ |

---

_最后更新：2026-03-04_
_所有渠道共享此配置_
