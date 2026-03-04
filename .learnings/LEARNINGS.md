# LEARNINGS.md - 自我改进日志

_记录纠正、知识缺口、最佳实践_

---

## [LRN-20260304-001] Feishu 文件发送流程

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: high  
**Status**: resolved  
**Area**: infra  

### Summary
Feishu 发送文件必须使用工作区路径 `/root/.openclaw/workspace/`，不能用 `/tmp/` 或其他路径。

### Details
用户在 2026-03-04 测试 auto-dev 完整流程时发现：

**✅ 正确方式**：
```javascript
message(
  action: "send",
  filePath: "/root/.openclaw/workspace/xxx.zip",  // 必须放在工作区
  target: "ou_xxx"
)
```

**❌ 错误方式**：
- `filePath: "/tmp/xxx.zip"` - Feishu 无法访问
- `buffer: "base64..."` - 需要 message 参数配合，容易失败
- `path: "..."` - 可能只发送路径字符串

### 成功流程
1. 打包文件到 `/tmp/xxx.zip`
2. 复制到工作区 `cp /tmp/xxx.zip /root/.openclaw/workspace/`
3. 用 message 工具发送工作区路径

### Metadata
- Source: conversation
- Related Files: notes/auto-dev-workflow.md, MEMORY.md
- Pattern-Key: feishu.file-send
- Promoted: MEMORY.md, notes/auto-dev-workflow.md

---

## [LRN-20260304-002] Git 推送 Token 安全

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: critical  
**Status**: resolved  
**Area**: infra  

### Summary
GitHub token 不能明文记录在文件中，会被 GitHub secret scanning 阻止推送。

### Details
在推送包含 token 的提交时，GitHub 返回错误：
```
remote: error: GH013: Repository rule violations found for refs/heads/master.
remote: - Push cannot contain secrets
```

**正确做法**：
1. 不要在文件中使用 `https://<TOKEN>@github.com/...` 格式
2. 使用 `git credential` 配置 token
3. 或者推送时手动输入 token

**错误示例**（不要这样做）：
```bash
git remote add origin https://ghp_xxx@github.com/user/repo.git
```

**正确示例**：
```bash
git remote add origin https://github.com/user/repo.git
# 推送时 Git 会提示输入 token
```

### 解决方案
1. 从文件中移除明文 token
2. 使用 `git commit --amend` 修改提交
3. 重新推送

### Metadata
- Source: error
- Related Files: MEMORY.md, notes/auto-dev-workflow.md
- Pattern-Key: github.token-security
- Promoted: notes/auto-dev-workflow.md

---

## [LRN-20260304-003] auto-dev 完整流程

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: high  
**Status**: resolved  
**Area**: infra  

### Summary
成功测试了完整的 auto-dev 流程：需求→技术文档→代码实现→代码审查→Git 提交→推送 GitHub→ZIP 发送

### Details
**7 步完整流程**：

1. **📝 生成技术文档** → TECH_DOC.md
2. **💻 实现代码** → index.html + css/style.css + js/login.js
3. **🔍 代码审查** → 检查代码质量
4. **📦 Git 提交** → git add -A && git commit -m "feat: xxx"
5. **🚀 推送到 GitHub** → git push -u origin <branch>
6. **📬 打包 ZIP** → zip -r project.zip -x "*.git*"
7. **✉️ 发送文件** → message 工具发送工作区文件

**测试项目**：登录页面（login-page）
- 文件：index.html, css/style.css, js/login.js, TECH_DOC.md, README.md
- GitHub: https://github.com/cuiyichao/openclaw-test/tree/login-page

### Suggested Action
已将完整流程文档化到：
- MEMORY.md（快速参考）
- notes/auto-dev-workflow.md（详细指南）

### Metadata
- Source: conversation
- Pattern-Key: auto-dev.workflow
- Promoted: MEMORY.md, notes/auto-dev-workflow.md

---

## [LRN-20260304-004] Git 子模块嵌套问题

**Logged**: 2026-03-04T11:54:00+08:00  
**Priority**: medium  
**Status**: resolved  
**Area**: infra  

### Summary
在 Git 仓库中嵌套另一个 Git 仓库（projects/login-page）会导致提交问题。

### Details
当执行 `git add -A` 时，如果子目录包含独立的 Git 仓库（有 .git 目录），Git 会：
1. 显示警告：`adding embedded git repository`
2. 将子目录作为 submodule 处理（mode 160000）
3. 不提交子目录的实际内容

**解决方案**：
- 排除子目录：`git add --all -- ':!projects/*'`
- 或者移除子目录的 .git：`rm -rf projects/login-page/.git`

### Metadata
- Source: error
- Pattern-Key: git.nested-repo

---

_最后更新：2026-03-04_
