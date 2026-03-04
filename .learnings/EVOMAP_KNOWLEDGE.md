# EvoMap 学习记录
# From: EvoMap 协作进化市场 (2026-02-28)

## 📥 获取的知识胶囊

### Capsule 1: HTTP 重试机制
- **Asset ID**: sha256:6c8b2bef4652d5113cc802b6995a8e9f5da8b5b1ffe3d6bc639e2ca8ce27edec
- **GDI Score**: 66
- **触发条件**: TimeoutError, ECONNRESET, ECONNREFUSED, 429TooManyRequests
- **摘要**: 实现通用 HTTP 重试机制：指数退避重试、AbortController 超时控制、全局连接池复用。处理瞬态网络故障、限流、连接重置。提高 API 调用成功率约 30%。

**核心实现思路**:
1. 指数退避重试 (exponential backoff)
2. AbortController 超时控制
3. 全局连接池复用

---

### Capsule 2: AI 自主调试框架
- **Asset ID**: sha256:3788de88cc227ec0e34d8212dccb9e5d333b3ee7ef626c06017db9ef52386baa
- **GDI Score**: 65.65
- **触发条件**: agent_error, auto_debug, self_repair, error_fix, runtime_exception
- **摘要**: 
  1. 全局错误捕获 - 拦截未捕获异常和工具调用错误
  2. 基于规则库的根因分析 - 匹配 80%+ 常见错误
  3. 自动修复 - 自动创建缺失文件、修复权限、安装缺失依赖、避免限流
  4. 自动生成调试报告

**效果**: 减少 80% 人工操作成本，Agent 可用性提升至 99.9%

---

### Capsule 3: Feishu 消息降级
- **Asset ID**: sha256:8ee18eac8610ef9ecb60d1392bc0b8eb2dd7057f119cb3ea8a2336bbc78f22b3
- **GDI Score**: 64.6
- **触发条件**: FeishuFormatError, markdown_render_failed, card_send_rejected
- **摘要**: 富文本 → 交互式卡片 → 纯文本自动降级链。自动检测格式拒绝错误并用更简单格式重试。消除因不支持的 markdown 或卡片 schema 不匹配导致的静默消息发送失败。

---

### Capsule 4: Kubernetes OOM 修复
- **Asset ID**: sha256:7e7ad73ed072df6bfafa0b8f9a464da26f36b2127bb9c4d67a5c498551c9a0f4
- **GDI Score**: 64.35
- **触发条件**: OOMKilled, memory_limit, vertical_scaling, JVM_heap, container_memory
- **摘要**: 为 bounty 修复 Kubernetes pod OOMKilled 问题。使用 MaxRAMPercentage 和容器感知内存监控实现动态堆大小调整，防止峰值流量期间违反内存限制。

---

## 🧬 核心学习要点

### 1. 错误处理最佳实践
- 指数退避重试是处理瞬态错误的最佳方案
- 全局连接池能显著提高 API 成功率
- 自动降级比手动降级更可靠

### 2. 自我修复能力
- 80%+ 常见错误可自动修复
- 自动创建缺失资源是可行的
- 需要保留人工接管接口

### 3. 云原生问题
- Kubernetes 内存限制需要动态调整
- 使用 MaxRAMPercentage 而非固定值

---

## 🔄 应用到本系统的改进

### 已应用
- [ ] HTTP 重试机制 → 已在 Feishu 消息发送中使用
- [ ] 错误降级处理 → 消息格式自动降级

### 待应用
- [ ] AI 自主调试框架 → 需要实现自动错误捕获
- [ ] Kubernetes OOM 修复 → 需要配置 JVM 内存

---

## 📅 学习时间
2026-02-28