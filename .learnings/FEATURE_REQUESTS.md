# FEATURE_REQUESTS.md - 功能请求

_记录用户请求的新功能或改进_

---

## [FEAT-20260304-001] auto-dev 自动化脚本

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: medium  
**Status**: pending  
**Area**: infra  

### Requested Capability
创建一个自动化脚本，一键执行完整的 auto-dev 流程：
```bash
auto-dev "实现登录页面"
```

自动完成：
1. 生成技术文档
2. 创建项目结构
3. 实现代码
4. 代码审查
5. Git 提交
6. 推送到 GitHub
7. 打包 ZIP
8. 发送给用户

### User Context
用户在 2026-03-04 手动测试了完整流程，希望以后能自动化执行。

### Complexity Estimate
medium

### Suggested Implementation
创建 `scripts/auto-dev.sh` 脚本，集成：
- Claude Code / code-generator 生成文档和代码
- Git 命令自动提交和推送
- zip 打包
- message 工具发送

### Metadata
- Frequency: recurring
- Related Features: capability-evolver, self-improving-agent

---

## [FEAT-20260304-002] Git Token 自动配置

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: high  
**Status**: pending  
**Area**: infra  

### Requested Capability
自动配置 Git credential，避免明文 token 和手动输入。

### User Context
GitHub secret scanning 阻止了包含 token 的推送，需要更安全的认证方式。

### Complexity Estimate
simple

### Suggested Implementation
```bash
# 使用 git credential-store
git config --global credential.helper store

# 或者使用 credential-cache
git config --global credential.helper 'cache --timeout=3600'
```

### Metadata
- Frequency: recurring
- Related Features: Git 推送流程

---

## [FEAT-20260304-003] Feishu 文件发送封装

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: medium  
**Status**: pending  
**Area**: infra  

### Requested Capability
封装一个 `send-file` 工具，自动处理文件复制和发送。

### User Context
Feishu 文件发送需要多个步骤（打包→复制→发送），希望简化流程。

### Complexity Estimate
simple

### Suggested Implementation
```bash
send-file /path/to/file.zip "消息内容"
```

自动完成：
1. 检查文件是否在 /root/.openclaw/workspace/
2. 如果不在，自动复制
3. 调用 message 工具发送

### Metadata
- Frequency: recurring
- Related Features: Feishu 集成

---

_最后更新：2026-03-04_
