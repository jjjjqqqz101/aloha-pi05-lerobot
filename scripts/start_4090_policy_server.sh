#!/usr/bin/env bash
set -Eeuo pipefail

# Template: start a LeRobot async policy_server on a GPU workstation.
# Keep machine-specific paths in environment variables or local config files.

CONDA_ENV="${CONDA_ENV:-aloha_lerobot}"
LEROBOT_ROOT="${LEROBOT_ROOT:-/path/to/lerobot}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
FPS="${FPS:-30}"
INFERENCE_LATENCY="${INFERENCE_LATENCY:-0.033}"
OBS_QUEUE_TIMEOUT="${OBS_QUEUE_TIMEOUT:-2}"
CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
POLICY_PATH="${POLICY_PATH:-}"

export CUDA_VISIBLE_DEVICES
export PYTHONPATH="${LEROBOT_ROOT}/src${PYTHONPATH:+:${PYTHONPATH}}"
export TOKENIZERS_PARALLELISM="${TOKENIZERS_PARALLELISM:-false}"

die() {
  echo "[ERROR] $*" >&2
  exit 1
}

info() {
  echo "[INFO] $*"
}

[[ -d "${LEROBOT_ROOT}/src/lerobot" ]] || die "Invalid LEROBOT_ROOT: ${LEROBOT_ROOT}"

if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.bash hook)"
else
  die "conda was not found"
fi

conda activate "${CONDA_ENV}"

python - <<'PY'
import torch
print(f"[INFO] torch={torch.__version__}, cuda={torch.cuda.is_available()}")
if not torch.cuda.is_available():
    raise SystemExit("[ERROR] CUDA is not available")
print(f"[INFO] gpu={torch.cuda.get_device_name(0)}")
PY

if [[ -n "${POLICY_PATH}" ]]; then
  [[ -d "${POLICY_PATH}" ]] || die "POLICY_PATH is not a directory: ${POLICY_PATH}"
  for file in config.json model.safetensors policy_preprocessor.json policy_postprocessor.json; do
    [[ -f "${POLICY_PATH}/${file}" ]] || die "Missing ${POLICY_PATH}/${file}"
  done
fi

info "Starting policy_server on ${HOST}:${PORT}"
cd "${LEROBOT_ROOT}"
exec python -m lerobot.async_inference.policy_server \
  --host="${HOST}" \
  --port="${PORT}" \
  --fps="${FPS}" \
  --inference_latency="${INFERENCE_LATENCY}" \
  --obs_queue_timeout="${OBS_QUEUE_TIMEOUT}"
