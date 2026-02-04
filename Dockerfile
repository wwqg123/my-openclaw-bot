# --- 阶段 1: 构建阶段 (使用 Node 22) ---
FROM node:22-slim AS builder

# 安装编译所需的系统工具 (node-llama-cpp 依然需要这些)
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# --- 阶段 2: 运行阶段 ---
FROM node:22-slim

WORKDIR /app

# 拷贝构建好的依赖和源码
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# 暴露端口
EXPOSE 18789

# 启动命令
CMD ["npm", "start"]
