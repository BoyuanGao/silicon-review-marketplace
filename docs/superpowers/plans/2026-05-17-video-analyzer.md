# video-analyzer Skill 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 `video-product-summary` skill 重构为通用的 `video-analyzer`，支持会议纪要、教学总结、产品分析三种预设模式 + 自定义模式。

**Architecture:** 主文件 SKILL.md 包含模式选择逻辑和共享视频处理流水线，references/ 目录下每个模式一个文件包含分析策略和输出模板。从当前 video-product-summary 目录重命名为 video-analyzer，迁移产品分析内容到 references/product-mode.md，新建其余三个模式文件。

**Tech Stack:** Markdown skill 文件、peepshow CLI、MiniMax MCP、whisper.cpp

---

### Task 1: 重命名目录并创建 references 目录结构

**Files:**
- Rename: `video-product-summary/` → `video-analyzer/`
- Create: `video-analyzer/references/`

- [ ] **Step 1: 重命名 skill 目录**

```bash
mv /home/gaoby3/project/gaoboy-marketplace/video-product-summary /home/gaoby3/project/gaoboy-marketplace/video-analyzer
```

- [ ] **Step 2: 创建 references 目录**

```bash
mkdir -p /home/gaoby3/project/gaoboy-marketplace/video-analyzer/references
```

- [ ] **Step 3: 验证目录结构**

```bash
ls -la /home/gaoby3/project/gaoboy-marketplace/video-analyzer/
ls -la /home/gaoby3/project/gaoboy-marketplace/video-analyzer/references/
```

Expected: video-analyzer/ 下有 SKILL.md、.claude-plugin/、references/

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: rename video-product-summary to video-analyzer, add references dir"
```

---

### Task 2: 创建 references/product-mode.md（迁移现有产品分析内容）

**Files:**
- Create: `video-analyzer/references/product-mode.md`

从当前 SKILL.md 中提取产品演示分析模式的专有内容：帧分析 prompt、转录提炼重点、图像分析模式的输出模板、降级模式输出模板。

- [ ] **Step 1: 创建 product-mode.md**

```markdown
---
name: product-mode
description: 产品演示分析模式 — 提取功能模块、使用场景和 User Journey
---

# 产品演示分析模式

## 模式标识

`product` — 当用户提到产品、功能、demo、演示、user journey 等关键词时触发。

## 帧过滤标准

识别"产品功能演示时间段"：

- **目标段**：讲解功能模块、操作演示、界面展示的片段
- **跳过段**：开场寒暄、嘉宾介绍、会议总结/感谢、Q&A 闲聊、纯过渡画面

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
产品演示视频截图分析。请描述画面中的内容。重点关注：
1. 产品功能模块名称（左侧菜单、顶部标签、按钮文字）
2. 正在演示的具体功能（筛选条件、话术配置、数据看板等）
3. 界面上的关键数据和文字
4. 对应的业务使用场景
用中文回答，简明扼要。如果画面没有变化（如PPT静止页），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 产品名称、定位、解决的问题
- 功能模块及其作用描述
- 典型使用场景和用户角色
- 技术特点或竞争优势
- 行业案例或客户故事

## 图像分析模式输出模板

```markdown
# <产品名称>产品能力介绍

**来源：** <会议名称/文件名>
**时长：** <X 小时 X 分钟>
**平台：** <Teams/腾讯会议/Zoom 等>

---

## 一、产品定位

<2-3 句概述：产品是什么、解决什么问题、核心技术特点>

---

## 二、产品架构总览

<ASCII 架构图：按"获客→触达→管理"链路排列各模块>

---

## 三、功能模块详解

### 模块 1：<模块名称>

![<描述>](screenshots/<对应帧文件名>)

**功能点：**
- <功能点 1>
- <功能点 2>
- ...

**User Journey：**
> <角色> → <操作1> → <操作2> → ... → <最终效果>

**演示案例：** <视频中实际演示的具体场景>

### 模块 2：<模块名称>
...

---

## 四、User Journey 全景

<ASCII 流程图：从获客到管理的完整用户路径>

---

## 五、行业应用场景

| 行业 | 场景 | 核心模块 |
|------|------|---------|
| ... | ... | ... |

---

## 六、技术特点

- <技术特点>
- ...

---

*本报告由 peepshow + MiniMax MCP + Claude Code 自动生成*
```

