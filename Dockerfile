FROM node:22-alpine

# Alpine 版本更小，拉取更快
# 仅安装运行 openclaw 必需的运行时库
RUN apk add --no-cache python3 make g++

WORKDIR /app

# 预先设置环境变量
ENV OPENCLAW_GATEWAY_TOKEN=manus123
ENV NODE_ENV=production
ENV PORT=18789

# 复制 package.json
COPY package.json ./

# 使用 pnpm 或 npm 安装，--omit=dev 减小体积
RUN npm install --omit=dev

# 明确声明端口
EXPOSE 18789

# 直接运行，减少层级
CMD ["npx", "openclaw", "gateway", "--port", "18789", "--allow-unconfigured", "--token", "manus123"]
