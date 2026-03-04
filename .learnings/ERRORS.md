# ERRORS.md - 错误日志

_记录命令失败、异常、意外行为_

---

## [ERR-20260304-001] GitHub Secret Scanning 阻止推送

**Logged**: 2026-03-04T11:43:00+08:00  
**Priority**: critical  
**Status**: resolved  
**Area**: infra  

### Summary
Git 推送被 GitHub secret scanning 阻止，因为提交中包含明文 GitHub token。

### Error
```
remote: error: GH013: Repository rule violations found for refs/heads/master.
remote: - Push cannot contain secrets
remote: —— GitHub Personal Access Token ——————————————————————
remote: locations:
remote:   - commit: 518d117cc8f3e0c77ac3f21679f9612fc40370bd
remote:     path: MEMORY.md:138
remote:     path: notes/auto-dev-workflow.md:101
```

### Context
- 在 MEMORY.md 和 notes/auto-dev-workflow.md 中记录了 GitHub token
- 格式：`https://ghp_xxx@github.com/user/repo.git`
- GitHub 自动扫描并阻止推送

### Suggested Fix
1. 从文件中移除 token
2. 使用 `git commit --amend` 修改提交
3. 或者创建新分支重新提交
4. 以后使用 git credential 配置 token

### Resolution
- **Resolved**: 2026-03-04T11:47:00+08:00
- **Commit**: cf58b9c
- **Notes**: 移除所有明文 token，使用 `git commit --amend` 修改提交后推送成功

### Metadata
- Reproducible: yes
- Related Files: MEMORY.md, notes/auto-dev-workflow.md
- See Also: LRN-20260304-002

---

## [ERR-20260304-002] Feishu 文件发送失败

**Logged**: 2026-03-04T10:56:00+08:00  
**Priority**: high  
**Status**: resolved  
**Area**: infra  

### Summary
使用 message 工具发送文件时，用户收到的是路径字符串而不是实际文件。

### Error
用户反馈："你发送了个路径给我"

### Context
- 使用 `filePath: "/tmp/xxx.zip"` 发送
- Feishu 返回成功（有 messageId）
- 但用户实际收到的是路径文本

### Suggested Fix
1. 文件必须放在 `/root/.openclaw/workspace/` 目录
2. 使用 `cp /tmp/xxx.zip /root/.openclaw/workspace/` 复制
3. 然后用工作区路径发送

### Resolution
- **Resolved**: 2026-03-04T11:12:00+08:00
- **Notes**: 复制到工作区后发送成功

### Metadata
- Reproducible: yes
- Related Files: notes/auto-dev-workflow.md
- See Also: LRN-20260304-001

---

## [ERR-20260304-003] Git 嵌套仓库警告

**Logged**: 2026-03-04T11:43:00+08:00  
**Priority**: medium  
**Status**: resolved  
**Area**: infra  

### Error
```
warning: adding embedded git repository: projects/login-page
hint: You've added another git repository inside your current repository.
hint: If you meant to add a submodule, use:
hint: 	git submodule add <url> projects/login-page
```

### Context
- projects/login-page 目录有独立的 .git 目录
- 执行 `git add -A` 时触发警告
- Git 将其作为 submodule 处理（mode 160000）

### Suggested Fix
- 排除子目录：`git add --all -- ':!projects/*'`
- 或者移除子目录的 .git 目录

### Resolution
- **Resolved**: 2026-03-04T11:43:00+08:00
- **Notes**: 使用 `-- ':!agents/*'` 排除子目录后成功提交

### Metadata
- Reproducible: yes
- Related Files: projects/login-page
- See Also: LRN-20260304-004

---

_最后更新：2026-03-04_