## 降级模式输出模板（零功能帧时使用）

```markdown
# <产品名称>产品能力介绍（会议转录总结）

> ⚠️ 本次会议视频为人物录屏/PPT，无产品界面演示。以下内容基于会议转录文本整理。

**来源：** <会议名称/文件名>
**时长：** <X 小时 X 分钟>
**平台：** <Teams/腾讯会议/Zoom 等>

---

## 一、产品定位

<从会议对话中提取的产品定位描述>

---

## 二、功能模块梳理

以下模块由会议讨论内容归纳，非界面演示提取：

### 模块 1：<模块名称>

**功能点（来自会议讨论）：**
- <从对话中提取的功能点>
- ...

**涉及场景：** <对话中提到的使用场景>

### 模块 2：<模块名称>
...

---

## 三、使用场景与 User Journey

<从讨论中还原的用户路径，用 ASCII 流程图>

---

## 四、行业应用场景

| 行业 | 场景 | 涉及模块 |
|------|------|---------|
| ... | ... | ... |

---

## 五、技术特点

- <从对话中提取的技术特点>
- ...

---

## 六、会议转录摘要

<200-300 字的会议核心内容摘要>

---

## 附录：完整转录文件

- [完整转录文本](<产品名称>_transcript.txt)
- [字幕文件](<产品名称>_transcript.srt)

---

*本报告由 peepshow + whisper.cpp + Claude Code 自动生成（纯转录模式）*
```
```

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/references/product-mode.md
git commit -m "feat: add product-mode.md reference for video-analyzer"
```

---

### Task 3: 创建 references/meeting-mode.md

**Files:**
- Create: `video-analyzer/references/meeting-mode.md`

- [ ] **Step 1: 创建 meeting-mode.md**

```markdown
---
name: meeting-mode
description: 会议纪要模式 — 提取决策、行动项、关键讨论点
---

# 会议纪要模式

## 模式标识

`meeting` — 当用户提到会议、meeting、纪要、行动项、action item 等关键词时触发。

## 帧过滤标准

识别"实质性讨论时间段"：

- **目标段**：议程讨论、决策陈述、任务分配、数据汇报、方案评审
- **跳过段**：开场寒暄、自我介绍、茶歇/休息、闲聊、纯过渡画面

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
会议视频截图分析。请描述画面中的内容。重点关注：
1. 演示文档/PPT 的标题和要点（大标题、项目符号、关键数据）
2. 数据图表的内容（轴标签、数值、趋势）
3. 白板/协作画板上的文字和图形
4. 屏幕共享中的应用界面（如项目管理工具、表格等）
用中文回答，简明扼要。如果画面没有变化（如静止PPT），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 决策项：达成了什么共识或决定
- 行动项：谁需要在什么时间前完成什么
- 关键讨论点：各方观点和论据
- 反对意见：谁持不同意见，理由是什么
- 待定事项：悬而未决、需要后续跟进的问题
- 重要数据：会议中引用的关键数字和指标

## 图像分析模式输出模板

```markdown
# <会议主题>会议纪要

**来源：** <会议名称/文件名>
**时长：** <X 小时 X 分钟>
**平台：** <Teams/腾讯会议/Zoom 等>

---

## 一、会议概要

- **主题：** <会议主题>
- **关键结论：** <1-2 句话概括会议核心结论>

---

## 二、决策记录

| # | 决策内容 | 相关背景 | 备注 |
|---|---------|---------|------|
| 1 | <决策描述> | <为什么做此决策> | <补充说明> |
| ... | ... | ... | ... |

---

## 三、行动项清单

| # | 任务 | 负责人 | 截止时间 | 状态 |
|---|------|--------|---------|------|
| 1 | <任务描述> | <负责人> | <截止日期> | 待开始 |
| ... | ... | ... | ... | ... |

---

## 四、关键讨论点

### 议题 1：<议题名称>

**背景：** <为什么讨论这个议题>

**各方观点：**
- <人/角色 A>：<观点>
- <人/角色 B>：<观点>

**结论：** <讨论结果>

### 议题 2：<议题名称>
...

---

## 五、待定/未决事项

| # | 事项 | 需要谁跟进 | 下一步 |
|---|------|-----------|--------|
| 1 | <未决事项> | <跟进人> | <下一步动作> |
| ... | ... | ... | ... |

