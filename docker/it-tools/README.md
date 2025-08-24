# IT Tools

IT Tools is a collection of handy online tools for developers and system administrators. It provides various utilities for encoding, decoding, formatting, and other common development tasks.

## Features

- Base64 encoding/decoding
- JSON formatter and validator
- Hash generators (MD5, SHA1, SHA256, etc.)
- QR code generator
- URL encoder/decoder
- JWT token decoder
- Color palette tools
- Text manipulation utilities
- Network tools
- Cryptography utilities
- No data sent to external servers (privacy-focused)

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://it-tools.yourdomain.com` (if using Traefik)

## Usage

Once deployed, you can access various tools including:

- **Converters**: Base64, URL encoding, case converters
- **Web**: JWT decoder, HTML entities, URL parser
- **Images**: QR codes, image converters
- **Development**: JSON formatter, regex tester, cron parser
- **Network**: IP subnet calculator, MAC address lookup
- **Math**: Calculator, unit converters
- **Text**: Hash generators, text analyzers, lorem ipsum
- **Cryptography**: Password generators, encryption tools

## Privacy

All tools run locally in your browser - no data is sent to external servers, ensuring complete privacy for your sensitive information.

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## IT Tools Image

This deployment uses the official IT Tools image (`ghcr.io/corentinth/it-tools:2024.10.22-7ca5933`) which provides:

- Comprehensive tool collection
- Regular updates with new utilities
- Privacy-focused design
- No external dependencies for core functionality
- Clean and intuitive interface
