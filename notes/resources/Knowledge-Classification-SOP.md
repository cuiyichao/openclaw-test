# 知识分类标准作业程序 (SOP)
# 版本：1.0
# 创建：2026-02-28

---

## 🎯 目标
确保每次学习的知识都经过系统化分类，便于后续检索和复用。

---

## 📋 PARA 分类标准

### 📁 Projects (项目)
**定义**: 有明确结束日期的 active work

**判断标准**:
- [ ] 有明确的完成日期/里程碑
- [ ] 需要多个步骤才能完成
- [ ] 完成后会移入 Archive

**示例**:
- "EvoMap 集成项目" (截止 2026-03-15)
- "HTTP 重试机制实现"
- "AI 自主调试框架开发"

**文件命名**: `Project-Name.md`

---

### 📁 Areas (领域)
**定义**: 持续维护的责任领域

**判断标准**:
- [ ] 没有结束日期，需要持续关注
- [ ] 有明确的成功标准/指标
- [ ] 需要定期回顾和更新

**示例**:
- "AI 能力发展" (持续提升能力)
- "系统稳定性" (持续监控和维护)
- "用户体验优化" (持续改进)

**文件命名**: `Area-Name.md`

---

### 📁 Resources (资源)
**定义**: 可复用的参考材料和知识

**判断标准**:
- [ ] 可复用的技术解决方案
- [ ] 最佳实践模式
- [ ] 外部知识库/文档
- [ ] 工具和技能说明

**示例**:
- "EvoMap 知识库" (技术胶囊集合)
- "HTTP 重试模式" (可复用方案)
- "Feishu API 参考" (外部文档)

**文件命名**: `Topic-Name.md`

---

### 📁 Archive (归档)
**定义**: 已完成的项目或过时的知识

**判断标准**:
- [ ] 项目已完成/取消
- [ ] 知识已过时/被替代
- [ ] 不再 active 但需要保留历史记录

**示例**:
- "Project-XXX-Completed"
- "Legacy-System-Docs"

**文件命名**: `YYYY-MM-DD-Original-Name.md`

---

## 🔄 知识处理流程

### Step 1: 获取知识
```
来源: EvoMap / 用户反馈 / 错误日志 / 学习材料
↓
保存到临时位置：.learnings/RAW-YYYY-MM-DD.md
```

### Step 2: 初步分析
```
阅读原始材料
↓
识别关键知识点
↓
标记潜在分类 (Project/Area/Resource)
```

### Step 3: 分类决策树

```
这个知识是...
│
├─ 需要主动完成的任务？
│   └─ 有明确截止日期？
│       ├─ YES → Projects/
│       └─ NO → Areas/
│
├─ 可复用的参考材料？
│   └─ YES → Resources/
│
├─ 已完成/过时的内容？
│   └─ YES → Archive/
│
└─ 不确定？
    └─ 暂时放入 Resources/，后续调整
```

### Step 4: 创建/更新文档

**新项目**:
```bash
touch notes/projects/Project-Name.md
# 填写项目模板
```

**更新现有**:
```bash
# 追加到新分类的对应文档
# 或创建新的子文档
```

### Step 5: 建立连接

**添加双向链接**:
```markdown
## 相关资源
- [[Projects/Related-Project]]
- [[Areas/Related-Area]]
- [[Resources/Related-Resource]]
```

**更新索引**:
```markdown
# 在对应分类的主索引中添加引用
```

### Step 6: 标记 searchable

**确保 symlink 存在**:
```bash
ln -s notes memory/notes  # 只需执行一次
```

**验证搜索**:
```bash
# 使用 memory_search 测试能否找到新内容
```

---

## 📝 文档模板

### Projects 模板
```markdown
# 项目：{项目名称}
# 状态：Active | On Hold | Completed
# 创建：YYYY-MM-DD
# 截止：YYYY-MM-DD

## 🎯 项目目标

## 📋 待办任务
- [ ] Task 1
- [ ] Task 2

## 📊 进度跟踪

## 🔗 相关资源
- [[Areas/Related-Area]]
- [[Resources/Related-Resource]]
```

### Areas 模板
```markdown
# 领域：{领域名称}
# 类型：Area (持续维护)
# 创建：YYYY-MM-DD

## 🎯 领域目标

## 📊 关键指标

## 🔧 能力建设

## 📈 历史改进记录
```

### Resources 模板
```markdown
# {资源主题}
# 分类：Resources
# 创建：YYYY-MM-DD
# 来源：{来源链接/引用}

## 📚 概述

## 🔧 技术方案/知识点

## 📊 统计/指标

## 🔗 相关资源
- [[Projects/Related-Project]]
- [[Areas/Related-Area]]
```

---

## ✅ 质量检查清单

每次分类完成后检查：

- [ ] 分类正确 (Project/Area/Resource/Archive)
- [ ] 文件命名规范
- [ ] 添加了日期戳
- [ ] 建立了双向链接
- [ ] 更新了相关索引
- [ ] 可通过 memory_search 搜索到
- [ ] 原始学习记录已归档到 `.learnings/`

---

## 📅 维护计划

### 每日
- [ ] 处理当天学习的新知识
- [ ] 更新 `.learnings/` 目录

### 每周
- [ ] 回顾 Projects 进度
- [ ] 更新 Areas 指标
- [ ] 清理 Resources 重复内容

### 每月
- [ ] 移动 Completed Projects 到 Archive
- [ ] 评估 Areas 健康度
- [ ] 整理 Resources 结构

---

## 🎓 示例：本次 EvoMap 学习

### 原始学习
```
.learnings/EVOMAP_KNOWLEDGE.md
.learnings/EVOMAP_ADVANCED_KNOWLEDGE.md
```

### 分类后
```
notes/resources/EvoMap-Knowledge-Base.md     ← 技术胶囊库
notes/projects/EvoMap-Integration.md         ← 集成项目
notes/areas/AI-Capability-Development.md     ← 能力发展领域
```

### 连接关系
```
EvoMap-Knowledge-Base (Resource)
    ↓ 指导
EvoMap-Integration (Project)
    ↓ 服务于
AI-Capability-Development (Area)
```

---

## 🔗 工具集成

### self-improving-agent
- 自动记录错误到 `.learnings/ERRORS.md`
- 自动记录学习到 `.learnings/LEARNINGS.md`

### capability-evolver
- 分析 `.learnings/` 中的模式
- 生成进化建议

### memory_search
- 搜索所有 PARA 知识库
- 通过 symlink 实现全局搜索

---

## 📞 常见问题

**Q: 一个知识点可以属于多个分类吗？**
A: 可以！使用交叉引用链接。例如一个技术方案 (Resource) 可能服务于某个项目 (Project)。

**Q: 如何决定创建新文档还是追加到现有文档？**
A: 
- 主题相关 → 追加到现有文档
- 主题独立 → 创建新文档
- 不确定 → 先追加，后续拆分

**Q: Archive 和 Resources 有什么区别？**
A: 
- Resources = 持续有用的参考材料
- Archive = 已完成/过时的历史记录

---

## 📈 持续改进

每次使用此 SOP 后，记录改进建议：

- **2026-02-28**: 初始版本创建
