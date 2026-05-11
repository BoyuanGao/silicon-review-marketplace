---
name: video-product-summary
description: "分析产品介绍/演示类会议视频，提取功能模块、使用场景和 User Journey，输出带截图的 Markdown 结构化报告。触发词：分析产品视频、提取功能模块、产品会议总结、视频转产品文档。"
---

# Video Product Summary

从产品介绍/演示类会议视频中提取功能模块、使用场景和 User Journey，输出结构化 Markdown 报告。

## 适用场景

- 产品演示会议录制
- SaaS 产品能力介绍
- 软件系统功能培训
- 销售 Demo 录像分析

## 前置依赖

确保以下工具可用（本会话需已安装）：
- `peepshow`（全局 CLI + Claude Code 插件）—— 帧提取 + 转录
- MiniMax MCP `understand_image` —— 图片理解
- `ffmpeg` / `ffprobe` —— 视频信息检查
- `whisper-cli`（whisper.cpp）—— 本地语音转录

## 工作流程

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

利用转录文本识别产品功能时间段，过滤掉非功能场景的帧，减少无效图像分析。

**2.5a — 保存转录文件**

将 `audio.transcript.text` 保存为 `transcript.txt`，将 segments 按 SRT 格式保存为 `transcript.srt`，放到输出目录。

```bash
# 保存完整转录文本
echo "<transcript.text>" > "<输出目录>/<产品名称>_transcript.txt"

# 将 segments 转为 SRT 格式保存（每条记录编号 + 时间戳 + 文本）
# SRT 格式: index\nHH:MM:SS,mmm --> HH:MM:SS,mmm\ntext\n\n
```

**2.5b — 识别产品功能时间段**

阅读完整转录文本 `audio.transcript.text`，根据对话内容识别视频的时间线结构：

- **功能演示段**：讲解功能模块、操作演示、界面展示的片段
- **非功能段**：开场寒暄、嘉宾介绍、会议总结/感谢、Q&A 闲聊、纯过渡画面

输出产品功能时间段列表，格式：
```
功能段时间范围：
- 00:02:30 ~ 00:05:00  群呼任务管理
- 00:05:30 ~ 00:12:00  智能话术配置
- ...
```

**2.5c — 过滤帧列表**

将 peepshow 输出的帧列表（每帧带有 `timestampSeconds`）映射到功能时间段：

- 帧时间落在功能段内 → **保留**，进入 Step 3
- 帧时间落在非功能段内 → **跳过**（标记原因，写入附录）

边界容忍 ±3 秒，避免漏掉界面切换前的内容。

**2.5d — 模式判定**

过滤后统计保留帧数量：

- **保留帧数 ≥ 1** → 进入 Step 3（图像分析模式），正常分析产品 UI 截图
- **保留帧数 = 0** → 说明视频只有人头像录屏、PPT 静止页或纯语音讨论，不存在产品 UI → 进入 **Step 3b（纯会议讨论模式）**

**2.5e — 记录跳过的帧**

对跳过的帧，按时间段归类，根据转录文本生成一句话摘要，供报告附录使用。例如：

> 00:00 ~ 02:30：开场寒暄与产品背景介绍，无功能演示界面

### Step 3: 分批分析关键帧（仅分析过滤后的帧）

**核心原则：先粗后细。** 不要一次性分析所有帧，分两轮：

**第 1 轮：采样摸底（从过滤后的帧中均匀选择 8-12 帧）**
- 从 frame_0001 开始，每隔 N 帧取 1 帧（使总数 ≤ 12）
- 每帧调用 `mcp__MiniMax__understand_image`，prompt 统一使用：

```
云蝠智能产品演示。请描述画面中的内容。重点关注：
1. 产品功能模块名称（左侧菜单、顶部标签、按钮文字）
2. 正在演示的具体功能（筛选条件、话术配置、数据看板等）
3. 界面上的关键数据和文字
4. 对应的业务使用场景
用中文回答，简明扼要。如果画面没有变化（如PPT静止页），说明即可。
```

