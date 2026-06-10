#!/usr/bin/env bash
set -Eeuo pipefail

# Template: train Pi0.5 with LeRobot on an A100 machine.
# Replace paths through environment variables. Do not commit local values.

CONDA_ENV="${CONDA_ENV:-aloha_lerobot_pi05}"
LEROBOT_ROOT="${LEROBOT_ROOT:-/path/to/lerobot}"

DATASET_REPO_ID="${DATASET_REPO_ID:-local/aloha_clean_dataset}"
DATASET_ROOT="${DATASET_ROOT:-/path/to/datasets/aloha_clean_dataset}"
PRETRAINED_PATH="${PRETRAINED_PATH:-/path/to/checkpoints/pi05_base}"
OUTPUT_DIR="${OUTPUT_DIR:-/path/to/outputs/aloha_pi05}"
JOB_NAME="${JOB_NAME:-aloha_pi05}"

GPUS="${GPUS:-0}"
NUM_PROCESSES="$(awk -F',' '{print NF}' <<< "${GPUS}")"
STEPS="${STEPS:-50000}"
BATCH_SIZE="${BATCH_SIZE:-16}"
SAVE_FREQ="${SAVE_FREQ:-5000}"
LOG_FREQ="${LOG_FREQ:-50}"
MIXED_PRECISION="${MIXED_PRECISION:-bf16}"
WANDB_MODE="${WANDB_MODE:-offline}"
WANDB_PROJECT="${WANDB_PROJECT:-aloha_pi05}"

export CUDA_VISIBLE_DEVICES="${GPUS}"
export WANDB_MODE
export WANDB_PROJECT

if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.bash hook)"
else
  echo "[ERROR] conda was not found" >&2
  exit 1
fi

conda activate "${CONDA_ENV}"
cd "${LEROBOT_ROOT}"

[[ -d "${DATASET_ROOT}" ]] || { echo "[ERROR] Missing dataset: ${DATASET_ROOT}" >&2; exit 1; }
[[ -d "${PRETRAINED_PATH}" ]] || { echo "[ERROR] Missing pretrained path: ${PRETRAINED_PATH}" >&2; exit 1; }

LOG_DIR="$(dirname "${OUTPUT_DIR}")/_logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/${JOB_NAME}.$(date +%Y%m%d_%H%M%S).log"

accelerate launch \
  --num_processes="${NUM_PROCESSES}" \
  --mixed_precision="${MIXED_PRECISION}" \
  "$(which lerobot-train)" \
  --dataset.repo_id="${DATASET_REPO_ID}" \
  --dataset.root="${DATASET_ROOT}" \
  --dataset.video_backend=pyav \
  --dataset.use_imagenet_stats=false \
  --policy.type=pi05 \
  --policy.pretrained_path="${PRETRAINED_PATH}" \
  --policy.push_to_hub=false \
  --policy.device=cuda \
  --policy.dtype=bfloat16 \
  --policy.gradient_checkpointing=true \
  --policy.compile_model=false \
  --policy.freeze_vision_encoder=false \
  --policy.train_expert_only=false \
  --policy.normalization_mapping="{ACTION: MEAN_STD, STATE: MEAN_STD, VISUAL: IDENTITY}" \
  --output_dir="${OUTPUT_DIR}" \
  --job_name="${JOB_NAME}" \
  --steps="${STEPS}" \
  --batch_size="${BATCH_SIZE}" \
  --save_freq="${SAVE_FREQ}" \
  --log_freq="${LOG_FREQ}" \
  --eval_freq=0 \
  --wandb.enable=true \
  --wandb.project="${WANDB_PROJECT}" \
  --wandb.mode="${WANDB_MODE}" \
  --wandb.disable_artifact=true \
  2>&1 | tee "${LOG_FILE}"
