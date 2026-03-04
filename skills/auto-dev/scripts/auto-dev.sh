#!/bin/bash
set -e
TASK="$1"
BASE_DIR="${2:-$HOME/.mcporter/projects}"
MAX_FIX="${3:-2}"
INPUT_DOC="${4:-}"  # 可选：需求文档路径
REMOTE="${5:-}"

[ -z "$TASK" ] && echo "用法：auto-dev \"任务\" [项目目录] [最大轮数] [需求文档路径] [远程地址]" && exit 1

TS=$(date +%Y%m%d-%H%M%S)
PROJECT="$BASE_DIR/project-$TS"
mkdir -p "$PROJECT"
cd "$PROJECT"
git init -q && git config user.email "autodev@local" && git config user.name "AutoDev"
echo "# $TASK" > README.md && git add . && git commit -q -m "init"

echo "╔══════════════════════════════════════════╗"
echo "║  🚀 Auto-Dev Pipeline                   ║"
echo "╚══════════════════════════════════════════╝"
echo "📋 任务：$TASK"
echo "📁 项目：$PROJECT"
echo ""

# ── [1] 准备阶段 ──────────────────────────────────────
echo "📥 [1/5] 准备阶段..."
if [ -n "$INPUT_DOC" ] && [ -f "$INPUT_DOC" ]; then
  echo "  ✅ 需求文档：$INPUT_DOC"
  cp "$INPUT_DOC" "$PROJECT/requirements.md"
else
  echo "  ℹ️  无外部文档，使用任务描述作为需求"
  echo "# $TASK" > "$PROJECT/requirements.md"
fi
echo ""

# ── [2] 需求文档 → 技术文档（Claude Code）────────────
echo "🔄 [2/5] Claude Code → 需求转技术文档..."
if [ -f "$INPUT_DOC" ] && [ -n "$INPUT_DOC" ]; then
  # 有需求文档，进行转换
  climux run "阅读 requirements.md 需求文档，生成完整的技术文档保存为 TECH_DOC.md，包含：1.功能描述 2.技术方案 3.文件结构 4.API 设计 5.数据模型" \
    --provider claude-code --mode task 2>&1 | tail -3
else
  # 无需求文档，直接生成
  climux run "根据任务描述生成完整的技术文档保存为 TECH_DOC.md，包含：1.功能描述 2.技术方案 3.文件结构 4.API 设计 5.数据模型：$TASK" \
    --provider claude-code --mode task 2>&1 | tail -3
fi
echo "  ✅ 技术文档已生成：TECH_DOC.md"
echo ""

# ── [3] Claude Code → 代码实现 ───────────────────────
echo "💻 [3/5] Claude Code → 代码实现..."
climux run "根据 TECH_DOC.md 实现完整代码，创建所有必要的文件" \
  --provider claude-code --mode task 2>&1 | tail -3
git add -A && git commit -q -m "feat: implementation" 2>/dev/null || true
echo "  ✅ 代码已实现"
echo ""

# ── [4] Codex 审查 → Claude Code 修复（循环）─────────
echo "🔁 [4/5] Codex 审查 → Claude Code 修复..."
ROUND=0
while [ $ROUND -lt $MAX_FIX ]; do
  ROUND=$((ROUND+1))
  echo "  🔍 轮次 $ROUND: Codex 审查..."

  REVIEW=$(codex exec --sandbox danger-full-access \
    "审查当前目录所有代码文件，列出：1.bug 2.安全漏洞 3.性能问题 4.代码质量问题。无问题回复：LGTM" \
    2>&1 | grep -v "^thinking\|^tokens\|^codex$\|^deprecated\|^Set \`web\|^mcp startup" | head -40)

  REVIEW_BRIEF=$(echo "$REVIEW" | tail -20)
  echo "     📋 ${REVIEW_BRIEF:0:80}..."

  if echo "$REVIEW" | grep -qi "^lgtm\|无问题\|no issues\|looks good"; then
    echo "     ✅ Codex: 审查通过"
    break
  fi

  [ $ROUND -ge $MAX_FIX ] && echo "     ⚠️  达到最大修复轮数 ($MAX_FIX)" && break

  echo "     🔧 Claude Code 修复..."
  climux run "根据以下审查结果修复代码：
$REVIEW_BRIEF" \
    --provider claude-code --mode task 2>&1 | tail -3
  git add -A && git commit -q -m "fix: review round $ROUND" 2>/dev/null || true
done
echo ""

# ── [5] 提交 + 推送 ──────────────────────────────────
echo "📦 [5/5] 提交代码..."
git add -A
git diff --cached --quiet || git commit -q -m "feat: $TASK" 2>/dev/null || true

if [ -n "$REMOTE" ]; then
  echo "🌐 推送到远程..."
  git remote add origin "$REMOTE" 2>/dev/null || git remote set-url origin "$REMOTE"
  git branch -M main 2>/dev/null || true
  git push -u origin main 2>&1 && echo "  ✅ 已推送到 $REMOTE" || echo "  ⚠️  推送失败"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  🎉 完成！                               ║"
echo "╚══════════════════════════════════════════╝"
echo "📁 路径：$PROJECT"
echo "📄 文件:"
find "$PROJECT" -type f -not -path '*/.git/*' -not -path '*/__pycache__/*' \
  | sed "s|$PROJECT/||" | grep -v "^$" | sort | sed 's/^/    /'
echo ""
echo "📜 提交记录:"
git log --oneline | head -5 | sed 's/^/    /'
echo ""
if [ -n "$REMOTE" ]; then
  echo "🔗 远程：$REMOTE"
else
  echo "💡 推送：cd $PROJECT && git remote add origin <URL> && git push -u origin"
fi
