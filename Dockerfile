# --- 阶段 1: 构建阶段 ---
FROM node:22-slim AS builder

# 安装最小化的编译依赖
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./

# 使用 --no-audit 和 --no-fund 减少安装时的内存占用
RUN npm install --omit=dev --no-audit --no-fund

COPY . .

# --- 阶段 2: 运行阶段 ---
FROM node:22-slim

WORKDIR /app

# 只拷贝生产环境必需文件
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# --- 1GB 内存环境的关键优化 ---
# 将堆内存限制在 768MB，预留 250MB 给系统和 C++ 绑定，防止直接被系统杀掉
ENV NODE_OPTIONS="--max-old-space-size=768 --is-node-main-instance"
ENV NODE_ENV=production

EXPOSE 18789

# 直接调用二进制文件启动，跳过 npm，节省内存
CMD ["node", "./node_modules/.bin/openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0", "--allow-unconfigured"]
