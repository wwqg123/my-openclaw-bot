# --- 阶段 1: 构建阶段 ---
# 使用 bullseye-slim 而不是 full 镜像，因为它更轻但比 slim 稍微多一点工具
FROM node:22-bullseye-slim AS builder

# 安装最小化编译工具
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 限制构建时的并行线程数，防止多核编译吃掉所有内存
ENV MAKEFLAGS="-j1"
ENV CMAKE_BUILD_PARALLEL_LEVEL=1

COPY package*.json ./

# 1. 禁用脚本运行，防止在安装时自动触发耗能的二进制构建
# 2. 限制 npm 自身的内存
RUN node --max-old-space-size=512 /usr/local/lib/node_modules/npm/bin/npm-cli.js install \
    --omit=dev \
    --no-audit \
    --no-fund \
    --legacy-peer-deps

COPY . .

# --- 阶段 2: 运行阶段 ---
FROM node:22-bullseye-slim

# 运行本地模型必须的库
RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app ./

# --- 运行时的 1GB 内存存活策略 ---
# 预留 300MB 给系统内核和 C++ 扩展，Node 只拿 700MB
ENV NODE_OPTIONS="--max-old-space-size=700"
ENV NODE_ENV=production

EXPOSE 18789

# 启动命令
CMD ["node", "./node_modules/.bin/openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0", "--allow-unconfigured"]
