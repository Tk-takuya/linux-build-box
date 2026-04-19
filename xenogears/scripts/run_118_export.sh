#!/usr/bin/env bash
set -euo pipefail
BUNDLE_DIR="$1"
PSF_PATH="$2"
OUT_DIR="$3"
mkdir -p "$OUT_DIR"
cd "$BUNDLE_DIR"
./build/linux-x64/Release/bin/vgmtrans-shell <<EOF
load "$PSF_PATH"
collection list
instrumentset list
sequence list
collection export 0 "$OUT_DIR"
quit
EOF
