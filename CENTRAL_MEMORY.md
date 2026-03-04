# 🧠 中央记忆库 (Central Memory Bank)

**目的**: 解决渠道隔离导致的记忆不同步问题

**规则**: 所有渠道的 session 都应该读写这个文件

---

## 📋 最新记忆 (Latest Memory)

### 2026-03-04 12:46 - 渠道隔离问题

**问题**: 用户反馈"还有渠道隔离"，导致：
- 不同 session 之间记忆不共享
- 昨天的事情想不起来
- 跨渠道记忆丢失

**解决方案**:
1. 使用 `CENTRAL_MEMORY.md` 作为共享记忆
2. 每个 session 开始时读取此文件
3. 每个 session 结束时更新此文件

**状态**: 🟡 处理中

---

### 2026-03-04 11:54 - auto-dev 流程完成

**完成**:
- ✅ 登录页面项目实现
- ✅ Git 推送到 GitHub
- ✅ ZIP 文件发送
- ✅ 文档化到 notes/auto-dev-workflow.md
- ✅ 记录到 .learnings/

**GitHub**: https://github.com/cuiyichao/openclaw-test/tree/login-page

**状态**: ✅ 完成

---

### 2026-03-04 11:12 - Feishu 文件发送流程验证

**成功经验**:
- 文件必须放在 `/root/.openclaw/workspace/`
- 使用 `message(action="send", filePath="...")`
- 不能用 `/tmp/` 路径

**状态**: ✅ 已验证

---

## 📝 待办事项 (Pending Tasks)

- [ ] 检查悬赏任务审核状态（2 个 pending 任务）
- [ ] 查看是否有新的可用任务
- [ ] 修复渠道隔离问题
- [ ] 恢复缺失的记忆文件 (2026-03-02, 2026-03-03)

---

## 🛠️ 系统配置

### Git 配置
```
仓库：https://github.com/cuiyichao/openclaw-test
分支：master, login-page
Token: 已配置在 git credential
```

### Feishu 配置
```
用户 ID: ou_45002b5fc5dab94f1d6ffa620638314b
渠道：Feishu (飞书) DM
文件路径：/root/.openclaw/workspace/
```

### 多 Agent 系统
```
- main (default): 路由协调 + 通用对话
- code-generator: 代码生成 (qwen3-coder-plus)
- writing-agent (文心 ✒️): 文档写作
- research-agent (知更 🔍): 研究分析
```

---

## 📚 重要文档位置

```
AUTO_DEV_WORKFLOW.md        - auto-dev 完整流程指南
notes/auto-dev-workflow.md  - 详细流程文档
.learnings/LEARNINGS.md     - 学习记录
.learnings/ERRORS.md        - 错误日志
memory/2026-03-04.md        - 今日记忆
scripts/memory-maintenance.sh - 记忆维护脚本
```

---

## ⚠️ 注意事项

1. **Token 安全**: GitHub token 不要明文记录
2. **Feishu 文件**: 必须放在工作区目录
3. **Git 推送**: 使用 git credential，不要用 URL 中的 token
4. **渠道隔离**: 所有 session 都要读写 CENTRAL_MEMORY.md

---

_最后更新：2026-03-04 12:46_
_下次 session 开始时请读取此文件_
