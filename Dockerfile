# --- 阶段 1: 构建阶段 ---
FROM node:22-slim AS builder

# 关键：必须安装 git，否则无法下载 package.json 里的 git 依赖
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制依赖定义
COPY package*.json ./

# 运行安装 (此时有了 git，应该可以成功了)
RUN npm install --omit=dev --no-audit

# 复制其余源码
COPY . .

# --- 阶段 2: 运行阶段 ---
FROM node:22-slim

WORKDIR /app

# 从构建阶段拷贝编译好的依赖和源码
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# 限制 1GB 内存环境下的 Node 堆大小
ENV NODE_OPTIONS="--max-old-space-size=768"
ENV NODE_ENV=production

EXPOSE 18789

# 直接启动
CMD ["node", "./node_modules/.bin/openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0", "--allow-unconfigured"]