---

## 六、会议转录摘要

<200-300 字的会议核心内容摘要>

---

*本纪要由 peepshow + MiniMax MCP + Claude Code 自动生成*
```

## 降级模式输出模板（零目标帧时使用）

```markdown
# <会议主题>会议纪要（纯转录总结）

> ⚠️ 本次会议视频无共享屏幕/PPT 内容。以下内容基于会议转录文本整理。

**来源：** <会议名称/文件名>
**时长：** <X 小时 X 分钟>
**平台：** <Teams/腾讯会议/Zoom 等>

---

## 一、会议概要

- **主题：** <会议主题>
- **关键结论：** <1-2 句话概括会议核心结论>

---

## 二、决策记录

| # | 决策内容 | 相关背景 |
|---|---------|---------|
| ... | ... | ... |

---

## 三、行动项清单

| # | 任务 | 负责人 | 截止时间 |
|---|------|--------|---------|
| ... | ... | ... | ... |

---

## 四、关键讨论点

<基于转录文本归纳的讨论要点>

---

## 五、待定/未决事项

<需要后续跟进的问题>

---

## 六、会议转录摘要

<200-300 字的会议核心内容摘要>

---

## 附录：完整转录文件

- [完整转录文本](<会议主题>_transcript.txt)
- [字幕文件](<会议主题>_transcript.srt)

---

*本纪要由 peepshow + whisper.cpp + Claude Code 自动生成（纯转录模式）*
```
```

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/references/meeting-mode.md
git commit -m "feat: add meeting-mode.md reference for video-analyzer"
```

---

### Task 4: 创建 references/training-mode.md

**Files:**
- Create: `video-analyzer/references/training-mode.md`

- [ ] **Step 1: 创建 training-mode.md**

```markdown
---
name: training-mode
description: 教学/培训总结模式 — 提取知识点、章节结构、关键概念和实操步骤
---

# 教学/培训总结模式

## 模式标识

`training` — 当用户提到教学、培训、课程、知识点、lecture、tutorial 等关键词时触发。

## 帧过滤标准

识别"知识讲解时间段"：

- **目标段**：知识讲解、概念定义、示例演示、实操步骤、案例分析、板书/图表讲解
- **跳过段**：课前准备/调试、课间休息、广告/宣传、纯闲聊、设备故障等待

## 帧分析 Prompt

每帧调用 `mcp__MiniMax__understand_image` 时使用以下 prompt：

```
教学/培训视频截图分析。请描述画面中的内容。重点关注：
1. 幻灯片/PPT 的标题和要点（章节标题、定义、公式）
2. 板书/手写内容（关键概念、推导过程）
3. 代码演示片段（语言、函数名、关键逻辑）
4. 图表和示意图（流程图、架构图、对比图）
5. 实操界面（工具名称、操作步骤）
用中文回答，简明扼要。如果画面没有变化（如静止PPT），说明即可。
```

## 转录提炼重点

从转录文本中提取：

- 课程/培训的主题和目标
- 章节结构和知识体系
- 关键概念的定义和解释
- 重要公式、定理或规则
- 示例和案例
- 实操步骤和注意事项
- 常见问题和易错点

## 图像分析模式输出模板

```markdown
# <课程/培训名称>学习总结

**来源：** <视频文件名>
**时长：** <X 小时 X 分钟>
**类型：** <教学/培训/讲座/教程>

---

## 一、课程概览

- **主题：** <课程主题>
- **核心目标：** <学完能掌握什么>
- **适用人群：** <目标受众>

---

## 二、知识结构

<章节树形结构>

```
<课程主题>
├── 第一章：<章节名>
│   ├── <知识点1>
│   └── <知识点2>
├── 第二章：<章节名>
│   ├── <知识点1>
│   └── <知识点2>
└── ...
```

---

## 三、核心知识点详解

### 第一章：<章节名称>

#### 知识点 1：<名称>

**定义：** <概念定义>

![<描述>](screenshots/<对应帧文件名>)

**要点：**
- <要点 1>
- <要点 2>

**示例：** <相关示例或案例>

#### 知识点 2：<名称>
...

### 第二章：<章节名称>
...

---

## 四、关键概念速查表

| 概念 | 定义 | 关键要点 |
|------|------|---------|
| <概念1> | <一句话定义> | <核心要点> |
| <概念2> | <一句话定义> | <核心要点> |
| ... | ... | ... |

---

## 五、实操步骤

<如果视频中包含实操演示，列出步骤；否则注明"本课程无实操环节">

### <实操名称>

1. <步骤 1>
2. <步骤 2>
3. ...

**注意事项：**
- <注意事项 1>
- <注意事项 2>

---

## 六、课程转录摘要

<200-300 字的课程核心内容摘要>

---

*本总结由 peepshow + MiniMax MCP + Claude Code 自动生成*
```

