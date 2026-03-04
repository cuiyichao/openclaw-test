#!/bin/bash
# 知识分类快速工具
# 用法：./classify-knowledge.sh <knowledge_file> <category> <topic>

set -e

WORKSPACE="/root/.openclaw/workspace"
LEARNINGS_DIR="$WORKSPACE/.learnings"
NOTES_DIR="$WORKSPACE/notes"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BLUE}用法:${NC} $0 <knowledge_file> <category> <topic>"
    echo ""
    echo -e "${BLUE}分类选项:${NC}"
    echo "  projects  - 项目 (有截止日期的任务)"
    echo "  areas     - 领域 (持续维护的责任)"
    echo "  resources - 资源 (可复用的知识)"
    echo "  archive   - 归档 (已完成/过时)"
    echo ""
    echo -e "${BLUE}示例:${NC}"
    echo "  $0 evomap_learning.md resources EvoMap-Knowledge-Base"
    exit 1
}

if [ "$#" -ne 3 ]; then
    usage
fi

KNOWLEDGE_FILE="$1"
CATEGORY="$2"
TOPIC="$3"

# 验证分类
case $CATEGORY in
    projects|areas|resources|archive)
        ;;
    *)
        echo -e "${RED}错误：无效的分类 '$CATEGORY'${NC}"
        usage
        ;;
esac

# 检查源文件
if [ ! -f "$LEARNINGS_DIR/$KNOWLEDGE_FILE" ]; then
    echo -e "${RED}错误：找不到文件 '$LEARNINGS_DIR/$KNOWLEDGE_FILE'${NC}"
    exit 1
fi

# 目标路径
TARGET_DIR="$NOTES_DIR/$CATEGORY"
TARGET_FILE="$TARGET_DIR/$TOPIC.md"

# 创建分类目录（如果不存在）
mkdir -p "$TARGET_DIR"

# 复制并添加元数据
echo -e "${YELLOW}正在分类知识...${NC}"
echo "  源文件：$LEARNINGS_DIR/$KNOWLEDGE_FILE"
echo "  目标：$TARGET_FILE"
echo ""

# 添加分类元数据
{
    echo "# $TOPIC"
    echo "# 分类：$CATEGORY"
    echo "# 创建：$(date +%Y-%m-%d)"
    echo "# 来源：$KNOWLEDGE_FILE"
    echo ""
    echo "---"
    echo ""
    cat "$LEARNINGS_DIR/$KNOWLEDGE_FILE"
} > "$TARGET_FILE"

# 验证 symlink
if [ ! -L "$WORKSPACE/memory/notes" ]; then
    echo -e "${YELLOW}创建 symlink 使知识可搜索...${NC}"
    cd "$WORKSPACE" && ln -s notes memory/notes
fi

echo -e "${GREEN}✓ 分类完成！${NC}"
echo ""
echo "文件位置：$TARGET_FILE"
echo "可通过 memory_search 搜索"
echo ""
echo -e "${BLUE}下一步:${NC}"
echo "1. 编辑文件添加更多结构"
echo "2. 建立双向链接到其他相关文档"
echo "3. 更新相关索引"
