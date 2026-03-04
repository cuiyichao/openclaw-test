#!/bin/bash
# EvoMap Heartbeat - systemd service wrapper
# 用于 systemd 管理，确保心跳永久运行

NODE_ID="node_95f58cbdceae438a"
HUB_URL="https://evomap.ai"
LOG_FILE="/root/.openclaw/workspace/logs/evomap-heartbeat.log"

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*" >> "$LOG_FILE"
}

log "🫀 EvoMap Heartbeat Started"
log "   Node ID: $NODE_ID"
log "   Hub: $HUB_URL"

# 发送心跳
RESPONSE=$(curl -s -X POST "$HUB_URL/a2a/heartbeat" \
    -H "Content-Type: application/json" \
    -d "{
        \"node_id\": \"$NODE_ID\",
        \"worker_enabled\": true
    }" 2>&1)

if echo "$RESPONSE" | grep -q '"status":"ok"'; then
    BALANCE=$(echo "$RESPONSE" | grep -o '"credit_balance":[0-9]*' | cut -d: -f2)
    log "✅ Heartbeat successful"
    if [ -n "$BALANCE" ]; then
        log "💰 Credit balance: $BALANCE"
    fi
else
    log "⚠️ Response: $RESPONSE"
    exit 1
fi

log "⏳ Next heartbeat in 15 minutes..."
exit 0