**第 2 轮：查漏补缺（按需 3-5 帧）**
- 根据第 1 轮结果，识别未覆盖的模块
- 从帧列表中定位对应帧号，补充分析

### Step 3b: 纯会议讨论模式（零功能帧时触发）

当过滤后保留帧数为 0 时，跳过全部图像分析，直接基于转录文本生成报告。

**3b.1 — 转录内容提炼**

阅读 `audio.transcript.text` 完整转录，从中提取产品相关信息：

- 产品名称、定位、解决的问题
- 提到的功能模块及其作用描述
- 典型使用场景和用户角色
- 提到的技术特点或竞争优势
- 行业案例或客户故事

**3b.2 — 生成纯转录报告**

按以下模板输出 Markdown 文件（无截图、无图像分析）：

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

### Step 4: 生成报告（图像分析模式）

综合所有帧分析结果，按以下模板输出 Markdown 文件：

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

### Step 4.5: 补充附录

在报告末尾追加跳过的时间段附录：

```markdown
---

## 附录：跳过的非功能时间段

以下时间段经转录文本分析后判定为非产品功能演示内容，对应帧未纳入图像分析：

| 时间段 | 转录内容摘要 | 跳过原因 |
|--------|-------------|---------|
| 00:00:00 ~ 00:02:30 | "大家好，欢迎参加今天的会议..." | 开场寒暄与背景介绍 |
| ... | ... | ... |
```

### Step 5: 输出文件

- 报告文件默认保存到当前项目工作目录（`$CWD`），即会话启动时所在的项目根目录
- 创建 `screenshots/` 子目录，复制引用的关键帧
- 文件名格式：`<产品名称>产品能力介绍.md`

```bash
# 默认输出到项目工作目录
OUT_DIR="${CWD:-.}"

# 图像分析模式：复制引用截图
mkdir -p "$OUT_DIR/screenshots"
cp <引用的frame_paths> "$OUT_DIR/screenshots/"

# 纯会议讨论模式：无截图，跳过 screenshots/ 创建
# 两种模式都输出转录文件
cp <transcript.txt路径> "$OUT_DIR/<产品名称>_transcript.txt"
cp <transcript.srt路径> "$OUT_DIR/<产品名称>_transcript.srt"
```

### Step 6: 标注 peepshow 报告

```bash
echo '{"summary":"...","perFrame":[...],"provider":"claude-code","model":"<当前模型>"}' \
  | peepshow report annotate <outputDir>
```

## 注意事项

- **转录环境变量：** `PEEPSHOW_TRANSCRIBE`、`PEEPSHOW_TRANSCRIBE_MODEL`、`PEEPSHOW_TRANSCRIBE_LANGUAGE`、`PEEPSHOW_WHISPER_MODEL_DIR` 已在 Step 2 命令中内联设置，无需手动配置
- **转录模型：** 中英混合内容必须使用多语言模型（如 `large-v3-turbo`），`.en` 模型不支持中文
- **并行调用：** 帧分析可以并行发起（无依赖），每批 3-5 个同时进行
- **减帧策略：** 如果 N 帧中连续多帧内容相同（如静止 PPT），合并为 1 帧描述，节省分析成本；转录过滤后的帧池已排除非功能场景
- **模型适配：** 当前模型若不支持直接读图，必须使用 MiniMax MCP `understand_image` 工具
- **中文输出：** 报告面向中文用户，所有描述用中文
- **帧过滤容忍度：** 功能段边界 ±3 秒，避免漏掉界面切换前的内容
- **降级模式：** 当过滤后零功能帧（如纯人头录屏/PPT），自动进入 Step 3b 纯会议讨论模式，基于转录生成报告，零 API 调用
- **隐私安全：** whisper.cpp 完全本地运行，音频不离开本机
