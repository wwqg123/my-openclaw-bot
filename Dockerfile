FROM node:22-alpine

RUN apk add --no-cache python3 make g++ git

WORKDIR /app

ENV OPENCLAW_GATEWAY_TOKEN=manus123
ENV NODE_ENV=production
ENV PORT=18789

COPY package.json ./

RUN npm install --omit=dev

EXPOSE 18789

# 关键修复：添加 --host 0.0.0.0 确保外部可访问
CMD ["npx", "openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0", "--allow-unconfigured", "--token", "manus123"]
