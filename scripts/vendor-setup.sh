#!/bin/sh
set -eu

AGAVE_TAG="v3.1.10"
YELLOWSTONE_TAG="v12.1.0+triton-ext.solana.3.1.10"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENDOR_DIR="$(dirname "$SCRIPT_DIR")/vendor"

rm -rf "$VENDOR_DIR/agave" "$VENDOR_DIR/yellowstone-grpc"
mkdir -p "$VENDOR_DIR"

git clone --branch "$AGAVE_TAG" --depth=1 \
    https://github.com/anza-xyz/agave.git "$VENDOR_DIR/agave"

git clone --branch "$YELLOWSTONE_TAG" --depth=1 \
    https://github.com/rpcpool/yellowstone-grpc.git "$VENDOR_DIR/yellowstone-grpc"

echo "vendor setup complete: agave@${AGAVE_TAG} yellowstone-grpc@${YELLOWSTONE_TAG}"
