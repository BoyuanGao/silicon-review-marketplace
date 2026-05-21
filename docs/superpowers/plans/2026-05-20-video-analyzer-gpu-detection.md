# Video Analyzer GPU Detection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automatic GPU detection to video-analyzer, replacing the hardcoded `--no-gpu` flag with dynamic GPU selection for peepshow video decoding.

**Architecture:** A bash wrapper script (`detect-gpu.sh`) probes the system for GPU capability (CUDA, Metal, VAAPI) and outputs environment variables. SKILL.md sources these variables and uses `$PEEPSHOW_GPU_FLAG` in place of the hardcoded `--no-gpu`. Whisper.cpp needs no changes — peepshow already invokes it without GPU flags, letting it auto-detect.

**Tech Stack:** Bash, peepshow CLI, whisper.cpp

---

### Task 1: Create `detect-gpu.sh`

**Files:**
- Create: `video-analyzer/scripts/detect-gpu.sh`

- [ ] **Step 1: Create the scripts directory and write detect-gpu.sh**

```bash
mkdir -p video-analyzer/scripts
```

Write `video-analyzer/scripts/detect-gpu.sh` with this content:

```bash
#!/usr/bin/env bash
# GPU detection for video-analyzer
# Outputs export lines for eval consumption. Fails silently, always falls back to CPU.

set -o pipefail

detect_gpu() {
  # 1. NVIDIA CUDA
  if command -v nvidia-smi &>/dev/null && nvidia-smi -L &>/dev/null 2>&1; then
    echo "cuda"
    return
  fi

  # 2. Apple Metal (macOS)
  if [[ "$(uname -s)" == "Darwin" ]] && command -v system_profiler &>/dev/null; then
    if system_profiler SPDisplaysDataType 2>/dev/null | grep -qi "Metal"; then
      echo "videotoolbox"
      return
    fi
  fi

  # 3. AMD ROCm / Intel VAAPI (Linux)
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command -v rocminfo &>/dev/null && rocminfo &>/dev/null 2>&1; then
      echo "vaapi"
      return
    fi
    if [[ -e /dev/kfd ]]; then
      echo "vaapi"
      return
    fi
    # VAAPI available on most modern Linux systems with Intel/AMD iGPU
    if command -v vainfo &>/dev/null && vainfo &>/dev/null 2>&1; then
      echo "vaapi"
      return
    fi
  fi

  # 4. Fallback to CPU
  echo "off"
}

GPU_TYPE=$(detect_gpu)

case "$GPU_TYPE" in
  cuda)
    PEEPSHOW_GPU_FLAG="--gpu cuda"
    WHISPER_USE_GPU=1
    ;;
  videotoolbox)
    PEEPSHOW_GPU_FLAG="--gpu videotoolbox"
    WHISPER_USE_GPU=1
    ;;
  vaapi)
    PEEPSHOW_GPU_FLAG="--gpu vaapi"
    WHISPER_USE_GPU=1
    ;;
  *)
    PEEPSHOW_GPU_FLAG="--no-gpu"
    WHISPER_USE_GPU=0
    GPU_TYPE="off"
    ;;
esac

cat <<EOF
export PEEPSHOW_GPU_FLAG="${PEEPSHOW_GPU_FLAG}"
export WHISPER_USE_GPU=${WHISPER_USE_GPU}
export GPU_TYPE="${GPU_TYPE}"
EOF
```

- [ ] **Step 2: Make the script executable**

```bash
chmod +x video-analyzer/scripts/detect-gpu.sh
```

- [ ] **Step 3: Verify the script runs without errors**

Run: `bash video-analyzer/scripts/detect-gpu.sh`
Expected: Outputs three export lines with no errors. On this WSL2 system, likely outputs `GPU_TYPE="off"`.

- [ ] **Step 4: Commit**

```bash
git add video-analyzer/scripts/detect-gpu.sh
git commit -m "feat: add GPU detection script for video-analyzer"
```

---

### Task 2: Update SKILL.md — Environment Detection Section

**Files:**
- Modify: `video-analyzer/SKILL.md:17-35`

- [ ] **Step 1: Add GPU detection after the peepshow auto-install block**

Open `video-analyzer/SKILL.md`. After line 29 (the closing `\`\`\`` after the peepshow install check), insert GPU detection code block and status output.

The existing lines 23-35 are:

```markdown
```bash
# 检测 peepshow 是否已安装
if ! command -v peepshow &> /dev/null; then
  echo "peepshow 未安装，正在通过 npm 自动安装..."
  npm i -g peepshow
