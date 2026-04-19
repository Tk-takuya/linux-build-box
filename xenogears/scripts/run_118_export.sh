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
  printf '  %s
' "${CANDIDATES[@]}" >&2
  find "${VGMTRANS_ROOT}/build" -maxdepth 8 -type f | sort >&2 || true
  exit 127
fi

echo "SHELL_BIN=${SHELL_BIN}"

if [[ ! -f "${PSF_PATH}" ]]; then
  echo "ERROR: input PSF not found: ${PSF_PATH}" >&2
  exit 2
fi

pushd "${OUT_DIR}" >/dev/null

cat > shell_commands.txt <<EOF
load "${PSF_PATH}"
collection list
instrumentset list
sequence list
collection export 0 .
quit
EOF

echo "=== shell_commands.txt ==="
cat shell_commands.txt

"${SHELL_BIN}" < shell_commands.txt | tee shell_output.txt

# Normalize output names so downstream steps can rely on shinnyu.mid/sf2.
MID_COUNT=$(find . -maxdepth 2 -type f -name '*.mid' ! -name 'shinnyu_fft118_fixed.mid' ! -name 'shinnyu_fixed_pc0.mid' | wc -l | tr -d ' ')
SF2_COUNT=$(find . -maxdepth 2 -type f -name '*.sf2' | wc -l | tr -d ' ')

if [[ ! -f ./shinnyu.mid ]]; then
  if [[ "${MID_COUNT}" == "1" ]]; then
    MID_PATH=$(find . -maxdepth 2 -type f -name '*.mid' ! -name 'shinnyu_fft118_fixed.mid' ! -name 'shinnyu_fixed_pc0.mid' | head -n 1)
    cp "${MID_PATH}" ./shinnyu.mid
  fi
fi

if [[ ! -f ./shinnyu.sf2 ]]; then
  if [[ "${SF2_COUNT}" == "1" ]]; then
    SF2_PATH=$(find . -maxdepth 2 -type f -name '*.sf2' | head -n 1)
    cp "${SF2_PATH}" ./shinnyu.sf2
  fi
fi

echo "=== generated files ==="
find . -maxdepth 3 -type f | sort

popd >/dev/null
