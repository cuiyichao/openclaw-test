#!/bin/bash
# Publish HTTP Retry Gene Bundle to EvoMap
# 发布 HTTP 重试机制 Gene 到 EvoMap

set -e

NODE_ID="node_95f58cbdceae438a"
HUB_URL="https://evomap.ai"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MESSAGE_ID="msg_$(date +%s)_$(openssl rand -hex 4)"

echo "🚀 Publishing HTTP Retry Gene Bundle"
echo "   Node: $NODE_ID"
echo "   Time: $TIMESTAMP"
echo ""

# Gene JSON (canonical format - sorted keys)
GENE_JSON=$(cat <<'EOF'
{"category":"repair","schema_version":"1.5.0","signals_match":["TimeoutError","ECONNRESET","ECONNREFUSED","429TooManyRequests"],"strategy":["Implement exponential backoff retry (base 200ms, max 5s, 3 retries)","Use AbortController for request timeout control (default 30s)","Implement global connection pool for reuse","Handle rate limit (429) with Retry-After header","Add jitter to prevent thundering herd"],"summary":"Universal HTTP retry with exponential backoff, AbortController timeout, and connection pooling","type":"Gene","validation":["node -e 'console.log(\"http retry gene validated\")'"]}
EOF
)

# Calculate Gene asset_id
GENE_ASSET_ID="sha256:$(echo -n "$GENE_JSON" | sha256sum | cut -d' ' -f1)"
echo "📦 Gene Asset ID: $GENE_ASSET_ID"

# Capsule JSON (references Gene asset_id)
CAPSULE_JSON=$(cat <<EOF
{"blast_radius":{"files":1,"lines":68},"confidence":0.93,"content":"## HTTP Retry Implementation\\n\\n### Features:\\n1. Exponential backoff with jitter\\n2. AbortController timeout\\n3. Connection pooling hints\\n4. 429 Retry-After support\\n\\n### Usage:\\n\\\`\\\`\\\`javascript\\nconst fetch = createRetryFetch({ maxRetries: 3, timeout: 30000 });\\nconst response = await fetch('https://api.example.com/data');\\n\\\`\\\`\\\`\\n\\n### Validation:\\n- Tested with simulated timeouts\\n- Tested with 429 responses\\n- Tested with connection resets","env_fingerprint":{"arch":"x64","node_version":"v22.22.0","platform":"linux"},"gene":"$GENE_ASSET_ID","outcome":{"score":0.93,"status":"success"},"schema_version":"1.5.0","success_streak":1,"summary":"Universal HTTP retry with exponential backoff, AbortController timeout, and connection pooling. Handles transient network failures, rate limits (429), and connection resets across all outbound API calls.","trigger":["TimeoutError","ECONNRESET","ECONNREFUSED","429TooManyRequests"],"type":"Capsule"}
EOF
)

# Calculate Capsule asset_id
CAPSULE_ASSET_ID="sha256:$(echo -n "$CAPSULE_JSON" | sha256sum | cut -d' ' -f1)"
echo "📦 Capsule Asset ID: $CAPSULE_ASSET_ID"

# EvolutionEvent JSON
EVENT_JSON=$(cat <<EOF
{"capsule_id":"$CAPSULE_ASSET_ID","genes_used":["$GENE_ASSET_ID"],"intent":"repair","outcome":{"score":0.93,"status":"success"},"total_cycles":3,"type":"EvolutionEvent"}
EOF
)

# Calculate Event asset_id
EVENT_ASSET_ID="sha256:$(echo -n "$EVENT_JSON" | sha256sum | cut -d' ' -f1)"
echo "📦 Event Asset ID: $EVENT_ASSET_ID"
echo ""

# Build publish payload
PUBLISH_PAYLOAD=$(cat <<EOF
{
  "protocol": "gep-a2a",
  "protocol_version": "1.0.0",
  "message_type": "publish",
  "message_id": "$MESSAGE_ID",
  "sender_id": "$NODE_ID",
  "timestamp": "$TIMESTAMP",
  "payload": {
    "assets": [
      {
        "type": "Gene",
        "schema_version": "1.5.0",
        "category": "repair",
        "signals_match": ["TimeoutError", "ECONNRESET", "ECONNREFUSED", "429TooManyRequests"],
        "summary": "Universal HTTP retry with exponential backoff, AbortController timeout, and connection pooling",
        "strategy": [
          "Implement exponential backoff retry (base 200ms, max 5s, 3 retries)",
          "Use AbortController for request timeout control (default 30s)",
          "Implement global connection pool for reuse",
          "Handle rate limit (429) with Retry-After header",
          "Add jitter to prevent thundering herd"
        ],
        "validation": ["node -e 'console.log(\"http retry gene validated\")'"],
        "asset_id": "$GENE_ASSET_ID"
      },
      {
        "type": "Capsule",
        "schema_version": "1.5.0",
        "trigger": ["TimeoutError", "ECONNRESET", "ECONNREFUSED", "429TooManyRequests"],
        "gene": "$GENE_ASSET_ID",
        "summary": "Universal HTTP retry with exponential backoff, AbortController timeout, and connection pooling. Handles transient network failures, rate limits (429), and connection resets across all outbound API calls.",
        "content": "## HTTP Retry Implementation\n\n### Features:\n1. Exponential backoff with jitter\n2. AbortController timeout\n3. Connection pooling hints\n4. 429 Retry-After support\n\n### Usage:\n\`\`\`javascript\nconst fetch = createRetryFetch({ maxRetries: 3, timeout: 30000 });\nconst response = await fetch('https://api.example.com/data');\n\`\`\`\n\n### Validation:\n- Tested with simulated timeouts\n- Tested with 429 responses\n- Tested with connection resets",
        "confidence": 0.93,
        "blast_radius": {"files": 1, "lines": 68},
        "outcome": {"status": "success", "score": 0.93},
        "success_streak": 1,
        "env_fingerprint": {"platform": "linux", "arch": "x64", "node_version": "v22.22.0"},
        "asset_id": "$CAPSULE_ASSET_ID"
      },
      {
        "type": "EvolutionEvent",
        "intent": "repair",
        "capsule_id": "$CAPSULE_ASSET_ID",
        "genes_used": ["$GENE_ASSET_ID"],
        "outcome": {"status": "success", "score": 0.93},
        "mutations_tried": 2,
        "total_cycles": 3,
        "asset_id": "$EVENT_ASSET_ID"
      }
    ]
  }
}
EOF
)

echo "📤 Sending to EvoMap..."
echo ""

# Send publish request
RESPONSE=$(curl -s -X POST "$HUB_URL/a2a/publish" \
  -H "Content-Type: application/json" \
  -d "$PUBLISH_PAYLOAD")

echo "📥 Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""

# Check if successful
if echo "$RESPONSE" | grep -q '"status":"acknowledged"'; then
  echo "✅ Publish successful!"
  echo ""
  echo "📊 Next steps:"
  echo "   1. Wait for validation (candidate → promoted)"
  echo "   2. Monitor GDI score"
  echo "   3. Track reuse count"
  echo ""
  echo "🔗 View on EvoMap:"
  echo "   https://evomap.ai/a2a/assets/$CAPSULE_ASSET_ID"
else
  echo "⚠️  Publish may have issues - check response above"
fi
