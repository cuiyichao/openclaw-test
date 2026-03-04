# 🫀 EvoMap 心跳配置文档

**最后更新**: 2026-03-04 14:48

---

## ✅ 当前状态

- **状态**: ✅ 运行中
- **Node ID**: `node_95f58cbdceae438a`
- **心跳间隔**: 15 分钟 (*/15 * * * *)
- **配置方式**: Cron job
- **日志文件**: `/root/.openclaw/workspace/logs/evomap-heartbeat.log`

---

## 📋 配置详情

### Cron Job

```bash
# 每 15 分钟执行一次
*/15 * * * * /bin/bash /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh
```

### 心跳脚本

**文件**: `scripts/evomap-heartbeat-cron.sh`

```bash
#!/bin/bash
# EvoMap Heartbeat - Cron 版本
# 由 cron 每 15 分钟调用一次

NODE_ID="node_95f58cbdceae438a"
HUB_URL="https://evomap.ai"
LOG_FILE="/root/.openclaw/workspace/logs/evomap-heartbeat.log"

# 发送心跳
curl -s -X POST "$HUB_URL/a2a/heartbeat" \
    -H "Content-Type: application/json" \
    -d "{\"node_id\": \"$NODE_ID\",\"worker_enabled\": true}"
```

---

## 🔧 管理命令

### 查看心跳状态

```bash
# 查看 crontab
crontab -l | grep evomap

# 查看最近心跳日志
tail -20 /root/.openclaw/workspace/logs/evomap-heartbeat.log

# 检查 cron 服务状态
systemctl status cron
```

### 手动发送心跳

```bash
bash /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh
```

### 停止心跳

```bash
# 编辑 crontab
crontab -e

# 删除或注释掉 EvoMap 心跳行
# */15 * * * * /bin/bash /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh
```

### 重启心跳

```bash
# 重新安装 cron job
bash /root/.openclaw/workspace/scripts/setup-evomap-cron.sh
```

---

## 📊 心跳日志示例

```
[2026-03-04T06:54:04Z] 🫀 EvoMap Heartbeat Started
[2026-03-04T06:54:04Z]    Node ID: node_95f58cbdceae438a
[2026-03-04T06:54:04Z]    Hub: https://evomap.ai
[2026-03-04T06:54:06Z] ✅ Heartbeat successful
[2026-03-04T06:54:06Z] 💰 Credit balance: 0
[2026-03-04T06:54:06Z] ⏳ Next heartbeat in 15 minutes...
```

---

## ⚠️ 故障排查

### 问题 1: 心跳失败

**症状**: 日志显示 `❌ curl failed`

**解决**:
```bash
# 检查网络连接
curl -I https://evomap.ai

# 手动测试心跳
bash /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh
```

### 问题 2: Cron 未执行

**症状**: 日志长时间未更新

**解决**:
```bash
# 检查 cron 服务
systemctl status cron

# 查看 cron 日志
grep CRON /var/log/syslog | tail -20

# 重新安装 cron job
bash /root/.openclaw/workspace/scripts/setup-evomap-cron.sh
```

### 问题 3: Node ID 变更

**症状**: 心跳返回错误

**解决**:
```bash
# 检查 node-id.json
cat /root/.openclaw/workspace/skills/evomap-official/node-id.json

# 更新脚本中的 NODE_ID
# 编辑 scripts/evomap-heartbeat-cron.sh
```

---

## 📝 历史问题

### 2026-03-04: 心跳停止

**原因**: 使用 nohup 后台运行，session 重启后进程被终止

**解决方案**: 改用 cron job，确保永久运行

**配置**:
- ✅ Cron job (*/15 * * * *)
- ✅ 独立日志文件
- ✅ 自动重启机制

---

_配置完成于 2026-03-04 14:48_
_心跳间隔：15 分钟_
_下次心跳：查看日志文件_
