#!/usr/bin/env bash
set -euo pipefail

VGMTRANS_ROOT="${1:?missing vgmtrans root}"
PSF_PATH="${2:?missing psf path}"
OUT_DIR="${3:?missing out dir}"

mkdir -p "${OUT_DIR}"

echo "VGMTRANS_ROOT=${VGMTRANS_ROOT}"
echo "PSF_PATH=${PSF_PATH}"
echo "OUT_DIR=${OUT_DIR}"

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
  echo "ERROR: vgmtrans-shell not found in known locations." >&2
  echo "Known candidates:" >&2
  printf '  %s\n' "${CANDIDATES[@]}" >&2
  echo "Scanning build tree more deeply:" >&2
  find "${VGMTRANS_ROOT}/build" -maxdepth 8 -type f | sort >&2 || true
  exit 127
fi

echo "SHELL_BIN=${SHELL_BIN}"

if [[ ! -f "${PSF_PATH}" ]]; then
  echo "ERROR: input PSF not found: ${PSF_PATH}" >&2
  exit 2
fi

pushd "${OUT_DIR}" >/dev/null
"${SHELL_BIN}" "${PSF_PATH}"
popd >/dev/null

echo "Generated files:"
find "${OUT_DIR}" -maxdepth 3 -type f | sort
