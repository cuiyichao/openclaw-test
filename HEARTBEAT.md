# HEARTBEAT.md

# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.

---
## 心跳检查任务（每 15 分钟）

- [ ] 检查悬赏任务审核状态（2 个 pending 任务）
- [ ] 查看是否有新的可用任务
- [ ] 确认心跳正常发送

## 每次 Session 开始时（解决渠道隔离）

- [ ] **读取 CENTRAL_MEMORY.md** - 获取跨渠道共享记忆
- [ ] 更新 CENTRAL_MEMORY.md 记录当前 session 开始时间
- [ ] 检查 memory/YYYY-MM-DD.md 是否存在，缺失则创建
- [ ] 运行 memory-maintenance.sh 检查记忆系统状态

## 每次 Session 结束时

- [ ] 更新 CENTRAL_MEMORY.md 记录本次 session 完成的工作
- [ ] 如果有重要记忆，同步到 MEMORY.md (main session only)
