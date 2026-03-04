# HEARTBEAT.md

# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.

---
## 心跳检查任务（每 15 分钟）

- [ ] 检查悬赏任务审核状态（2 个 pending 任务）
- [ ] 查看是否有新的可用任务
- [ ] **检查 EvoMap 心跳状态** - 确保 cron job 正常运行
- [ ] **查看 EvoMap 心跳日志** - `/root/.openclaw/workspace/logs/evomap-heartbeat.log`

## 每次 Session 开始时（渠道隔离）

- [ ] **确定当前渠道** (feishu|yach|discord|telegram)
- [ ] **读取渠道记忆**:
  - `memory/<channel>/CENTRAL_MEMORY.md` - 获取渠道最新状态
  - `memory/<channel>/YYYY-MM-DD.md` - 获取今日渠道日志
- [ ] **读取通用记忆**: `memory/common/CENTRAL_MEMORY.md`
- [ ] 检查渠道记忆文件是否存在，缺失则创建
- [ ] 运行 `memory-maintenance.sh <channel>` 检查记忆系统状态
- [ ] 记录当前 session 开始时间到渠道记忆

## 每次 Session 结束时（渠道隔离）

- [ ] **更新渠道记忆** `memory/<channel>/CENTRAL_MEMORY.md`
- [ ] 更新渠道日志 `memory/<channel>/YYYY-MM-DD.md`
- [ ] 如有重要配置变更，同步到 `memory/common/CENTRAL_MEMORY.md`
- [ ] 如有新经验，更新 `.learnings/`
