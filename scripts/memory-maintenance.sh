#!/bin/bash
# memory-maintenance.sh - 自动维护记忆系统

set -e

WORKSPACE="/root/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
TODAY=$(date +%Y-%m-%d)
TODAY_FILE="$MEMORY_DIR/$TODAY.md"
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
YESTERDAY_FILE="$MEMORY_DIR/$YESTERDAY.md"

echo "🧠 Memory Maintenance - $TODAY"
echo "================================"

# 1. 检查并创建今日记忆文件
if [ ! -f "$TODAY_FILE" ]; then
    echo "📝 创建今日记忆文件：$TODAY_FILE"
    cat > "$TODAY_FILE" << 'EOF'
# YYYY-MM-DD 工作日志

## 📋 今日完成

### 任务 1
- [ ] 待办事项

### 任务 2
- [ ] 待办事项

## 📝 学到的东西

1. 学到的经验 1
2. 学到的经验 2

## 🔧 配置变更

- 配置文件更新

## ⚠️ 发现的问题

### 问题描述
- 问题详情

### 解决方案
- 解决方法

## 💡 想法

- 新的想法或建议

---

_今日总结：待填写_
EOF
    echo "✅ 已创建今日记忆文件"
else
    echo "✅ 今日记忆文件已存在"
fi

# 2. 检查并创建昨日记忆文件（如果缺失）
if [ ! -f "$YESTERDAY_FILE" ]; then
    echo "⚠️  昨日记忆文件缺失：$YESTERDAY_FILE"
    echo "💡 建议手动创建或从会话历史中恢复"
else
    echo "✅ 昨日记忆文件已存在"
fi

# 3. 检查最近 7 天的记忆文件
echo ""
echo "📊 最近 7 天记忆文件状态："
for i in {0..6}; do
    DATE=$(date -d "$i days ago" +%Y-%m-%d)
    FILE="$MEMORY_DIR/$DATE.md"
    if [ -f "$FILE" ]; then
        SIZE=$(wc -c < "$FILE")
        echo "  ✅ $DATE ($SIZE bytes)"
    else
        echo "  ❌ $DATE (缺失)"
    fi
done

# 4. 检查 MEMORY.md 最后更新时间
echo ""
echo "📋 MEMORY.md 状态："
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    LAST_MODIFIED=$(stat -c %y "$WORKSPACE/MEMORY.md" | cut -d' ' -f1)
    echo "  最后更新：$LAST_MODIFIED"
    
    # 如果超过 7 天未更新，提醒归档
    DAYS_OLD=$(( ($(date +%s) - $(stat -c %Y "$WORKSPACE/MEMORY.md")) / 86400 ))
    if [ $DAYS_OLD -gt 7 ]; then
        echo "  ⚠️  已 $DAYS_OLD 天未更新，建议归档 daily memory"
    fi
fi

# 5. 统计 .learnings/ 待处理项目
echo ""
echo "📚 .learnings/ 状态："
if [ -d "$WORKSPACE/.learnings" ]; then
    PENDING_LEARNINGS=$(grep -c "Status\*\*: pending" "$WORKSPACE/.learnings/LEARNINGS.md" 2>/dev/null || echo "0")
    PENDING_ERRORS=$(grep -c "Status\*\*: pending" "$WORKSPACE/.learnings/ERRORS.md" 2>/dev/null || echo "0")
    PENDING_FEATURES=$(grep -c "Status\*\*: pending" "$WORKSPACE/.learnings/FEATURE_REQUESTS.md" 2>/dev/null || echo "0")
    
    echo "  待处理学习：$PENDING_LEARNINGS"
    echo "  待处理错误：$PENDING_ERRORS"
    echo "  待处理功能：$PENDING_FEATURES"
fi

echo ""
echo "✅ Memory Maintenance 完成"
