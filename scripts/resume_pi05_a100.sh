#!/usr/bin/env bash
set -Eeuo pipefail

# Template: resume Pi0.5 training from a LeRobot checkpoint.

CONDA_ENV="${CONDA_ENV:-aloha_lerobot_pi05}"
LEROBOT_ROOT="${LEROBOT_ROOT:-/path/to/lerobot}"
OUTPUT_DIR="${OUTPUT_DIR:-/path/to/outputs/aloha_pi05}"
GPUS="${GPUS:-0}"
NUM_PROCESSES="$(awk -F',' '{print NF}' <<< "${GPUS}")"
MIXED_PRECISION="${MIXED_PRECISION:-bf16}"

export CUDA_VISIBLE_DEVICES="${GPUS}"

if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.bash hook)"
else
  echo "[ERROR] conda was not found" >&2
  exit 1
fi

conda activate "${CONDA_ENV}"
cd "${LEROBOT_ROOT}"

CONFIG_PATH="${OUTPUT_DIR}/checkpoints/last/pretrained_model/train_config.json"
STATE_DIR="${OUTPUT_DIR}/checkpoints/last/training_state"
[[ -f "${CONFIG_PATH}" ]] || { echo "[ERROR] Missing resume config: ${CONFIG_PATH}" >&2; exit 1; }
[[ -d "${STATE_DIR}" ]] || { echo "[ERROR] Missing training_state: ${STATE_DIR}" >&2; exit 1; }

accelerate launch \
  --num_processes="${NUM_PROCESSES}" \
  --mixed_precision="${MIXED_PRECISION}" \
  "$(which lerobot-train)" \
  --config_path="${CONFIG_PATH}" \
  --resume=true
