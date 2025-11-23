# Networking Toolbox

A comprehensive web-based networking toolbox by Lissy93, providing 100+ offline-first networking tools and utilities. Perfect for sysadmins and network engineers who need quick access to various network diagnostic, analysis, and conversion tools through a beautiful web interface.

## Features

- **DNS Tools**: DNS lookup, WHOIS, DNS security checks
- **Network Analysis**: Ping, traceroute, port scanning, subnet calculator
- **SSL/TLS Tools**: Certificate analyzer, cipher suite testing
- **Converters**: IP converters, base conversions, encoding/decoding
- **Hash Generators**: MD5, SHA, HMAC, and more
- **Text Utilities**: Case converters, regex testing, string manipulation
- **Calculators**: Subnet calculator, CIDR calculator, bandwidth calculator
- **Security Tools**: Password generators, encryption utilities
- **Web Utilities**: URL parser, user agent parser, JSON formatter
- **Offline-First**: All tools work without internet connectivity
- **Privacy-Focused**: No data sent to external servers
- **Mobile-Optimized**: Responsive design works on all devices
- **Customizable**: Dark/light mode, custom layouts, bookmarks

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `TZ`: Timezone for the container (default: America/Los_Angeles)

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- **Web Interface**: `https://networking-toolbox.yourdomain.com` (with Traefik)

## Usage

Access the web interface through your browser to use any of the 100+ available tools:

### Tool Categories

**DNS & Network Tools:**
- DNS Lookup - Query DNS records
- WHOIS Lookup - Domain registration information
- IP Geolocation - Locate IP addresses
- Port Scanner - Check open ports
- Ping - Test connectivity
- Traceroute - Trace network path
- Subnet Calculator - Calculate network ranges

**SSL/TLS Tools:**
- SSL Certificate Analyzer - Inspect certificates
- SSL Labs Test - Security assessment
- Cipher Suite Analyzer - Check supported ciphers

**Conversion Tools:**
- IP Address Converter - Convert between formats
- Base64 Encoder/Decoder
- URL Encoder/Decoder
- Hash Generator - MD5, SHA1, SHA256, etc.
- Binary/Hex/Decimal Converter

**Text Utilities:**
- Case Converter - Upper/lower/title case
- Regex Tester - Test regular expressions
- String Manipulation - Various string operations
- Diff Checker - Compare text differences

**Security Tools:**
- Password Generator - Create secure passwords
- UUID Generator
- Random Number Generator
- Encryption/Decryption utilities

**Web Utilities:**
- JSON Formatter/Validator
- URL Parser
- User Agent Parser
- QR Code Generator
- Color Picker

### Features

- **Offline-Capable**: All tools work without internet connection
- **Privacy-First**: No data sent to external servers
- **Bookmarking**: Save frequently used tools
- **Multi-Language**: Support for multiple languages
- **Customizable**: Light/dark themes, custom layouts
- **Mobile-Friendly**: Responsive design for all devices

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## Networking Toolbox Image

This deployment uses the Lissy93 Networking Toolbox image (`lissy93/networking-toolbox:1.6.0`) which provides:

- 100+ networking tools and utilities
- Beautiful, intuitive web interface
- Offline-first architecture
- Privacy-focused design (no external data transmission)
- Regular updates with new features
- Comprehensive documentation
- Multi-language support
- Mobile-optimized responsive design

## Traefik Integration

This service is accessible via Traefik at `networking-toolbox.${TRAEFIK_BASE_DOMAIN}` with automatic SSL certificate management.

## Deployment

### Using Portainer
1. In Portainer, create a new stack
2. Use the Git repository option
3. Set the repository path to: `docker/networking-toolbox`
4. Configure your environment variables
5. Deploy the stack

### Manual Deployment
```bash
cd docker/networking-toolbox
docker compose up -d
```

## Logs

View container activity:
```bash
docker logs networking-toolbox
docker logs -f networking-toolbox  # Follow logs
```

## References

- [Networking Toolbox GitHub Repository](https://github.com/Lissy93/networking-toolbox)
- [Official Website](https://networkingtoolbox.net/)
- [Docker Hub](https://hub.docker.com/r/lissy93/networking-toolbox)
- [Full Tool List](https://github.com/Lissy93/networking-toolbox#100s-of-tools)
