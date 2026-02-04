# --- 阶段 1: 构建环境 (编译 node-llama-cpp) ---
FROM node:22-slim AS builder

# 安装编译所需的系统工具
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制依赖文件并安装
COPY package*.json ./
# 提示：如果 npm install 依然在构建阶段崩掉，说明 Zeabur 构建机内存不足
RUN npm install

# 复制源码
COPY . .

# --- 阶段 2: 运行环境 ---
FROM node:22-slim

WORKDIR /app

# 从构建阶段只拷贝必要的文件，减少镜像层数和体积
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# --- 内存优化设置 ---
# 告诉 Node.js 尽量利用容器内存，不要因为默认限制而过早崩溃
# 如果你的 Zeabur 套餐内存是 1GB，请将下方的 2048 改为 800
ENV NODE_OPTIONS="--max-old-space-size=2048"
ENV NODE_ENV=production

# 暴露 OpenClaw Gateway 端口
EXPOSE 18789

# 启动命令
# 加上 --no-warnings 可以减少日志杂讯
CMD ["npm", "start"]
