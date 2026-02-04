# --- 阶段 1: 构建阶段 (改用全量版 Node 22，虽然大，但稳) ---
FROM node:22 AS builder

# 设置构建时的环境变量，防止交互式弹窗卡住构建
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 复制所有文件
COPY . .

# 2. 清理可能存在的缓存并安装 (全量镜像自带 git, python, g++)
# 使用 --legacy-peer-deps 解决可能存在的依赖冲突
RUN npm install --omit=dev --legacy-peer-deps --no-audit

# --- 阶段 2: 运行阶段 (回归 slim 镜像，保持轻量) ---
FROM node:22-slim

# 运行阶段依然需要一些基础库来支撑 node-llama-cpp 的运行
RUN apt-get update && apt-get install -y \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从构建阶段拷贝
COPY --from=builder /app ./

# --- 1GB 内存限制优化 ---
# 严格限制堆空间，预留给 C++ 绑定
ENV NODE_OPTIONS="--max-old-space-size=700"
ENV NODE_ENV=production

EXPOSE 18789

# 启动
CMD ["node", "./node_modules/.bin/openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0", "--allow-unconfigured"]
