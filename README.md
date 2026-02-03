# OpenClaw (ClawdBot) 永久化部署指南

## 1. 引言

本指南旨在帮助您将个人 AI 助手 OpenClaw（原名 ClawdBot）部署到云端，实现 24/7 运行并可通过公共网络访问。我们将重点介绍如何利用 **Zeabur** 平台进行部署，该平台对开发者友好，并提供免费额度，是实现低成本、持久化部署的理想选择。

OpenClaw 是一款开源的 AI 助手，它可以在您自己的设备上运行，并通过您常用的消息应用（如 WhatsApp、Telegram、Discord，以及通过特定插件支持微信）与您互动。通过本指南，您将能够轻松地在云端搭建自己的 OpenClaw 服务，并进行个性化配置。

## 2. 部署准备

在开始部署之前，请确保您已拥有以下账户和工具：

*   **GitHub 账户**：用于存储您的 OpenClaw 配置文件，并与 Zeabur 进行集成，实现自动化部署。
*   **Zeabur 账户**：一个云应用托管平台，提供免费额度，支持 Docker 部署。
*   **OpenClaw 配置文件**：包括 `Dockerfile` 和 `docker-compose.yml`，这些文件已为您准备好，稍后将提供给您。
*   **大模型 API Key (可选)**：如果您希望 OpenClaw 使用 Anthropic (Claude) 或 OpenAI 等大模型，您需要提前准备好相应的 API Key。您也可以在部署完成后通过 OpenClaw 的 Web 界面进行配置。

## 3. Zeabur 部署步骤

Zeabur 平台支持通过连接 GitHub 仓库来自动部署您的应用。以下是详细步骤：

### 3.1. 创建 GitHub 仓库

1.  在您的 GitHub 账户中创建一个新的私有仓库，例如命名为 `openclaw-deployment`。
2.  将为您准备好的 `Dockerfile` 和 `docker-compose.yml` 文件上传到这个新创建的仓库的根目录。

### 3.2. 连接 Zeabur 与 GitHub

1.  登录您的 Zeabur 账户。
2.  在 Zeabur 控制台中，创建一个新的项目 (Project)。
3.  在新项目中，点击“Deploy New Service”（部署新服务）。
4.  选择“Deploy with Git”或“Connect to GitHub”，并授权 Zeabur 访问您刚刚创建的 `openclaw-deployment` 仓库。

### 3.3. 配置服务

1.  在服务配置页面，选择您的 `openclaw-deployment` 仓库。
2.  **构建方式**：Zeabur 会自动检测 `Dockerfile`。确保构建类型为 `Docker`。
3.  **端口配置**：OpenClaw Gateway 默认监听 `18789` 端口。在 Zeabur 的服务设置中，确保将服务的端口设置为 `18789`。
4.  **环境变量**：
    *   添加 `OPENCLAW_GATEWAY_TOKEN` 环境变量，值为 `manus123` (与 `Dockerfile` 和 `docker-compose.yml` 中的设置一致)。
    *   如果您有大模型 API Key，可以在此处添加，例如 `OPENCLAW_ANTHROPIC_API_KEY` 或 `OPENCLAW_OPENAI_API_KEY`。
5.  **持久化存储 (Persistent Storage)**：
    *   为了确保 OpenClaw 的配置、聊天记录和技能等数据在服务重启后不会丢失，您需要配置持久化存储。
    *   在 Zeabur 的服务设置中，找到“Persistent Storage”或类似选项，添加一个挂载点，将容器内的 `/root/.openclaw` 路径映射到持久化存储卷。这将确保 `openclaw_data` 卷中的数据得到保存。

### 3.4. 部署服务

1.  完成上述配置后，点击“Deploy”（部署）。
2.  Zeabur 将会自动从您的 GitHub 仓库拉取代码，构建 Docker 镜像，并启动您的 OpenClaw 服务。
3.  部署成功后，Zeabur 会为您提供一个公共访问域名 (Domain)，您可以通过该域名访问 OpenClaw 的 Web 控制台。

## 4. 部署后配置

1.  **访问 OpenClaw 控制台**：通过 Zeabur 提供的公共域名访问您的 OpenClaw 服务。例如：`https://your-service-name.zeabur.app`。
2.  **登录**：使用您在环境变量中设置的 `OPENCLAW_GATEWAY_TOKEN` (即 `manus123`) 作为访问令牌。
3.  **配置大模型**：在控制台的“Models”或“Settings”选项卡中，配置您的大模型 API Key，以便 OpenClaw 能够与 AI 进行交互。
4.  **接入微信**：
    *   在控制台的“Channels”或“Integrations”选项卡中，查找微信相关的插件。
    *   根据插件的指引，扫描二维码登录您的个人微信，或配置企业微信机器人。
    *   **注意**：个人微信接入可能存在封号风险，建议优先考虑企业微信或使用其他更稳定的渠道（如 Telegram、Discord）。

## 5. 成本考量

Zeabur 提供慷慨的免费额度，对于个人使用或轻量级应用，通常可以满足需求而无需支付费用。如果您的使用量超出免费额度，Zeabur 会按照实际资源消耗进行计费，通常费用较低。您可以在 Zeabur 的官网查看详细的定价信息。

## 6. 故障排除与提示

*   **服务无法启动**：检查 Zeabur 的部署日志，查看是否有错误信息。确保端口、环境变量和持久化存储配置正确。
*   **微信无法连接**：检查网络连接，确保 OpenClaw 服务可以访问微信服务器。同时，留意微信官方的限制和政策。
*   **数据丢失**：请务必确认已正确配置持久化存储，否则服务重启后数据可能会丢失。

希望这份指南能帮助您成功部署 OpenClaw！如果您在部署过程中遇到任何问题，可以参考 Zeabur 的官方文档或 OpenClaw 的 GitHub 仓库寻求帮助。
