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

## 前置依赖与环境检测

### 环境检测与自动安装

首次使用或检测到缺失时，自动安装依赖：

```bash
# 检测 peepshow 是否已安装
if ! command -v peepshow &> /dev/null; then
  echo "peepshow 未安装，正在通过 npm 自动安装..."
  npm i -g peepshow
fi

# 检测 GPU 环境，输出 PEEPSHOW_GPU_FLAG / WHISPER_USE_GPU / GPU_TYPE
eval $(bash "video-analyzer/scripts/detect-gpu.sh")
echo "GPU: $GPU_TYPE | peepshow: $PEEPSHOW_GPU_FLAG | whisper GPU: $([ "$WHISPER_USE_GPU" = 1 ] && echo on || echo off)"
```

确保以下工具可用：
- `peepshow`（全局 CLI + Claude Code 插件）—— 帧提取 + 转录
- MiniMax MCP `understand_image` —— 图片理解
- `ffmpeg` / `ffprobe` —— 视频信息检查
- `whisper-cli`（whisper.cpp）—— 本地语音转录（自动检测 GPU）

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
  $PEEPSHOW_GPU_FLAG \
  --transcribe whisper-cpp --emit json --output /tmp/peepshow_video_summary
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

**3b.2 — 生成纯转录 HTML 报告**

使用当前模式的降级模式输出模板（见 references 文件），生成自包含 HTML 文件。警告横幅和转录文件附录按模板自动包含。

## 共享 HTML 基础样式

所有模式的 HTML 输出共用以下内联 CSS 基础样式。每个模式的模板在此基础上叠加模式专属配色。

### 排版与布局

- 字体：`font-family: system-ui, -apple-system, sans-serif`
- 页面背景：`background: #fafbfc`，内容区 `max-width: 860px; margin: 0 auto; padding: 32px 40px`
- h1：`font-size: 26px; font-weight: 700; color: #0f172a; margin-bottom: 6px`
- h2：`font-size: 18px; color: #0f172a; margin: 28px 0 12px`，左侧带 4px 宽 20px 高彩色竖线标记（`<span style="background: <模式色>; width:4px; height:20px; border-radius:2px; display:inline-block;"></span>`）
- 正文：`font-size: 14px; color: #1e293b; line-height: 1.6`

### 区块面板

- 高亮面板：`background: <浅色渐变>; border-radius: 10px; padding: 16px 20px; border-left: 3px solid <模式色>; margin-bottom: 24px`
- 折叠面板：`<details open>` + `<summary style="padding: 14px 16px; cursor: pointer; font-weight: 600; font-size: 14px; background: #fafbfc;">`，默认展开
- 普通面板：`background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); padding: 14px 16px`

### 表格

- 表头：`background: <模式浅色>; text-align: left; padding: 10px 14px; font-size: 12px; text-transform: uppercase; font-weight: 600`
- 单元格：`padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 14px`
- 整表：`width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04)`

### 交互组件

- **可勾选行动项** — 用原生 `<input type="checkbox">`，添加 `onchange` 内联 JS 切换完成态（删除线 + 灰色文字）：
  ```html
  <input type="checkbox" style="width:18px; height:18px; accent-color:#10b981; cursor:pointer;"
    onchange="var t=this.parentElement.querySelector('.task-text');if(this.checked){t.style.textDecoration='line-through';t.style.color='#94a3b8';}else{t.style.textDecoration='none';t.style.color='inherit';}">
  ```
- **可折叠面板** — 用原生 `<details><summary>`，零 JS。默认 `open` 属性展开。

### 页脚

```html
<div style="margin-top: 32px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 12px; color: #94a3b8; text-align: center;">
  Generated by video-analyzer · <生成时间>
</div>
```

### 打印样式

在 `<head>` 的 `<style>` 中添加：
```css
@media print {
  details > summary { list-style: none; }
  details > summary::-webkit-details-marker { display: none; }
  body { background: #fff; }
}
```

### 模式专属配色

| 模式 | 主色 | 浅色背景 | 辅色 |
|------|------|---------|------|
| 会议纪要 | `#3b82f6` | `#eff6ff` | 绿=行动项 `#10b981`, 红=待跟进 `#fecaca` |
| 产品分析 | `#8b5cf6` | `#faf5ff` | — |
| 教学总结 | `#16a34a` | `#f0fdf4` | 黄=警告 `#fef3c7` |
| 自定义 | `#6b7280` | `#f3f4f6` | — |

### Step 4: 生成 HTML 报告（图像分析模式）

使用当前模式的图像分析模式 HTML 输出模板（见 references 文件）生成自包含 HTML 文件。模板中的 `<style>` 标签包含该模式完整的内联 CSS，报告可在浏览器中离线打开。

**输出要求：**
- 报告必须是以 `<!DOCTYPE html>` 开头的完整自包含 HTML 文件
- 所有 CSS 内联在 `<style>` 标签中，无外部引用
- 截图引用格式：`<img src="screenshots/<文件名>" alt="<描述>" style="max-width:100%; border-radius:6px;">`
- checkbox 行动项需包含 `onchange` 内联 JS 实现勾选切换效果
- 讨论区/章节使用 `<details open>` 折叠面板，默认展开

### Step 4.5: 补充附录

在 HTML 报告的 `<footer>` 之前追加跳过的时间段附录：

```html
<h2><span class="section-bar" style="background:#e2e8f0;"></span>附录：跳过的无关时间段</h2>
<p style="font-size:13px; color:#94a3b8; margin-bottom:12px;">以下时间段经转录文本分析后判定为与提取目标无关，对应帧未纳入图像分析：</p>
<table>
  <thead><tr><th>时间段</th><th>转录内容摘要</th><th>跳过原因</th></tr></thead>
  <tbody>
    <tr><td>00:00:00 ~ 00:02:30</td><td>"大家好，欢迎..."</td><td>开场寒暄</td></tr>
    <!-- ... -->
  </tbody>
</table>
```

将此 HTML 片段插入到 `<footer>` 之前。

### Step 5: 输出文件

- HTML 报告文件默认保存到当前项目工作目录（`$CWD`），文件名 `<标题>.html`
- 图像分析模式：创建 `screenshots/` 子目录，复制引用的关键帧
- 纯转录模式：无截图，跳过 screenshots/ 创建
- 两种模式都输出转录文件

```bash
OUT_DIR="${CWD:-.}"

# 保存 HTML 报告
# （报告内容由 AI 生成，写入 $OUT_DIR/<标题>.html）

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

- **GPU 加速：** `scripts/detect-gpu.sh` 自动检测 GPU（CUDA / Metal / VAAPI）并配置 peepshow 视频解码加速。whisper.cpp 自动检测 GPU，无需额外配置。无 GPU 时自动回退 CPU。可通过 `GPU_TYPE=off eval $(bash scripts/detect-gpu.sh)` 强制 CPU 模式
- **转录环境变量：** 已在 Step 2 命令中内联设置，无需手动配置
- **转录模型：** 中英混合内容必须使用多语言模型（如 `large-v3-turbo`），`.en` 模型不支持中文
- **并行调用：** 帧分析可以并行发起，每批 3-5 个
- **减帧策略：** 连续多帧内容相同时合并为 1 帧描述
- **模型适配：** 当前模型若不支持直接读图，必须使用 MiniMax MCP
- **中文输出：** 报告面向中文用户，所有描述用中文
- **降级模式：** 零目标帧时自动进入纯转录模式
- **隐私安全：** whisper.cpp 完全本地运行，音频不离开本机
- **模式 references：** 所有模式相关的分析策略和模板都在 references/ 目录下，SKILL.md 只包含共享流水线
