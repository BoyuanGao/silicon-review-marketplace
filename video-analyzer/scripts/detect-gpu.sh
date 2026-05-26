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

if [ -z "${GPU_TYPE:-}" ]; then
  GPU_TYPE=$(detect_gpu)
fi

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