## 降级模式输出模板（零目标帧时使用）

```markdown
# <课程/培训名称>学习总结（纯转录总结）

> ⚠️ 本视频无幻灯片/板书等视觉教学内容。以下内容基于转录文本整理。

**来源：** <视频文件名>
**时长：** <X 小时 X 分钟>

---

## 一、课程概览

- **主题：** <课程主题>
- **核心目标：** <学完能掌握什么>

---

## 二、知识结构

<基于转录文本归纳的章节结构>

```
<课程主题>
├── <章节1>
│   └── <知识点>
└── ...
```

---

## 三、核心知识点详解

<基于转录文本整理的知识点>

---

## 四、关键概念速查表

| 概念 | 定义 |
|------|------|
| ... | ... |

---

## 五、课程转录摘要

<200-300 字的课程核心内容摘要>

---

## 附录：完整转录文件

- [完整转录文本](<课程名称>_transcript.txt)
- [字幕文件](<课程名称>_transcript.srt)

---

*本总结由 peepshow + whisper.cpp + Claude Code 自动生成（纯转录模式）*
```
```

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/references/training-mode.md
git commit -m "feat: add training-mode.md reference for video-analyzer"
```

---

### Task 5: 创建 references/custom-mode.md

**Files:**
- Create: `video-analyzer/references/custom-mode.md`

- [ ] **Step 1: 创建 custom-mode.md**

```markdown
---
name: custom-mode
description: 自定义模式 — 用户用自然语言描述提取目标，AI 动态生成分析策略和输出模板
---

# 自定义模式

## 模式标识

`custom` — 当用户输入不匹配预设模式关键词，或用户明确说"提取/找出/总结 XXX"时触发。

## 意图解析

用户用自然语言描述提取目标时，将其解析为三个要素：

1. **提取目标**：用户想从视频中获取什么信息
2. **关注维度**：分析帧和转录时应重点关注的方面
3. **输出格式偏好**：结果以什么结构呈现（列表、表格、时间线等）

**解析示例：**

| 用户输入 | 提取目标 | 关注维度 | 输出格式 |
|---------|---------|---------|---------|
| "找出视频里提到的所有竞品" | 竞品名称和信息 | 竞品提及、对比分析 | 表格：竞品名 | 特点 | 与自家对比 |
| "提取这个视频里的技术架构信息" | 技术架构 | 架构图、组件名称、技术栈 | 层级结构图 + 组件表格 |
| "总结这个访谈里嘉宾的核心观点" | 嘉宾观点 | 观点陈述、论据、态度 | 按嘉宾分节列表 |

## 模糊输入处理

如果用户描述太模糊（如"分析这个视频"、"帮我看看这个视频"），主动追问：

> 你想从这个视频中提取什么内容？例如：
> - 会议的决策和行动项
> - 教学视频的知识点和概念
> - 产品功能和使用场景
> - 或者其他你关心的内容

## 帧过滤标准

根据解析出的"关注维度"动态生成过滤标准：

- **目标段**：包含与提取目标相关的视觉内容的片段
- **跳过段**：与提取目标无关的片段

如果无法仅从转录判断相关性，保留帧进入分析阶段，在帧分析时再过滤。

## 帧分析 Prompt

基于解析出的提取目标和关注维度，动态生成帧分析 prompt。模板：

```
视频截图分析。用户想从视频中提取：{提取目标}。
请描述画面中与以下维度相关的内容：{关注维度}。
如果画面与提取目标无关，说明"无关画面"即可。
用中文回答，简明扼要。
```

## 转录提炼重点

根据提取目标从转录文本中提取相关内容，重点关注解析出的"关注维度"。

## 输出模板生成

根据提取目标和输出格式偏好动态组织输出。通用骨架：

```markdown
# <标题：基于提取目标生成>

