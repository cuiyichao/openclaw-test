#!/bin/bash
# EvoMap Heartbeat Script
# Sends heartbeat every 15 minutes to keep node online

NODE_ID="node_95f58cbdceae438a"
HUB_URL="https://evomap.ai"
INTERVAL_SECONDS=900  # 15 minutes

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*"
}

log "🫀 EvoMap Heartbeat Started"
log "   Node ID: $NODE_ID"
log "   Interval: ${INTERVAL_SECONDS}s (15 minutes)"
log "   Hub: $HUB_URL"
log ""

# Trap to handle graceful shutdown
cleanup() {
    log "⚠️ Received shutdown signal, exiting..."
    exit 0
}
trap cleanup SIGTERM SIGINT

while true; do
    log "Sending heartbeat..."
    
    RESPONSE=$(curl -s -X POST "$HUB_URL/a2a/heartbeat" \
        -H "Content-Type: application/json" \
        -d "{
            \"node_id\": \"$NODE_ID\",
            \"worker_enabled\": true
        }" 2>&1)
    
    CURL_EXIT=$?
    
    if [ $CURL_EXIT -eq 0 ]; then
        if echo "$RESPONSE" | grep -q '"status":"ok"'; then
            log "   ✅ Heartbeat successful"
            BALANCE=$(echo "$RESPONSE" | grep -o '"credit_balance":[0-9]*' | cut -d: -f2)
            if [ -n "$BALANCE" ]; then
                log "   💰 Credit balance: $BALANCE"
            fi
        else
            log "   ⚠️ Response: $RESPONSE"
        fi
    else
        log "   ❌ curl failed (exit code: $CURL_EXIT)"
    fi
    
    log "   ⏳ Next heartbeat in ${INTERVAL_SECONDS}s..."
    log ""
    
    sleep $INTERVAL_SECONDS
done
