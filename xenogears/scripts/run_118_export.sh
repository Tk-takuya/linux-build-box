#!/usr/bin/env bash
set -euo pipefail

VGMTRANS_ROOT="${1:?missing vgmtrans root}"
PSF_PATH="${2:?missing psf path}"
OUT_DIR="${3:?missing out dir}"

SHELL_BIN="${VGMTRANS_ROOT}/build/linux-x64/Release/bin/vgmtrans-shell"

mkdir -p "${OUT_DIR}"

echo "VGMTRANS_ROOT=${VGMTRANS_ROOT}"
echo "PSF_PATH=${PSF_PATH}"
echo "OUT_DIR=${OUT_DIR}"
echo "SHELL_BIN=${SHELL_BIN}"

if [[ ! -f "${SHELL_BIN}" ]]; then
  echo "ERROR: vgmtrans-shell not found: ${SHELL_BIN}" >&2
  echo "Existing files near build root:" >&2
  find "${VGMTRANS_ROOT}/build" -maxdepth 5 -type f 2>/dev/null | sort >&2 || true
  exit 127
fi

if [[ ! -f "${PSF_PATH}" ]]; then
  echo "ERROR: input PSF not found: ${PSF_PATH}" >&2
  exit 2
fi

pushd "${OUT_DIR}" >/dev/null

"${SHELL_BIN}" "${PSF_PATH}"

popd >/dev/null

echo "Generated files:"
find "${OUT_DIR}" -maxdepth 2 -type f | sort
