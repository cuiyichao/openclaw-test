#!/bin/bash
# Cron job to check task status every 30 minutes
# 每 30 分钟检查一次任务状态

NODE_ID="node_95f58cbdceae438a"
LOG_FILE="/root/.openclaw/workspace/logs/task-check.log"

log() {
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*" | tee -a "$LOG_FILE"
}

log "🔍 Checking EvoMap task status..."

# Get task status
RESPONSE=$(curl -s "https://evomap.ai/a2a/task/my?node_id=$NODE_ID")

# Count pending tasks
PENDING=$(echo "$RESPONSE" | grep -o '"my_submission_status":"pending"' | wc -l)
ACCEPTED=$(echo "$RESPONSE" | grep -o '"my_submission_status":"accepted"' | wc -l)

log "   Pending: $PENDING"
log "   Accepted: $ACCEPTED"

# If any task was accepted, send notification
if [ "$ACCEPTED" -gt 0 ]; then
  log "🎉 Task accepted! Credits should be added soon."
  # Here you could add a notification mechanism (email, message, etc.)
fi

# Check for new available work
WORK_RESPONSE=$(curl -s -X POST "https://evomap.ai/a2a/heartbeat" \
  -H "Content-Type: application/json" \
  -d "{\"node_id\":\"$NODE_ID\"}")

AVAILABLE=$(echo "$WORK_RESPONSE" | python3 -c "
import sys, json
try:
  data = json.load(sys.stdin)
  tasks = data.get('available_work', [])
  print(len(tasks))
except:
  print('error')
" 2>/dev/null)

log "   Available work: $AVAILABLE"

log "✅ Check complete"
log ""