**来源：** <视频文件名>
**时长：** <X 小时 X 分钟>
**提取目标：** <用户的提取目标>

---

## 一、概要

<基于提取目标的内容概述，2-3 句>

---

## 二、<根据输出格式偏好组织正文>

<AI 根据提取目标和输出格式偏好组织内容>
<如果用户偏好表格，用表格呈现>
<如果用户偏好列表，用列表呈现>
<如果用户偏好时间线，按时间线排列>

---

## 三、转录相关摘要

<与提取目标相关的转录内容摘要，200-300 字>

---

*本报告由 peepshow + MiniMax MCP + Claude Code 自动生成*
```

## 降级模式输出模板（零目标帧时使用）

```markdown
# <标题>（纯转录总结）

> ⚠️ 本视频无与提取目标相关的视觉内容。以下内容基于转录文本整理。

**来源：** <视频文件名>
**时长：** <X 小时 X 分钟>
**提取目标：** <用户的提取目标>

---

## 一、概要

<基于提取目标的内容概述>

---

## 二、提取结果

<基于转录文本整理的提取结果>

---

## 三、转录相关摘要

<与提取目标相关的转录内容摘要>

---

## 附录：完整转录文件

- [完整转录文本](<标题>_transcript.txt)
- [字幕文件](<标题>_transcript.srt)

---

*本报告由 peepshow + whisper.cpp + Claude Code 自动生成（纯转录模式）*
```
```

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/references/custom-mode.md
git commit -m "feat: add custom-mode.md reference for video-analyzer"
```

---

### Task 6: 重写 SKILL.md 主文件

**Files:**
- Rewrite: `video-analyzer/SKILL.md`

这是最核心的步骤。重写 SKILL.md，加入模式选择逻辑，泛化共享流水线，移除硬编码的产品分析内容。

- [ ] **Step 1: 重写 SKILL.md**

```markdown
---
name: video-analyzer
description: "从视频中提取用户想要的内容。支持会议纪要、教学/培训总结、产品演示分析三种预设模式，也支持自然语言描述的自定义提取。当用户提到"分析视频"、"提取视频内容"、"视频总结"、"会议纪要"、"视频转文档"、"总结教学视频"时触发。即使用户没有明确说"视频"，只要上下文涉及视频文件且需要从中提取信息，也应使用此 skill。"
---

# Video Analyzer

从视频中提取用户想要的内容。支持会议纪要、教学/培训总结、产品演示分析三种预设模式，也支持自然语言自定义提取。

## 适用场景

- 会议录制 → 提取决策和行动项
- 教学/培训视频 → 提取知识点和概念
- 产品演示视频 → 提取功能模块和 User Journey
- 任意视频 → 用户自定义提取目标

## 前置依赖

确保以下工具可用（本会话需已安装）：
- `peepshow`（全局 CLI + Claude Code 插件）—— 帧提取 + 转录
- MiniMax MCP `understand_image` —— 图片理解
- `ffmpeg` / `ffprobe` —— 视频信息检查
- `whisper-cli`（whisper.cpp）—— 本地语音转录

## 工作流程

### Step 0: 模式识别

根据用户输入判断提取模式，并读取对应的 references 文件：

| 用户输入关键词 | 模式 | references 文件 |
|---|---|---|
| 会议、meeting、纪要、行动项、action item | 会议纪要 | `references/meeting-mode.md` |
| 教学、培训、课程、知识点、lecture、tutorial | 教学/培训总结 | `references/training-mode.md` |
| 产品、功能、demo、演示、user journey | 产品演示分析 | `references/product-mode.md` |
| 其他 / 用户明确说"提取XXX" | 自定义 | `references/custom-mode.md` |

识别模式后，读取对应 references 文件获取该模式的分析策略和输出模板。

如果用户输入模糊（如"分析这个视频"），主动追问想提取什么内容。

### Step 1: 检查视频信息

```bash
ffprobe -v quiet -show_entries format=duration,size -of csv=p=0 <视频路径>
```

根据时长推断帧提取参数：

| 时长 | `--fps` | `--max` |
|------|---------|---------|
| < 15 min | 0.5 | 30 |
| 15-30 min | 0.3 | 50 |
| 30-60 min | 0.3 | 80 |
| > 60 min | 0.2 | 100 |

