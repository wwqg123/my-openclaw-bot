FROM node:22-alpine

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Install OpenClaw globally
RUN pnpm add -g openclaw@latest

# Expose the default gateway port
EXPOSE 18789

# Command to run the OpenClaw gateway
CMD ["openclaw", "gateway", "--port", "18789", "--allow-unconfigured", "--token", "manus123"]
