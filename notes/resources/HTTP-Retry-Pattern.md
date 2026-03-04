# HTTP 重试模式
# 分类：Resources / 网络通信
# 创建：2026-02-28
# 来源：EvoMap Top #1 (复用 896,427 次)

---

## 📊 核心指标

| 指标 | 值 |
|------|-----|
| **复用次数** | 896,427+ 次 |
| **GDI 评分** | 66.0 (Top #1) |
| **成功率** | 96% |
| **成功连胜** | 22 次 |
| **效果** | API 成功率提升 30% |

---

## 🎯 问题场景

### 触发信号
- `TimeoutError` - 请求超时
- `ECONNRESET` - 连接被重置
- `ECONNREFUSED` - 连接被拒绝
- `429TooManyRequests` - 限流

### 根本原因
1. **瞬态网络故障** - 临时抖动、丢包
2. **服务端过载** - 需要降级或排队
3. **连接池耗尽** - 需要复用连接
4. **超时设置不当** - 需要动态调整

---

## 🔧 解决方案

### 核心组件

#### 1. 指数退避重试 (Exponential Backoff)

```javascript
async function retryWithBackoff(fn, options = {}) {
  const {
    maxRetries = 3,
    baseDelay = 100,      // 100ms
    maxDelay = 10000,     // 10s
    jitter = true
  } = options;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries || !isRetryable(error)) {
        throw error;
      }
      
      // 计算延迟：baseDelay * 2^attempt
      let delay = baseDelay * Math.pow(2, attempt);
      
      // 添加抖动 (避免 thundering herd)
      if (jitter) {
        delay = delay * (0.5 + Math.random());
      }
      
      // 限制最大延迟
      delay = Math.min(delay, maxDelay);
      
      await sleep(delay);
    }
  }
}

function isRetryable(error) {
  const retryableCodes = [
    'TimeoutError',
    'ECONNRESET',
    'ECONNREFUSED',
    429, 500, 502, 503, 504
  ];
  return retryableCodes.includes(error.code || error.status);
}
```

**关键参数**:
- `baseDelay`: 100-1000ms (根据业务调整)
- `maxRetries`: 3-5 次 (太多会恶化问题)
- `jitter`: 必须开启 (防止集群同时重试)

---

#### 2. AbortController 超时控制

```javascript
async function fetchWithTimeout(url, options = {}) {
  const { timeout = 30000 } = options;
  
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    return response;
  } finally {
    clearTimeout(timeoutId);
  }
}

// 使用示例
try {
  const response = await fetchWithTimeout('https://api.example.com/data', {
    timeout: 5000  // 5 秒超时
  });
} catch (error) {
  if (error.name === 'AbortError') {
    console.error('请求超时');
  } else {
    console.error('请求失败:', error);
  }
}
```

**超时建议**:
| 场景 | 推荐超时 |
|------|----------|
| 内部 API | 1-3 秒 |
| 外部 API | 5-10 秒 |
| 文件下载 | 30-60 秒 |
| 流式传输 | 根据数据量 |

---

#### 3. 全局连接池

```javascript
const https = require('https');
const http = require('http');

// 创建全局 Agent
const agentOptions = {
  keepAlive: true,
  maxSockets: 50,        // 每个主机最大连接数
  maxFreeSockets: 10,    // 最大空闲连接数
  timeout: 60000,        // 连接超时
  freeSocketTimeout: 30000  // 空闲连接回收时间
};

const httpsAgent = new https.Agent(agentOptions);
const httpAgent = new http.Agent(agentOptions);

// 使用示例
fetch('https://api.example.com/data', {
  agent: url.startsWith('https') ? httpsAgent : httpAgent
});
```

**连接池监控**:
```javascript
setInterval(() => {
  console.log('HTTPS 连接池状态:', {
    sockets: httpsAgent.sockets,
    freeSockets: httpsAgent.freeSockets,
    requests: httpsAgent.requests
  });
}, 60000); // 每分钟打印
```

---

## 📦 完整实现

```javascript
class ResilientHTTPClient {
  constructor(options = {}) {
    this.baseURL = options.baseURL;
    this.timeout = options.timeout || 10000;
    this.maxRetries = options.maxRetries || 3;
    this.baseDelay = options.baseDelay || 100;
    this.maxDelay = options.maxDelay || 10000;
    
    // 连接池
    this.agent = new https.Agent({
      keepAlive: true,
      maxSockets: 50,
      maxFreeSockets: 10,
      timeout: 60000,
      freeSocketTimeout: 30000
    });
    
    // 指标统计
    this.metrics = {
      total: 0,
      success: 0,
      retries: 0,
      failures: 0
    };
  }
  
  async request(url, options = {}) {
    this.metrics.total++;
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        const response = await this._doRequest(url, options);
        this.metrics.success++;
        return response;
      } catch (error) {
        if (attempt === this.maxRetries || !this._isRetryable(error)) {
          this.metrics.failures++;
          throw error;
        }
        
        this.metrics.retries++;
        const delay = this._calculateDelay(attempt);
        console.log(`重试 ${attempt + 1}/${this.maxRetries}, 延迟 ${delay}ms`);
        await this._sleep(delay);
      }
    }
  }
  
  async _doRequest(url, options) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        agent: this.agent,
        signal: controller.signal
      });
      
      if (!response.ok) {
        throw new HTTPError(response.status, response.statusText);
      }
      
      return response.json();
    } finally {
      clearTimeout(timeoutId);
    }
  }
  
  _isRetryable(error) {
    const retryableCodes = [
      'TimeoutError',
      'ECONNRESET',
      'ECONNREFUSED',
      'AbortError',
      429, 500, 502, 503, 504
    ];
    return retryableCodes.includes(error.code || error.status);
  }
  
  _calculateDelay(attempt) {
    let delay = this.baseDelay * Math.pow(2, attempt);
    delay = delay * (0.5 + Math.random()); // jitter
    return Math.min(delay, this.maxDelay);
  }
  
  _sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getMetrics() {
    return {
      ...this.metrics,
      successRate: this.metrics.success / this.metrics.total,
      retryRate: this.metrics.retries / this.metrics.total
    };
  }
}

class HTTPError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
    this.name = 'HTTPError';
  }
}

// 使用示例
const client = new ResilientHTTPClient({
  baseURL: 'https://api.example.com',
  timeout: 5000,
  maxRetries: 3
});

try {
  const data = await client.request('/users/123');
  console.log('成功:', data);
} catch (error) {
  console.error('失败:', error.message);
}

// 查看指标
console.log(client.getMetrics());
```

---

## 📊 效果验证

### 实施前
```
API 调用成功率：~70%
平均响应时间：2.3s
超时错误占比：18%
连接错误占比：12%
```

### 实施后
```
API 调用成功率：~95% (+35%)
平均响应时间：1.8s (-22%)
超时错误占比：3% (-83%)
连接错误占比：2% (-83%)
```

---

## ⚠️ 注意事项

### 1. 避免过度重试
```javascript
// ❌ 错误：无限制重试
while (true) {
  try { return await fn(); } catch {}
}

// ✅ 正确：限制重试次数
for (let i = 0; i < maxRetries; i++) {
  try { return await fn(); } catch {}
}
```

### 2. 必须添加 Jitter
```javascript
// ❌ 错误：固定延迟 (导致 thundering herd)
delay = 1000 * attempt;

// ✅ 正确：添加随机抖动
delay = 1000 * attempt * (0.5 + Math.random());
```

### 3. 区分错误类型
```javascript
// ❌ 错误：所有错误都重试
if (error) retry();

// ✅ 正确：只重试瞬态错误
if (isRetryable(error)) retry();
else throw error; // 4xx 客户端错误不应重试
```

### 4. 监控重试指标
```javascript
// 必须监控
- 重试率 (retry rate)
- 成功率 (success rate)
- 平均延迟 (avg latency)
- 连接池使用率 (pool utilization)
```

---

## 🔗 相关资源

- **EvoMap 胶囊**: sha256:6c8b2bef4652d5113cc802b6995a8e9f5da8b5b1ffe3d6bc639e2ca8ce27edec
- **实现项目**: [[Projects/EvoMap-Integration]]
- **相关领域**: [[Areas/AI-Capability-Development]]
- **类似方案**: 
  - [[Resources/Feishu-Message-Fallback]]
  - [[Resources/Error-Recovery-Patterns]]

---

## 📅 更新日志

- **2026-02-28**: 初始版本，基于 EvoMap Top #1 胶囊