### Step 2: 提取关键帧

```bash
export PEEPSHOW_TRANSCRIBE=whisper-cpp
export PEEPSHOW_TRANSCRIBE_MODEL=large-v3-turbo
export PEEPSHOW_TRANSCRIBE_LANGUAGE=zh
export PEEPSHOW_WHISPER_MODEL_DIR=/home/gaoby3/project/video-analysis/models
export PATH="$HOME/bin:$PATH"

PEEPSHOW_CLIENT=claude-code peepshow <视频路径> \
  --fps <按上表> --max <按上表> --width 1280 \
  --transcribe whisper-cpp --no-gpu --emit json --output /tmp/peepshow_video_summary
```

解析 JSON 输出，获取：
- `frames[].path`、`frames[].timestampSeconds`、`video.durationSeconds`、`outputDir`
- `audio.transcript.text`（完整转录文本）
- `audio.transcript.segments[]`（`{start, end, text}` 带时间戳的分段）

### Step 2.5: 转录分析与帧过滤

利用转录文本识别目标内容时间段，过滤掉无关帧，减少无效图像分析。

**2.5a — 保存转录文件**

将 `audio.transcript.text` 保存为 `transcript.txt`，将 segments 按 SRT 格式保存为 `transcript.srt`，放到输出目录。

```bash
# 保存完整转录文本
echo "<transcript.text>" > "<输出目录>/<标题>_transcript.txt"

# 将 segments 转为 SRT 格式保存
# SRT 格式: index\nHH:MM:SS,mmm --> HH:MM:SS,mmm\ntext\n\n
```

**2.5b — 识别目标内容时间段**

阅读完整转录文本，根据当前模式的帧过滤标准（见 references 文件）识别视频的时间线结构：

- **目标段**：包含与提取目标相关内容的片段
- **无关段**：开场寒暄、过渡、闲聊等与提取目标无关的片段

输出目标时间段列表，格式：
```
目标时间段范围：
- 00:02:30 ~ 00:05:00  <内容摘要>
- 00:05:30 ~ 00:12:00  <内容摘要>
- ...
```

**2.5c — 过滤帧列表**

将 peepshow 输出的帧列表映射到时间段：

- 帧时间落在目标段内 → **保留**，进入 Step 3
- 帧时间落在无关段内 → **跳过**（标记原因，写入附录）

边界容忍 ±3 秒。

**2.5d — 模式判定**

- **保留帧数 ≥ 1** → 进入 Step 3（图像分析模式）
- **保留帧数 = 0** → 进入 **Step 3b（纯转录模式）**

**2.5e — 记录跳过的帧**

对跳过的帧按时间段归类，根据转录文本生成一句话摘要，供附录使用。

### Step 3: 分批分析关键帧（仅分析过滤后的帧）

**核心原则：先粗后细。**

**第 1 轮：采样摸底（从过滤后的帧中均匀选择 8-12 帧）**
- 从 frame_0001 开始，每隔 N 帧取 1 帧（使总数 ≤ 12）
- 每帧调用 `mcp__MiniMax__understand_image`，prompt 使用当前模式的帧分析 prompt（见 references 文件）

**第 2 轮：查漏补缺（按需 3-5 帧）**
- 根据第 1 轮结果，识别未覆盖的内容
- 从帧列表中定位对应帧号，补充分析

### Step 3b: 纯转录模式（零目标帧时触发）

跳过图像分析，直接基于转录文本生成报告。

**3b.1 — 转录内容提炼**

阅读完整转录，按当前模式的转录提炼重点（见 references 文件）提取相关内容。

**3b.2 — 生成纯转录报告**

使用当前模式的降级模式输出模板（见 references 文件）。

### Step 4: 生成报告（图像分析模式）

使用当前模式的图像分析模式输出模板（见 references 文件）。

### Step 4.5: 补充附录

在报告末尾追加跳过的时间段附录：

```markdown
---

## 附录：跳过的无关时间段

以下时间段经转录文本分析后判定为与提取目标无关，对应帧未纳入图像分析：

| 时间段 | 转录内容摘要 | 跳过原因 |
|--------|-------------|---------|
| 00:00:00 ~ 00:02:30 | "大家好，欢迎..." | 开场寒暄 |
| ... | ... | ... |
```

### Step 5: 输出文件

