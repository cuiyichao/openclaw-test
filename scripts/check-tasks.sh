#!/bin/bash
# Check EvoMap Task Status Script
# 检查悬赏任务审核状态

NODE_ID="node_95f58cbdceae438a"
HUB_URL="https://evomap.ai"

echo "🔍 检查 EvoMap 任务状态"
echo "   Node ID: $NODE_ID"
echo "   时间：$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# 获取任务列表
RESPONSE=$(curl -s "$HUB_URL/a2a/task/my?node_id=$NODE_ID")

# 解析任务状态
PENDING=$(echo "$RESPONSE" | grep -o '"my_submission_status":"pending"' | wc -l)
OPEN=$(echo "$RESPONSE" | grep -o '"status":"open"' | wc -l)

echo "📊 任务统计:"
echo "   待审核 (pending): $PENDING"
echo "   进行中 (open): $OPEN"
echo ""

# 显示任务详情
echo "📋 任务详情:"
echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = data.get('tasks', [])
    if not tasks:
        print('   暂无任务')
    else:
        for i, task in enumerate(tasks, 1):
            title = task.get('title', 'Untitled')[:50]
            status = task.get('status', 'unknown')
            submission_status = task.get('my_submission_status', 'N/A')
            asset = task.get('my_submission_asset', '')[:20] + '...' if task.get('my_submission_asset') else 'N/A'
            print(f'   {i}. {title}...')
            print(f'      状态：{status} | 审核：{submission_status}')
            print(f'      资产：{asset}')
            print()
except Exception as e:
    print(f'   解析失败：{e}')
"

# 检查是否有新任务
echo "🔍 检查可用任务:"
WORK_RESPONSE=$(curl -s -X POST "$HUB_URL/a2a/heartbeat" \
    -H "Content-Type: application/json" \
    -d "{\"node_id\":\"$NODE_ID\"}")

AVAILABLE=$(echo "$WORK_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = data.get('available_work', [])
    print(f'   可用任务：{len(tasks)}')
    bounties = [t for t in tasks if t.get('bountyAmount') and t.get('bountyAmount') > 0]
    print(f'   有奖金的任务：{len(bounties)}')
except:
    print('   无法获取')
" 2>/dev/null)

echo "$AVAILABLE"
echo ""
