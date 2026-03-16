# syntax=docker/dockerfile:1.7

# ── shared build base ──────────────────────────────────────────────
FROM rust:1.86.0-bookworm AS build-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libssl-dev \
    libudev-dev \
    zlib1g-dev \
    llvm \
    clang \
    cmake \
    libprotobuf-dev \
    protobuf-compiler \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# ── agave validator ────────────────────────────────────────────────
FROM build-base AS agave-builder

WORKDIR /src/agave
COPY vendor/agave/ .

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/src/agave/target \
    ./scripts/cargo-install-all.sh /out

# ── yellowstone gRPC plugin ───────────────────────────────────────
FROM build-base AS yellowstone-builder

WORKDIR /src/yellowstone
COPY vendor/yellowstone-grpc/ .

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/src/yellowstone/target \
    cargo build --release -p yellowstone-grpc-geyser && \
    mkdir -p /out && \
    cp target/release/libyellowstone_grpc_geyser.so /out/

# ── minimal runtime ───────────────────────────────────────────────
FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    libudev1 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system solana \
    && useradd --system --gid solana --create-home solana \
    && mkdir -p /var/lib/solana /opt/agave/bin /opt/yellowstone /etc/yellowstone \
    && chown solana:solana /var/lib/solana

COPY --from=agave-builder /out/ /opt/agave/
COPY --from=yellowstone-builder /out/libyellowstone_grpc_geyser.so /opt/yellowstone/
COPY config/yellowstone.json /etc/yellowstone/config.json
COPY --chmod=755 scripts/docker-entrypoint.sh /usr/local/bin/

ENV PATH=/opt/agave/bin:$PATH

USER solana
WORKDIR /home/solana

EXPOSE 8899 8900 8999 10000

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD solana cluster-version --url http://127.0.0.1:8899

ENTRYPOINT ["docker-entrypoint.sh"]
