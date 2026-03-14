#!/bin/sh
set -eu

exec solana-test-validator \
    --ledger /var/lib/solana \
    --geyser-plugin-config /etc/yellowstone/config.json \
    "$@"
