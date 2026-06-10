#!/usr/bin/env bash
set -Eeuo pipefail

# Template: start the Orin-side robot_client that bridges robot observations
# to a remote GPU policy_server and sends returned actions to the robot host.

CONDA_ENV="${CONDA_ENV:-aloha_lerobot}"
LEROBOT_ROOT="${LEROBOT_ROOT:-/path/to/lerobot}"

ROBOT_TYPE="${ROBOT_TYPE:-lekiwi_client}"
ROBOT_ID="${ROBOT_ID:-aloha_pro_orin}"
ROBOT_MODEL="${ROBOT_MODEL:-alohamini2}"
ROBOT_REMOTE_IP="${ROBOT_REMOTE_IP:-127.0.0.1}"

SERVER_ADDRESS="${SERVER_ADDRESS:-4090_HOST:8080}"
POLICY_TYPE="${POLICY_TYPE:-pi05}"
POLICY_PATH="${POLICY_PATH:-/path/to/exported/pretrained_model}"
TASK="${TASK:-pick up the object and place it in the box}"

FPS="${FPS:-30}"
ACTIONS_PER_CHUNK="${ACTIONS_PER_CHUNK:-50}"
CHUNK_SIZE_THRESHOLD="${CHUNK_SIZE_THRESHOLD:-0.5}"
AGGREGATE_FN_NAME="${AGGREGATE_FN_NAME:-weighted_average}"
POLICY_DEVICE="${POLICY_DEVICE:-cuda}"
CLIENT_DEVICE="${CLIENT_DEVICE:-cpu}"

export PYTHONPATH="${LEROBOT_ROOT}/src${PYTHONPATH:+:${PYTHONPATH}}"

if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.bash hook)"
else
  echo "[ERROR] conda was not found" >&2
  exit 1
fi

conda activate "${CONDA_ENV}"
cd "${LEROBOT_ROOT}"

exec python -m lerobot.async_inference.robot_client \
  --robot.type="${ROBOT_TYPE}" \
  --robot.remote_ip="${ROBOT_REMOTE_IP}" \
  --robot.robot_model="${ROBOT_MODEL}" \
  --robot.id="${ROBOT_ID}" \
  --task="${TASK}" \
  --server_address="${SERVER_ADDRESS}" \
  --policy_type="${POLICY_TYPE}" \
  --pretrained_name_or_path="${POLICY_PATH}" \
  --policy_device="${POLICY_DEVICE}" \
  --client_device="${CLIENT_DEVICE}" \
  --actions_per_chunk="${ACTIONS_PER_CHUNK}" \
  --chunk_size_threshold="${CHUNK_SIZE_THRESHOLD}" \
  --aggregate_fn_name="${AGGREGATE_FN_NAME}" \
  --fps="${FPS}"
