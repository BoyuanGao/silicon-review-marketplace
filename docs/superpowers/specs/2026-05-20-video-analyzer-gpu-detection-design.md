# Video Analyzer GPU Detection Design

Date: 2026-05-20
Status: approved

## Purpose

Detect whether the user's environment supports GPU acceleration, and automatically configure peepshow (video decoding) and whisper.cpp (audio transcription) to use GPU when available. Fall back to CPU when no GPU is found.

## Decisions

1. **Wrapper script** — `video-analyzer/scripts/detect-gpu.sh` as a standalone file, not inline in SKILL.md
2. **Separate control for peepshow and whisper.cpp** — each independently configured via env vars
3. **whisper.cpp auto-selects GPU** — no `-ngl` flag passed; GPU-capable builds auto-detect
4. **GPU types** — auto-detect CUDA, Metal (Apple), VAAPI (Linux AMD/Intel), or fall back to CPU
5. **Integration** — `eval $(bash scripts/detect-gpu.sh)` in SKILL.md, outputs env vars consumed by the peepshow command

## Architecture

```
detect-gpu.sh
  ├── detects: nvidia-smi → CUDA
  ├── detects: macOS system_profiler → videotoolbox
  ├── detects: rocminfo or /dev/kfd → vaapi
  └── fallback: CPU (off)
         │
         ▼ outputs 3 env vars
  export PEEPSHOW_GPU_FLAG="--gpu cuda"  (or --gpu videotoolbox / --no-gpu)
  export WHISPER_USE_GPU=1               (1=GPU available, 0=CPU only)
  export GPU_TYPE="cuda"                 (cuda/videotoolbox/vaapi/off)
```

## Components

### 1. `video-analyzer/scripts/detect-gpu.sh` (new)

- Pure bash, no dependencies beyond system tools (nvidia-smi, system_profiler, rocminfo)
- Idempotent, re-runnable
- Fails silently — any detection failure falls back to CPU
- Outputs three `export` lines to stdout for `eval` consumption

GPU detection priority:
1. `nvidia-smi` available and returns GPU info → CUDA
2. macOS with `system_profiler SPDisplaysDataType` reporting "Metal" → videotoolbox
3. `rocm-smi` available or `/dev/kfd` exists → vaapi
4. None of the above → off (CPU)

### 2. SKILL.md modifications

#### 2a. Environment detection section

After peepshow auto-install, add GPU detection:

```bash
eval $(bash "$(dirname "$0")/scripts/detect-gpu.sh")
echo "GPU: $GPU_TYPE | peepshow: $PEEPSHOW_GPU_FLAG | whisper GPU: $([ "$WHISPER_USE_GPU" = 1 ] && echo on || echo off)"
```

#### 2b. Step 2 — peepshow command

Replace hardcoded `--no-gpu` with dynamic variables:

```bash
# CPU 回退时覆盖 whisper-cli 传参 --no-gpu
if [ "$WHISPER_USE_GPU" = "0" ]; then
  export PEEPSHOW_TRANSCRIBE_CMD="whisper-cli --no-gpu"
fi

PEEPSHOW_CLIENT=claude-code peepshow <视频路径> \
  --fps <按上表> --max <按上表> --width 1280 \
  $PEEPSHOW_GPU_FLAG \
  --transcribe whisper-cpp --emit json --output /tmp/peepshow_video_summary
```

- `$PEEPSHOW_GPU_FLAG`: controls peepshow's ffmpeg hwaccel (video decoding)
- `PEEPSHOW_TRANSCRIBE_CMD`: when GPU is unavailable, passes `--no-gpu` to whisper-cli; when GPU is available, unset so whisper.cpp auto-selects

#### 2c. Notes section

Replace existing "转录环境变量" note with GPU acceleration note:

> - **GPU 加速：** `scripts/detect-gpu.sh` 自动检测 GPU 并设置环境变量，无需手动配置。支持 CUDA/Metal/VAAPI，无 GPU 时自动回退 CPU。可通过 `GPU_TYPE=off eval $(bash scripts/detect-gpu.sh)` 强制 CPU 模式

### 3. Error Handling

- GPU detection failure → silent fallback to CPU, no interruption
- whisper.cpp binary not GPU-capable (wrong build) → whisper.cpp falls back to CPU on its own
- `whisper-cli` not on PATH → peepshow's existing handling kicks in (`PEEPSHOW_WHISPER_CPP` search)

### 4. Testing

Manual verification on target platforms:
- Linux + NVIDIA GPU: confirms `--gpu cuda` and whisper.cpp uses CUDA
- macOS + Apple Silicon: confirms `--gpu videotoolbox` and whisper.cpp uses Metal
- No GPU environment: confirms `--no-gpu` and whisper.cpp `--no-gpu`
- `GPU_TYPE=off` forced override: confirms CPU-only path

## Affected Files

| File | Change |
|------|--------|
| `video-analyzer/scripts/detect-gpu.sh` | New — GPU detection script |
| `video-analyzer/SKILL.md` | Modify — "前置依赖与环境检测" section, Step 2 command, 注意事项 |
