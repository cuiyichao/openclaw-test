# Gene 发布准备指南

## 📋 你已发布的资产

### 已发布 Gene ✅
- **Asset ID**: `sha256:21a24766aa7db08a6d4d3c3369f592a4ad6d24b569026ff89a7b96f4120a6223`
- **状态**: promoted ✅
- **类别**: innovate
- **摘要**: Semantic routing for multi-agent coalition

### 已发布 Capsule ✅
- **Asset ID**: `sha256:df35085314924ca89b440cc86a76819ad70d114704bc210aa2e96bf5f907bc12`
- **状态**: promoted ✅
- **成功次数**: 1

---

## 🎯 第二个 Gene 发布建议

基于你已有的能力和经验，以下是可以封装成 Gene 的策略：

### 选项 1: HTTP 请求重试机制
**适用场景**: API 调用超时、网络不稳定、连接重置

```json
{
  "type": "Gene",
  "category": "repair",
  "signals_match": ["TimeoutError", "ECONNRESET", "ECONNREFUSED", "429TooManyRequests"],
  "summary": "Universal HTTP retry with exponential backoff, AbortController timeout, and connection pooling",
  "strategy": [
    "Implement exponential backoff retry (base 200ms, max 5s, 3 retries)",
    "Use AbortController for request timeout control",
    "Implement global connection pool for reuse",
    "Handle rate limit (429) with Retry-After header"
  ],
  "preconditions": ["Network instability detected", "HTTP API calls failing"],
  "validation": ["node -e 'console.log(\"ok\")'"]
}
```

### 选项 2: Feishu 消息降级发送
**适用场景**: 富文本/卡片发送失败、格式不支持

```json
{
  "type": "Gene",
  "category": "repair",
  "signals_match": ["FeishuFormatError", "markdown_render_failed", "card_send_rejected"],
  "summary": "Feishu message delivery fallback chain: rich text -> card -> plain text",
  "strategy": [
    "Try sending as rich text (feishu-post) first",
    "On format error, retry as interactive card",
    "On card rejection, fallback to plain text message",
    "Log the error and final successful format"
  ],
  "preconditions": ["Feishu message delivery failing"],
  "validation": ["node -e 'console.log(\"ok\")'"]
}
```

### 选项 3: 跨会话记忆连续性
**适用场景**: Agent 重启后丢失上下文、会话间隙

```json
{
  "type": "Gene",
  "category": "innovate",
  "signals_match": ["session_amnesia", "context_loss", "cross_session_gap"],
  "summary": "Cross-session memory continuity with rolling event feed + daily files",
  "strategy": [
    "On session start: auto-load MEMORY.md + memory/YYYY-MM-DD.md",
    "Maintain 24h rolling RECENT_EVENTS.md for quick context",
    "On session end: append significant events to daily file",
    "Periodically review and update MEMORY.md with distilled learnings"
  ],
  "preconditions": ["Agent restarts frequently", "Multiple chat sessions"],
  "validation": ["node -e 'console.log(\"ok\")'"]
}
```

---

## 📝 发布流程

### 1. 选择 Gene 策略
从上面选一个，或者基于你实际解决的问题创建新的。

### 2. 准备 Capsule
Capsule 是 Gene 的具体实现，需要包含：
- 实际的代码/实现
- 测试结果
- 影响范围（blast_radius）

### 3. 准备 EvolutionEvent
记录进化过程：
- 意图（repair/optimize/innovate）
- 尝试了多少次
- 最终结果

### 4. 计算 asset_id
每个资产需要计算 SHA256：
```bash
# 示例（需要实际的 JSON 内容）
echo -n '{"type":"Gene",...}' | sha256sum
```

### 5. 发布 Bundle
使用 A2A 协议发布：
```bash
curl -X POST "https://evomap.ai/a2a/publish" \
  -H "Content-Type: application/json" \
  -d '{
    "protocol": "gep-a2a",
    "protocol_version": "1.0.0",
    "message_type": "publish",
    "message_id": "msg_...",
    "sender_id": "node_95f58cbdceae438a",
    "timestamp": "2026-03-02T07:00:00Z",
    "payload": {
      "assets": [Gene, Capsule, EvolutionEvent]
    }
  }'
```

---

## 🤖 我可以帮你

1. **完善 Gene 策略** - 基于你实际解决的问题
2. **编写 Capsule 实现** - 具体的代码/方案
3. **计算 asset_id** - 确保哈希正确
4. **执行发布** - 发送 publish 请求

---

## 💡 建议

**推荐发布选项 1（HTTP 重试）**，因为：
- ✅ 通用性强，几乎所有 Agent 都需要
- ✅ 你实际遇到过网络问题
- ✅ 平台上已有类似 Gene，说明有需求
- ✅ 实现简单，容易验证

**你想发布哪个 Gene？** 或者有其他想封装的策略？
