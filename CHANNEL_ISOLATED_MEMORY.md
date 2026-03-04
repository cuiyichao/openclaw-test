# 📌 渠道隔离记忆系统

**目的**: 保持不同渠道（飞书/Yach/其他）的记忆独立，互不干扰

**创建时间**: 2026-03-04

---

## 📋 渠道记忆结构

```
memory/
├── feishu/
│   ├── 2026-03-04.md          # 飞书渠道每日记忆
│   └── CENTRAL_MEMORY.md      # 飞书渠道中央记忆
├── yach/
│   ├── 2026-03-04.md          # Yach 渠道每日记忆
│   └── CENTRAL_MEMORY.md      # Yach 渠道中央记忆
└── common/
    ├── 2026-03-04.md          # 通用记忆（所有渠道共享）
    └── CENTRAL_MEMORY.md      # 通用中央记忆
```

---

## 🎯 渠道用途隔离

### 飞书 (Feishu)
**用途**: 工作相关、正式沟通、文档协作
**记忆内容**:
- 工作项目进展
- 文档编写记录
- 正式会议纪要

### Yach
**用途**: 个人用途、测试、娱乐
**记忆内容**:
- 个人项目
- 测试功能
- 娱乐内容

### 通用 (Common)
**用途**: 所有渠道共享的基础记忆
**记忆内容**:
- 系统配置
- 用户偏好
- 重要决策

---

## 📝 记忆文件命名规范

### 渠道特定记忆
```
memory/<channel>/YYYY-MM-DD.md
memory/<channel>/CENTRAL_MEMORY.md
```

### 渠道代码
- `feishu` - 飞书
- `yach` - Yach
- `discord` - Discord
- `telegram` - Telegram
- `common` - 通用（所有渠道共享）

---

## 🔄 记忆加载规则

### Session 开始时

```bash
# 1. 确定当前渠道
CHANNEL="feishu"  # 或 "yach" 或其他

# 2. 读取渠道特定记忆
read memory/$CHANNEL/CENTRAL_MEMORY.md
read memory/$CHANNEL/YYYY-MM-DD.md

# 3. 读取通用记忆
read memory/common/CENTRAL_MEMORY.md
```

### Session 结束时

```bash
# 1. 更新渠道特定记忆
更新 memory/$CHANNEL/CENTRAL_MEMORY.md
更新 memory/$CHANNEL/YYYY-MM-DD.md

# 2. 重要决策同步到通用记忆（可选）
如果决策影响所有渠道 → 更新 memory/common/CENTRAL_MEMORY.md
```

---

## 🛠️ 自动化工具

### memory-init-channel.sh

```bash
#!/bin/bash
# 初始化渠道记忆目录

CHANNEL="$1"

if [ -z "$CHANNEL" ]; then
    echo "用法：$0 <channel-name>"
    exit 1
fi

mkdir -p "memory/$CHANNEL"

# 创建渠道中央记忆模板
cat > "memory/$CHANNEL/CENTRAL_MEMORY.md" << EOF
# 📌 $CHANNEL 渠道记忆

**用途**: (待填写)

---

## 📋 最新记忆

### YYYY-MM-DD HH:MM - 记忆标题

**状态**: 🟡 处理中

---

## 📝 待办事项

- [ ] 待办事项 1
- [ ] 待办事项 2

---

## 🛠️ 渠道配置

\`\`\`
渠道：$CHANNEL
用户 ID: (待填写)
用途：(待填写)
\`\`\`

---

_最后更新：$(date +%Y-%m-%d)_
EOF

echo "✅ 已创建 $CHANNEL 渠道记忆目录"
```

### memory-maintenance.sh (更新版)

```bash
#!/bin/bash
# 自动检查记忆系统状态

CHANNEL="${1:-feishu}"  # 默认飞书
TODAY=$(date +%Y-%m-%d)

echo "🧠 Memory Maintenance - $CHANNEL - $TODAY"
echo "================================"

# 检查渠道记忆目录
if [ ! -d "memory/$CHANNEL" ]; then
    echo "⚠️  渠道记忆目录不存在：memory/$CHANNEL"
    echo "💡 运行：bash scripts/memory-init-channel.sh $CHANNEL"
else
    echo "✅ 渠道记忆目录存在：memory/$CHANNEL"
fi

# 检查今日记忆文件
if [ ! -f "memory/$CHANNEL/$TODAY.md" ]; then
    echo "⚠️  今日记忆文件缺失：memory/$CHANNEL/$TODAY.md"
else
    echo "✅ 今日记忆文件存在"
fi

# 检查中央记忆
if [ ! -f "memory/$CHANNEL/CENTRAL_MEMORY.md" ]; then
    echo "⚠️  中央记忆文件缺失：memory/$CHANNEL/CENTRAL_MEMORY.md"
else
    echo "✅ 中央记忆文件存在"
fi
```

---

## 📊 实际示例

### 示例 1: 飞书渠道工作项目

**飞书 Session**:
```
用户：帮我写个工作报告
AI: 好的，开始编写...

更新 memory/feishu/CENTRAL_MEMORY.md:
- 2026-03-04 10:00: 开始工作报告
- 项目：Q1 工作总结
```

**Yach Session** (同时):
```
用户：帮我写个游戏脚本
AI: 读取 memory/yach/CENTRAL_MEMORY.md
AI: 好的，开始编写游戏脚本...

（不会看到飞书的工作报告记录）
```

### 示例 2: 渠道间隔离

**飞书**:
```
memory/feishu/
├── 2026-03-04.md (工作：工作报告、会议记录)
└── CENTRAL_MEMORY.md (工作项目进展)
```

**Yach**:
```
memory/yach/
├── 2026-03-04.md (个人：游戏脚本、测试功能)
└── CENTRAL_MEMORY.md (个人项目)
```

**完全隔离，互不干扰！** ✅

---

## ⚠️ 注意事项

### 渠道识别

每次 session 开始时需要确定渠道：
```bash
# 从环境变量或配置中读取
CHANNEL="feishu"  # 或 "yach"
```

### 通用记忆的使用

**何时使用 `memory/common/`**:
- 系统配置变更（影响所有渠道）
- 用户偏好（如时区、语言）
- 重要决策（影响所有渠道）

**何时不使用**:
- 渠道特定的工作内容
- 渠道特定的项目
- 临时性任务

### 记忆归档

定期（每周）将渠道记忆归档：
```bash
# 飞书渠道归档
cp memory/feishu/2026-03-04.md memory/feishu/archive/2026-03.md

# Yach 渠道归档
cp memory/yach/2026-03-04.md memory/yach/archive/2026-03.md
```

---

## 🚀 下一步

- [ ] 创建 memory/feishu/ 目录和初始文件
- [ ] 创建 memory/yach/ 目录和初始文件
- [ ] 更新 AGENTS.md 支持渠道隔离
- [ ] 更新 HEARTBEAT.md 添加渠道记忆检查
- [ ] 修改 memory-maintenance.sh 支持多渠道

---

_此文档基于 2026-03-04 用户需求创建_
_渠道隔离：飞书 ≠ Yach_
