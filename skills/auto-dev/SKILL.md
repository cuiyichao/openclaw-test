# auto-dev - 自动化开发工作流

**一键完成：需求 → 技术文档 → 代码实现 → 代码审查 → 修复 → Git 提交**

---

## 🎯 工作流

```
用户需求
    ↓
1. 生成技术文档 (Claude Code)
    ↓
2. 创建 Git Worktree
    ↓
3. 实现代码 (Claude Code)
    ↓
4. 代码审查 (Codex)
    ↓
5. 有问题？→ 修复 (Claude Code) → 回到步骤 4
    ↓
6. 提交代码 → 返回 Git 地址
```

---

## 📋 使用方式

### 基础用法
```bash
auto-dev "实现一个用户登录功能"
```

### 带选项
```bash
# 指定项目目录
auto-dev "添加支付功能" --project ~/projects/myapp

# 指定分支
auto-dev "修复登录 bug" --branch main

# 跳过审查（快速模式）
auto-dev "小改动" --no-review
```

---

## 🔧 实现脚本

```bash
#!/bin/bash
# ~/.openclaw/workspace/skills/auto-dev/scripts/auto-dev.sh

set -e

# 参数解析
TASK="$1"
PROJECT="${2:-.}"
BRANCH="${3:-main}"
MAX_REVIEW_ITERATIONS=3

echo "🚀 开始自动化开发流程"
echo "任务：$TASK"
echo "项目：$PROJECT"
echo ""

# 步骤 1: 生成技术文档
echo "📝 步骤 1/6: 生成技术文档..."
TECH_DOC=$(mcporter call climux.run_task \
  task:"为以下需求生成技术文档，包括：1.功能描述 2.技术方案 3.文件结构 4.关键实现点：$TASK" \
  provider:"claude-code" \
  mode:"task" \
  --timeout 120000 | jq -r '.output')

echo "技术文档已生成"
echo "$TECH_DOC" > "$PROJECT/TECH_DOC.md"
echo ""

# 步骤 2: 创建 Git Worktree
echo "🌿 步骤 2/6: 创建 Git Worktree..."
WORKTREE_NAME="feature-$(date +%Y%m%d-%H%M%S)"
cd "$PROJECT"
git worktree add -b "$WORKTREE_NAME" "/tmp/climux-wt-$WORKTREE_NAME"
WORKTREE_PATH="/tmp/climux-wt-$WORKTREE_NAME"
echo "Worktree: $WORKTREE_NAME"
echo ""

# 步骤 3: 实现代码
echo "💻 步骤 3/6: 实现代码..."
cd "$WORKTREE_PATH"
mcporter call climux.run_task \
  task:"根据以下技术文档实现代码：$TECH_DOC" \
  provider:"claude-code" \
  mode:"task" \
  --timeout 300000

echo "代码实现完成"
echo ""

# 步骤 4-5: 代码审查 + 修复循环
echo "🔍 步骤 4/6: 代码审查..."
REVIEW_ITERATION=0
NEEDS_FIX=true

while [ "$NEEDS_FIX" = true ] && [ $REVIEW_ITERATION -lt $MAX_REVIEW_ITERATIONS ]; do
  REVIEW_ITERATION=$((REVIEW_ITERATION + 1))
  echo "审查轮次：$REVIEW_ITERATION"
  
  # 审查代码
  REVIEW_RESULT=$(mcporter call climux.run_task \
    task:"审查当前项目的代码，找出：1.代码质量问题 2.潜在 bug 3.性能问题 4.安全漏洞。如果没有问题，回复'代码审查通过'" \
    provider:"codex" \
    mode:"task" \
    --timeout 180000 | jq -r '.output')
  
  echo "审查结果：$REVIEW_RESULT"
  
  # 检查是否需要修复
  if echo "$REVIEW_RESULT" | grep -q "通过\|没有问题\|looks good"; then
    NEEDS_FIX=false
    echo "✅ 代码审查通过"
  else
    if [ $REVIEW_ITERATION -ge $MAX_REVIEW_ITERATIONS ]; then
      echo "⚠️ 达到最大审查次数，跳过修复"
      NEEDS_FIX=false
    else
      echo "🔧 步骤 5/6: 修复问题 (第 $REVIEW_ITERATION 轮)..."
      mcporter call climux.run_task \
        task:"根据以下审查结果修复代码：$REVIEW_RESULT" \
        provider:"claude-code" \
        mode:"task" \
        --timeout 180000
    fi
  fi
done

echo ""

# 步骤 6: 提交代码
echo "📦 步骤 6/6: 提交代码..."
cd "$WORKTREE_PATH"
git add -A
git commit -m "feat: $TASK

技术文档：
$TECH_DOC

审查轮次：$REVIEW_ITERATION"

# 推送到远程（如果配置了）
if git remote -v | grep -q origin; then
  git push -u origin "$WORKTREE_NAME"
  echo "✅ 已推送到远程"
fi

echo ""
echo "🎉 完成！"
echo "分支：$WORKTREE_NAME"
echo "路径：$WORKTREE_PATH"
echo "Git 命令：cd $WORKTREE_PATH && git log -1"
```

