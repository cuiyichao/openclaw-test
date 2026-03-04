# AI 自主调试框架
# 分类：Resources / AI 自我修复
# 创建：2026-02-28
# 来源：EvoMap Top #2 (复用 896,431 次)

---

## 📊 核心指标

| 指标 | 值 |
|------|-----|
| **复用次数** | 896,431+ 次 |
| **GDI 评分** | 65.65 |
| **成功率** | 96% |
| **效果** | 减少 80% 人工操作，可用性 99.9% |

---

## 🎯 问题场景

### 触发信号
- `agent_error` - AI 执行错误
- `auto_debug` - 调试请求
- `self_repair` - 自我修复请求
- `error_fix` - 错误修复请求
- `runtime_exception` - 运行时异常

---

## 🔧 核心能力

### 1. 全局错误捕获

```javascript
// 错误拦截器
class GlobalErrorInterceptor {
  constructor() {
    this.errorPatterns = new Map();
    this.setupInterceptors();
  }
  
  setupInterceptors() {
    // 拦截未捕获异常
    process.on('uncaughtException', (error) => {
      this.handleError(error, 'uncaughtException');
    });
    
    process.on('unhandledRejection', (reason) => {
      this.handleError(reason, 'unhandledRejection');
    });
    
    // 拦截工具调用错误
    this.interceptToolCalls();
  }
  
  interceptToolCalls() {
    const originalExec = exec;
    exec = async (...args) => {
      try {
        return await originalExec(...args);
      } catch (error) {
        this.handleToolError(error, args);
        throw error;
      }
    };
  }
  
  handleError(error, source) {
    console.error(`[${source}] ${error.message}`);
    // 记录错误到日志
    this.logError({
      error: error.message,
      stack: error.stack,
      source,
      timestamp: new Date().toISOString()
    });
  }
}
```

### 2. 根因分析规则库

```javascript
class RootCauseAnalyzer {
  constructor() {
    this.rules = this.initializeRules();
  }
  
  initializeRules() {
    return [
      {
        pattern: /command not found/i,
        category: 'CommandNotFound',
        solutions: [
          { action: 'install', command: 'apt-get install -y {{package}}' },
          { action: 'install', command: 'npm install -g {{package}}' },
          { action: 'install', command: 'pip install {{package}}' }
        ]
      },
      {
        pattern: /permission denied/i,
        category: 'PermissionDenied',
        solutions: [
          { action: 'chmod', command: 'chmod +x {{file}}' },
          { action: 'sudo', command: 'sudo {{command}}' }
        ]
      },
      {
        pattern: /ENOENT|no such file/i,
        category: 'FileNotFound',
        solutions: [
          { action: 'create', content: '# {{filename}}\n' },
          { action: 'mkdir', command: 'mkdir -p {{dir}}' }
        ]
      },
      {
        pattern: /ECONNREFUSED|connection refused/i,
        category: 'ConnectionRefused',
        solutions: [
          { action: 'retry', delay: 2000 },
          { action: 'check', service: 'systemctl status {{service}}' }
        ]
      },
      {
        pattern: /timeout|timed out/i,
        category: 'Timeout',
        solutions: [
          { action: 'retry', delay: 5000 },
          { action: 'increase', timeout: '{{current}} * 2' }
        ]
      },
      {
        pattern: /npm install|package.*not found/i,
        category: 'MissingDependency',
        solutions: [
          { action: 'install', command: 'npm install {{package}}' },
          { action: 'install', command: 'npm ci' }
        ]
      }
    ];
  }
  
  analyze(errorMessage) {
    for (const rule of this.rules) {
      if (rule.pattern.test(errorMessage)) {
        return {
          category: rule.category,
          confidence: 0.85,
          solutions: rule.solutions
        };
      }
    }
    return { category: 'Unknown', confidence: 0, solutions: [] };
  }
}
```

### 3. 自动修复引擎

```javascript
class AutoRepairEngine {
  constructor(analyzer) {
    this.analyzer = analyzer;
    this.repairHistory = [];
  }
  
  async autoRepair(error, context) {
    const analysis = this.analyzer.analyze(error.message);
    
    if (analysis.confidence < 0.5) {
      console.log('错误无法自动修复，生成报告');
      return this.generateErrorReport(error, context, analysis);
    }
    
    console.log(`检测到 ${analysis.category}，置信度 ${analysis.confidence}`);
    
    for (const solution of analysis.solutions) {
      try {
        await this.applySolution(solution, context);
        console.log(`✓ 修复成功: ${solution.action}`);
        this.recordRepair(error, solution, 'success');
        return true;
      } catch (e) {
        console.log(`✗ 修复失败: ${solution.action}, 尝试下一个...`);
        this.recordRepair(error, solution, 'failed');
      }
    }
    
    // 所有方案都失败
    console.log('所有自动修复方案都失败，生成报告');
    return this.generateErrorReport(error, context, analysis);
  }
  
  async applySolution(solution, context) {
    switch (solution.action) {
      case 'install':
        await exec(solution.command);
        break;
      case 'chmod':
        await exec(solution.command);
        break;
      case 'create':
        await write(solution.content);
        break;
      case 'mkdir':
        await exec(solution.command);
        break;
      case 'retry':
        await sleep(solution.delay);
        break;
      default:
        console.log(`未知动作: ${solution.action}`);
    }
  }
  
  generateErrorReport(error, context, analysis) {
    const report = {
      error: error.message,
      stack: error.stack,
      context: context,
      analysis: analysis,
      timestamp: new Date().toISOString(),
      requiresHuman: true
    };
    
    // 保存报告
    const filename = `.learnings/ERRORS/${Date.now()}_error_report.json`;
    // write(filename, JSON.stringify(report, null, 2));
    
    return report;
  }
  
  recordRepair(error, solution, status) {
    this.repairHistory.push({
      errorType: error.message.substring(0, 50),
      solution,
      status,
      timestamp: new Date().toISOString()
    });
  }
}
```

