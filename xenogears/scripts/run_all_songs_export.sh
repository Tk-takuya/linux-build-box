#!/usr/bin/env bash
set -euo pipefail

VGMTRANS_ROOT="${1:?missing vgmtrans root}"
INPUT_ZIP="${2:?missing input zip}"
OUT_DIR="${3:?missing out dir}"

mkdir -p "${OUT_DIR}" "${OUT_DIR}/results"
WORK_DIR="${OUT_DIR}/_work"
PSF_DIR="${WORK_DIR}/psf"

rm -rf "${WORK_DIR}"
mkdir -p "${PSF_DIR}"

CANDIDATES=(
  "${VGMTRANS_ROOT}/build/linux-x64/Release/bin/vgmtrans-shell"
  "${VGMTRANS_ROOT}/build/linux-x64/src/ui/shell/Release/vgmtrans-shell"
  "${VGMTRANS_ROOT}/build/linux-x64/Release/vgmtrans-shell"
)

SHELL_BIN=""
for p in "${CANDIDATES[@]}"; do
  if [[ -f "${p}" ]]; then
    SHELL_BIN="${p}"
    break
  fi
done

if [[ -z "${SHELL_BIN}" ]]; then
  echo "ERROR: vgmtrans-shell not found." >&2
  find "${VGMTRANS_ROOT}/build" -maxdepth 8 -type f | sort >&2 || true
  exit 127
fi

echo "Using shell: ${SHELL_BIN}"
echo "Extracting: ${INPUT_ZIP}"
unzip -qq "${INPUT_ZIP}" -d "${PSF_DIR}"

mapfile -d '' PSFS < <(find "${PSF_DIR}" -type f -iname '*.PSF' -print0 | sort -z)

if [[ ${#PSFS[@]} -eq 0 ]]; then
  echo "ERROR: no PSF files found after extraction" >&2
  exit 2
fi

idx=0
for psf in "${PSFS[@]}"; do
  idx=$((idx+1))
  run_dir="${OUT_DIR}/results/$(printf '%02d' "${idx}")"
  mkdir -p "${run_dir}"

  cat > "${run_dir}/cmds.txt" <<EOF
load "${psf}"
collection list
collection export 0 .
quit
EOF

  echo "=== [$(printf '%02d' "${idx}")] $(basename "${psf}") ==="
  pushd "${run_dir}" >/dev/null
  "${SHELL_BIN}" < cmds.txt > shell.log 2>&1 || true
  popd >/dev/null

  if grep -q "No collections loaded." "${run_dir}/shell.log"; then
    echo "NO_COLLECTION $(basename "${psf}")"
  else
    mid_count=$(find "${run_dir}" -maxdepth 1 -type f -iname '*.mid' | wc -l)
    sf2_count=$(find "${run_dir}" -maxdepth 1 -type f -iname '*.sf2' | wc -l)
    echo "OK $(basename "${psf}") MID=${mid_count} SF2=${sf2_count}"
  fi
done

echo "Batch export finished."