- 报告文件默认保存到当前项目工作目录（`$CWD`）
- 图像分析模式：创建 `screenshots/` 子目录，复制引用的关键帧
- 纯转录模式：无截图，跳过 screenshots/ 创建
- 两种模式都输出转录文件

```bash
OUT_DIR="${CWD:-.}"

# 图像分析模式
mkdir -p "$OUT_DIR/screenshots"
cp <引用的frame_paths> "$OUT_DIR/screenshots/"

# 两种模式都输出转录文件
cp <transcript.txt路径> "$OUT_DIR/<标题>_transcript.txt"
cp <transcript.srt路径> "$OUT_DIR/<标题>_transcript.srt"
```

### Step 6: 标注 peepshow 报告

```bash
echo '{"summary":"...","perFrame":[...],"provider":"claude-code","model":"<当前模型>"}' \
  | peepshow report annotate <outputDir>
```

## 注意事项

- **转录环境变量：** 已在 Step 2 命令中内联设置，无需手动配置
- **转录模型：** 中英混合内容必须使用多语言模型（如 `large-v3-turbo`），`.en` 模型不支持中文
- **并行调用：** 帧分析可以并行发起，每批 3-5 个
- **减帧策略：** 连续多帧内容相同时合并为 1 帧描述
- **模型适配：** 当前模型若不支持直接读图，必须使用 MiniMax MCP
- **中文输出：** 报告面向中文用户，所有描述用中文
- **降级模式：** 零目标帧时自动进入纯转录模式
- **隐私安全：** whisper.cpp 完全本地运行，音频不离开本机
- **模式 references：** 所有模式相关的分析策略和模板都在 references/ 目录下，SKILL.md 只包含共享流水线
```

- [ ] **Step 2: 验证 SKILL.md frontmatter 格式正确**

```bash
head -5 /home/gaoby3/project/gaoboy-marketplace/video-analyzer/SKILL.md
```

Expected: 看到 `---`、`name: video-analyzer`、`description:` 开头的 frontmatter

- [ ] **Step 3: Commit**

```bash
git add video-analyzer/SKILL.md
git commit -m "feat: rewrite SKILL.md as video-analyzer with mode selection and shared pipeline"
```

---

### Task 7: 更新 .claude-plugin 配置（如有必要）

**Files:**
- Modify: `video-analyzer/.claude-plugin/` 下的配置文件

- [ ] **Step 1: 检查 .claude-plugin 目录内容**

```bash
ls -la /home/gaoby3/project/gaoboy-marketplace/video-analyzer/.claude-plugin/
cat /home/gaoby3/project/gaoboy-marketplace/video-analyzer/.claude-plugin/*
```

- [ ] **Step 2: 如果有引用 skill name 的配置，更新为 video-analyzer**

检查输出中是否有 `video-product-summary` 字样，如果有则替换为 `video-analyzer`。

- [ ] **Step 3: Commit（如有改动）**

```bash
git add video-analyzer/.claude-plugin/
git commit -m "fix: update plugin config references from video-product-summary to video-analyzer"
```

---

### Task 8: 最终验证

- [ ] **Step 1: 验证完整文件结构**

```bash
find /home/gaoby3/project/gaoboy-marketplace/video-analyzer -type f | sort
```

Expected:
```
video-analyzer/.claude-plugin/...
video-analyzer/SKILL.md
video-analyzer/references/custom-mode.md
video-analyzer/references/meeting-mode.md
video-analyzer/references/product-mode.md
video-analyzer/references/training-mode.md
```

- [ ] **Step 2: 验证 SKILL.md 中不再包含硬编码的产品分析模板**

```bash
grep -c "产品能力介绍\|功能模块详解\|User Journey 全景\|云蝠智能" /home/gaoby3/project/gaoboy-marketplace/video-analyzer/SKILL.md
```

Expected: 0（这些内容已迁移到 references/product-mode.md）

- [ ] **Step 3: 验证 references 文件都存在且非空**

```bash
wc -l /home/gaoby3/project/gaoboy-marketplace/video-analyzer/references/*.md
```

Expected: 每个文件都有内容（行数 > 10）
```

- [ ] **Step 4: 确认 git 状态干净**

```bash
git status
git log --oneline -6
```

Expected: 工作区干净，能看到 5-6 个 commit 组成完整的重构历史
