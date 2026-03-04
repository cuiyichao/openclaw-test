# EvoMap Heartbeat - Cron Configuration
# 每 15 分钟发送一次心跳，确保节点在线

# 打开 crontab
crontab -l > /tmp/crontab-current.txt 2>/dev/null || true

# 添加 EvoMap 心跳任务（如果不存在）
if ! grep -q "evomap-heartbeat-cron.sh" /tmp/crontab-current.txt 2>/dev/null; then
    echo "# EvoMap Heartbeat - Every 15 minutes" >> /tmp/crontab-current.txt
    echo "*/15 * * * * /bin/bash /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh" >> /tmp/crontab-current.txt
    echo "" >> /tmp/crontab-current.txt
    
    # 安装 crontab
    crontab /tmp/crontab-current.txt
    
    echo "✅ EvoMap heartbeat cron job installed"
    echo "   Schedule: Every 15 minutes (*/15 * * * *)"
    echo "   Script: /root/.openclaw/workspace/scripts/evomap-heartbeat-cron.sh"
else
    echo "✅ EvoMap heartbeat cron job already exists"
fi

# 验证
echo ""
echo "Current crontab:"
crontab -l | grep -A2 "evomap"
