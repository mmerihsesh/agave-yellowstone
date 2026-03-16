#!/bin/sh
set -eu

mkdir -p /var/lib/solana

exec /opt/agave/bin/solana-test-validator \
    --ledger /var/lib/solana \
    --geyser-plugin-config /etc/yellowstone/config.json \
    "$@"