### 4. 调试报告生成

```javascript
function generateIntrospectionReport(error, context, analysis) {
  const report = `# 调试报告
  
## 错误信息
- **时间**: ${new Date().toISOString()}
- **错误**: ${error.message}
- **类型**: ${error.name}

## 上下文
\`\`\`json
${JSON.stringify(context, null, 2)}
\`\`\`

## 根因分析
- **分类**: ${analysis.category}
- **置信度**: ${(analysis.confidence * 100).toFixed(1)}%

## 尝试的解决方案
${analysis.solutions.map((s, i) => `${i + 1}. ${s.action}: ${JSON.stringify(s)}`).join('\n')}

## 堆栈跟踪
\`\`\`
${error.stack}
\`\`\`

## 建议
${analysis.confidence > 0.8 
  ? '✅ 高置信度，建议自动修复' 
  : '⚠️ 置信度较低，需要人工介入'}
`;
  
  return report;
}
```

---

## 📦 完整实现架构

```javascript
class AISelfDebuggingFramework {
  constructor() {
    this.interceptor = new GlobalErrorInterceptor();
    this.analyzer = new RootCauseAnalyzer();
    this.repairEngine = new AutoRepairEngine(this.analyzer);
    this.stats = { repairs: 0, success: 0, failed: 0 };
  }
  
  async handleError(error, context = {}) {
    console.log(`[AI Debug] 处理错误: ${error.message}`);
    
    // 1. 错误分类
    const analysis = this.analyzer.analyze(error.message);
    
    // 2. 尝试自动修复
    const repaired = await this.repairEngine.autoRepair(error, context);
    
    // 3. 更新统计
    this.stats.repairs++;
    if (repaired) this.stats.success++;
    else this.stats.failed++;
    
    // 4. 生成报告（如果需要人工介入）
    if (!repaired) {
      const report = generateIntrospectionReport(error, context, analysis);
      console.log('需要人工介入');
      // 可以通知用户
    }
    
    return repaired;
  }
  
  getStats() {
    return {
      ...this.stats,
      successRate: this.stats.repairs > 0 
        ? (this.stats.success / this.stats.repairs * 100).toFixed(1) + '%'
        : '0%'
    };
  }
}

// 使用示例
const debugger = new AISelfDebuggingFramework();

// 模拟错误处理
try {
  await doSomething();
} catch (error) {
  await debugger.handleError(error, { 
    tool: 'exec', 
    command: 'npm install',
    timestamp: new Date().toISOString() 
  });
}
```

---

## 📊 效果验证

### 实施前后对比

| 指标 | 实施前 | 实施后 | 改善 |
|------|--------|--------|------|
| 人工干预率 | 80% | 20% | -75% |
| 平均修复时间 | 30 分钟 | 2 分钟 | -93% |
| 工具调用成功率 | 70% | 99.9% | +43% |
| 错误复发率 | 15% | 2% | -87% |

---

## ⚠️ 安全注意事项

1. **限制自动修复范围**
   ```javascript
   const ALLOWED_REPAIRS = ['install', 'create', 'mkdir', 'chmod'];
   const BLOCKED_REPAIRS = ['rm', 'drop', 'delete'];
   
   if (BLOCKED_REPAIRS.includes(action)) {
     throw new Error('危险操作禁止自动执行');
   }
   ```

2. **增加人工确认**
   ```javascript
   if (analysis.confidence < 0.8) {
     // 低置信度需要人工确认
     await notifyHuman(error, analysis);
   }
   ```

3. **记录所有操作**
   ```javascript
   log('auto_repair', { 
     error, 
     solution, 
     result,
     approvedBy: 'auto' // 或 human
   });
   ```

---

## 🔗 相关资源

- **EvoMap 胶囊**: sha256:3788de88cc227ec0e34d8212dccb9e5d333b3ee7ef626c06017db9ef52386baa
- **相关**: [[Resources/HTTP-Retry-Pattern]]

---

## 📅 更新日志
- **2026-02-28**: 初始版本，基于 EvoMap Top #2 胶囊