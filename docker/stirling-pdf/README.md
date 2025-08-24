# Stirling PDF

Stirling PDF is a robust, locally hosted web-based PDF manipulation tool that allows you to perform various operations on PDF files without sending your documents to third-party services.

## Features

- PDF merging and splitting
- Page rotation and organization
- OCR (Optical Character Recognition)
- PDF compression and optimization
- Watermark and overlay addition
- Form filling and signing
- Password protection and security
- Format conversion (PDF to/from images, etc.)
- Metadata editing
- Multi-language support

## Configuration

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your specific values:
   - `PUID` and `PGID`: User and group IDs for file permissions
   - `DOCKER_BASE_PATH`: Base path for Docker volumes
   - `TRAEFIK_BASE_DOMAIN`: Your domain for Traefik routing
   - `DOCKER_ENABLE_SECURITY`: Enable/disable security features
   - `SECURITY_ENABLELOGIN`: Enable user authentication
   - `SECURITY_INITIALLOGIN_USERNAME`: Initial admin username
   - `SECURITY_INITIALLOGIN_PASSWORD`: Initial admin password
   - `INSTALL_BOOK_AND_ADVANCED_HTML_OPS`: Enable advanced HTML operations
   - `SECURITY_CSRFDISABLED`: Disable CSRF protection if needed
   - `SYSTEM_DEFAULTLOCALE`: Default system locale
   - `SYSTEM_MAXFILESIZE`: Maximum file size for uploads
   - `METRICS_ENABLED`: Enable metrics collection
   - `SYSTEM_GOOGLEVISIBILITY`: Control Google indexing

3. Deploy the service:
   ```bash
   docker compose up -d
   ```

## Access

- Web Interface: `https://stirling-pdf.yourdomain.com` (if using Traefik)

## Security Features

This setup includes several security options:
- User authentication system
- Login protection
- CSRF protection
- File size limits
- No data sent to external services

## Initial Setup

1. Access the web interface
2. Log in with your configured credentials (if authentication is enabled)
3. Start uploading and manipulating PDF files
4. Configure additional settings as needed

## OCR Support

The service includes OCR capabilities for:
- Text extraction from images in PDFs
- Making scanned documents searchable
- Additional language support via Tesseract

## Privacy

All PDF operations are performed locally on your server - no documents are sent to external services, ensuring complete privacy for sensitive documents.

## Resource Limits

The container is configured with:
- **Memory Limit**: 4GB
- **CPU Shares**: 1024
- **Security**: No new privileges
- **Health Checks**: Automatic service monitoring

## Volumes

- Data: `${DOCKER_BASE_PATH}/stirling-pdf/data` - Tesseract OCR language data
- Config: `${DOCKER_BASE_PATH}/stirling-pdf/config` - Application configuration
- Logs: `${DOCKER_BASE_PATH}/stirling-pdf/logs` - Application logs

## Network

This service is configured to use the `proxynet` external network for Traefik integration.

## Supported Operations

- **Merge/Split**: Combine or separate PDF documents
- **Rotate**: Rotate pages individually or in bulk
- **Compress**: Reduce file size while maintaining quality
- **Convert**: Transform PDFs to/from various formats
- **OCR**: Extract text from scanned documents
- **Security**: Add passwords and permissions
- **Edit**: Modify metadata, add watermarks, fill forms

## Stirling Tools Image

This deployment uses the official Stirling Tools image (`ghcr.io/stirling-tools/stirling-pdf:1.2.0`) which provides:

- Comprehensive PDF manipulation tools
- Privacy-focused local processing
- Regular security updates
- Multi-language interface support
- Advanced OCR capabilities
