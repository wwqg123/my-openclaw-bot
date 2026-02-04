# --- 第一阶段：构建 (编译 node-llama-cpp) ---
FROM node:20-slim AS builder

# 安装编译所需的系统工具
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制依赖定义
COPY package*.json ./

# 安装依赖（这一步会进行本地编译，耗时较长）
RUN npm install

# 复制其余源码
COPY . .

# --- 第二阶段：运行 ---
FROM node:20-slim

WORKDIR /app

# 从构建阶段只拷贝必要的文件
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# OpenClaw 默认可能需要的环境变量映射
ENV NODE_ENV=production

# 暴露端口（Zeabur 会自动通过环境变量分配端口，但声明一下是好习惯）
EXPOSE 3000

CMD ["npm", "start"]
