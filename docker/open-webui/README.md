# Open WebUI

Open WebUI is a feature-rich web interface for interacting with large language models. This setup includes both Open WebUI and Ollama for a complete local LLM solution.

## Features

- Modern web interface for LLM interactions
- Multi-model support
- User authentication
- Chat history and conversation management
- Integration with Ollama backend
- Traefik reverse proxy integration

## Setup

1. Copy and configure the `.env` file:
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

2. Deploy with Portainer using Git repository option, or manually:
   ```bash
   docker compose up -d
   ```

## Configuration

- **DOCKER_BASE_PATH**: Base path for Docker volumes
- **PUID/PGID**: User/Group IDs for file permissions
- **TZ**: Timezone
- **TRAEFIK_BASE_DOMAIN**: Base domain for Traefik routing

## Services Included

- **Open WebUI**: Web interface (port 8080)
- **Ollama**: LLM backend (port 11434)

## Usage

Once deployed, Open WebUI will be available at:
- Web Interface: `https://open-webui.${TRAEFIK_BASE_DOMAIN}`

## Initial Setup

1. First time access will prompt you to create an admin account
2. Download models through the interface or via Ollama CLI
3. Start chatting with your locally hosted LLMs

## Model Management

You can manage models through the web interface or by exec'ing into the Ollama container:
```bash
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull codellama
docker exec -it ollama ollama list
```

## Configuration Options

The Open WebUI service includes several environment variables you can customize:
- `ENABLE_SIGNUP`: Set to false to disable new user registration
- `DEFAULT_MODELS`: Comma-separated list of default models
- `WEBUI_NAME`: Custom name for the interface