---

## 🤖 OpenClaw Skill 配置

```yaml
# ~/.openclaw/workspace/skills/auto-dev/skill.yaml
name: auto-dev
description: 自动化开发工作流
version: 1.0.0

triggers:
  - "auto-dev"
  - "自动化开发"
  - "一键开发"
  - "生成代码"

parameters:
  - name: task
    type: string
    required: true
    description: 开发任务描述
  
  - name: project
    type: string
    required: false
    default: "."
    description: 项目目录
  
  - name: branch
    type: string
    required: false
    default: "main"
    description: 目标分支

steps:
  - name: generate_tech_doc
    tool: climux.run_task
    params:
      task: "为需求生成技术文档：{{task}}"
      provider: claude-code
      mode: task
  
  - name: create_worktree
    tool: exec
    command: "git worktree add -b feature-{{timestamp}} {{worktree_path}}"
  
  - name: implement
    tool: climux.run_task
    params:
      task: "根据技术文档实现代码：{{tech_doc}}"
      provider: claude-code
      mode: task
  
  - name: review
    tool: climux.run_task
    params:
      task: "审查代码质量"
      provider: codex
      mode: task
  
  - name: fix_loop
    condition: "review.has_issues"
    max_iterations: 3
    tool: climux.run_task
    params:
      task: "修复审查问题：{{review.result}}"
      provider: claude-code
      mode: task
  
  - name: commit
    tool: exec
    command: "git add -A && git commit -m '{{task}}'"
  
  - name: output
    tool: message
    params:
      message: |
        🎉 开发完成！
        
        📁 分支：{{worktree_name}}
        📍 路径：{{worktree_path}}
        🔗 Git: {{git_url}}
```

---

## 📊 输出示例

```
🚀 开始自动化开发流程
任务：实现用户登录功能

📝 步骤 1/6: 生成技术文档...
✅ 技术文档已生成

🌿 步骤 2/6: 创建 Git Worktree...
✅ Worktree: feature-20260303-175000

💻 步骤 3/6: 实现代码...
✅ 代码实现完成

🔍 步骤 4/6: 代码审查...
⚠️ 发现 2 个问题，开始修复...
🔧 步骤 5/6: 修复问题 (第 1 轮)...
✅ 修复完成

🔍 再次审查...
✅ 代码审查通过

📦 步骤 6/6: 提交代码...
✅ 已提交

🎉 完成！
分支：feature-20260303-175000
路径：/tmp/climux-wt-feature-20260303-175000
Git 地址：https://github.com/yourname/repo/tree/feature-20260303-175000
```

---

## 🔐 安全配置

- 最大审查轮次：3 次（避免无限循环）
- 超时时间：实现 5 分钟，审查 3 分钟，修复 3 分钟
- Worktree 隔离：每个任务在独立 worktree 中开发
- 人工确认：推送前可配置需要人工确认

---

## 🎯 下一步

1. 创建脚本文件
2. 测试完整流程
3. 集成到 OpenClaw
