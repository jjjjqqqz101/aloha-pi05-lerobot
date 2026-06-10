#!/usr/bin/env bash
set -Eeuo pipefail

# Template: clean bad episodes and merge LeRobot datasets.
# BAD_EPISODES_FILE format:
#   dataset_01: 1 3 4
#   dataset_02:

SRC_ROOT="${SRC_ROOT:-/path/to/raw_datasets}"
TMP_ROOT="${TMP_ROOT:-/path/to/clean_tmp}"
OUT_ROOT="${OUT_ROOT:-/path/to/merged_dataset}"
BAD_EPISODES_FILE="${BAD_EPISODES_FILE:-bad_episodes.txt}"

[[ -f "${BAD_EPISODES_FILE}" ]] || {
  echo "[ERROR] Missing BAD_EPISODES_FILE: ${BAD_EPISODES_FILE}" >&2
  exit 1
}

command -v lerobot-edit-dataset >/dev/null 2>&1 || {
  echo "[ERROR] lerobot-edit-dataset not found" >&2
  exit 1
}

[[ ! -e "${OUT_ROOT}" ]] || {
  echo "[ERROR] OUT_ROOT already exists: ${OUT_ROOT}" >&2
  exit 1
}

rm -rf "${TMP_ROOT}"
mkdir -p "${TMP_ROOT}"

repo_ids=()
roots=()

while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "${line}" | xargs || true)"
  [[ -n "${line}" ]] || continue
  name="${line%%:*}"
  bad="${line#*:}"
  name="$(echo "${name}" | xargs)"
  bad="$(echo "${bad}" | xargs || true)"

  src="${SRC_ROOT}/${name}"
  [[ -d "${src}" ]] || { echo "[ERROR] Missing dataset: ${src}" >&2; exit 1; }

  if [[ -n "${bad}" ]]; then
    dst="${TMP_ROOT}/${name}_clean"
    indices="[$(echo "${bad}" | sed 's/ /, /g')]"
    echo "[clean] ${name}: ${indices}"
    lerobot-edit-dataset \
      --repo_id "local/${name}" \
      --root "${src}" \
      --new_repo_id "local/${name}_clean" \
      --new_root "${dst}" \
      --operation.type delete_episodes \
      --operation.episode_indices "${indices}"
    repo_ids+=("local/${name}_clean")
    roots+=("${dst}")
  else
    echo "[keep] ${name}"
    repo_ids+=("local/${name}")
    roots+=("${src}")
  fi
done < "${BAD_EPISODES_FILE}"

join_items() {
  local out=""
  for item in "$@"; do
    if [[ -z "${out}" ]]; then out="'${item}'"; else out="${out}, '${item}'"; fi
  done
  echo "[${out}]"
}

lerobot-edit-dataset \
  --new_repo_id "local/merged_dataset" \
  --new_root "${OUT_ROOT}" \
  --operation.type merge \
  --operation.repo_ids "$(join_items "${repo_ids[@]}")" \
  --operation.roots "$(join_items "${roots[@]}")"