fi
\```

确保以下工具可用：
- `peepshow`（全局 CLI + Claude Code 插件）—— 帧提取 + 转录
- MiniMax MCP `understand_image` —— 图片理解
- `ffmpeg` / `ffprobe` —— 视频信息检查
- `whisper-cli`（whisper.cpp）—— 本地语音转录
```

Replace with:

```markdown
```bash
# 检测 peepshow 是否已安装
if ! command -v peepshow &> /dev/null; then
  echo "peepshow 未安装，正在通过 npm 自动安装..."
  npm i -g peepshow
fi

# 检测 GPU 环境，输出 PEEPSHOW_GPU_FLAG / WHISPER_USE_GPU / GPU_TYPE
eval $(bash "$(dirname "$0")/scripts/detect-gpu.sh")
echo "GPU: $GPU_TYPE | peepshow: $PEEPSHOW_GPU_FLAG | whisper GPU: $([ "$WHISPER_USE_GPU" = 1 ] && echo on || echo off)"
\```

确保以下工具可用：
- `peepshow`（全局 CLI + Claude Code 插件）—— 帧提取 + 转录
- MiniMax MCP `understand_image` —— 图片理解
- `ffmpeg` / `ffprobe` —— 视频信息检查
- `whisper-cli`（whisper.cpp）—— 本地语音转录（自动检测 GPU）
```

- [ ] **Step 2: Verify the edit is correct**

Review the modified section — ensure the code fence boundaries (`\`\`\``) are correct and the new lines don't break the markdown structure.

- [ ] **Step 3: Commit**

```bash
git add video-analyzer/SKILL.md
git commit -m "feat: add GPU detection step to environment setup in SKILL.md"
```

---

### Task 3: Update SKILL.md — Step 2 Command

**Files:**
- Modify: `video-analyzer/SKILL.md:69-81`

- [ ] **Step 1: Replace hardcoded `--no-gpu` with `$PEEPSHOW_GPU_FLAG`**

The existing Step 2 command (lines 71-81):

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

Replace line 80 (`--transcribe whisper-cpp --no-gpu --emit json --output`) with the dynamic flag:

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

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/SKILL.md
git commit -m "feat: replace hardcoded --no-gpu with dynamic GPU flag in Step 2"
```

---

### Task 4: Update SKILL.md — Notes Section

**Files:**
- Modify: `video-analyzer/SKILL.md:282`

- [ ] **Step 1: Replace the existing transcription env-var note**

Existing line 282:

```
- **转录环境变量：** 已在 Step 2 命令中内联设置，无需手动配置
```

Replace with:

```
- **GPU 加速：** `scripts/detect-gpu.sh` 自动检测 GPU（CUDA / Metal / VAAPI）并配置 peepshow 视频解码加速。whisper.cpp 自动检测 GPU，无需额外配置。无 GPU 时自动回退 CPU。可通过 `GPU_TYPE=off eval $(bash scripts/detect-gpu.sh)` 强制 CPU 模式
- **转录环境变量：** 已在 Step 2 命令中内联设置，无需手动配置
```

- [ ] **Step 2: Commit**

```bash
git add video-analyzer/SKILL.md
git commit -m "docs: update GPU acceleration notes in SKILL.md"
```

---

### Task 5: End-to-End Verification

- [ ] **Step 1: Run detect-gpu.sh standalone**

Run: `bash video-analyzer/scripts/detect-gpu.sh`
Expected: Three export lines with no errors.

- [ ] **Step 2: Verify eval integration works**

Run: `eval $(bash video-analyzer/scripts/detect-gpu.sh) && echo "GPU_TYPE=$GPU_TYPE PEEPSHOW_GPU_FLAG=$PEEPSHOW_GPU_FLAG WHISPER_USE_GPU=$WHISPER_USE_GPU"`
Expected: All three variables are set and printed.

- [ ] **Step 3: Verify GPU_TYPE=off override works**

Run: `GPU_TYPE=off eval $(bash video-analyzer/scripts/detect-gpu.sh) && echo "PEEPSHOW_GPU_FLAG=$PEEPSHOW_GPU_FLAG"`
Expected: `PEEPSHOW_GPU_FLAG=--no-gpu`

- [ ] **Step 4: Review all SKILL.md changes as a whole**

Read `video-analyzer/SKILL.md` from start to end to confirm:
- No broken markdown structure
- Code fence boundaries correct
- The three modified sections (environment detection, Step 2, notes) are consistent with each other
- No remaining references to hardcoded `--no-gpu`

- [ ] **Step 5: Commit if any additional fixes made**

```bash
git add video-analyzer/SKILL.md
git commit -m "chore: final review and cleanup of GPU detection integration"
```
