---
mode: 'agent'
tools: ['codebase']
description: 'Create optimized multi-stage Dockerfiles for any language or framework'
---

Your goal is to help me create efficient multi-stage Dockerfiles that follow best practices, resulting in smaller, more secure container images.

## Multi-Stage Structure

- Use a builder stage for compilation, dependency installation, and other build-time operations
- Use a separate runtime stage that only includes what's needed to run the application
- Copy only the necessary artifacts from the builder stage to the runtime stage
- Use meaningful stage names with the `AS` keyword (e.g., `FROM node:18 AS builder`)
- Place stages in logical order: dependencies → build → test → runtime

## Base Images

- Start with official, minimal base images when possible
- Specify exact version tags to ensure reproducible builds (e.g., `python:3.11-slim` not just `python`)
- Consider distroless images for runtime stages where appropriate
- Use Alpine-based images for smaller footprints when compatible with your application
- Ensure the runtime image has the minimal necessary dependencies

## Layer Optimization

- Organize commands to maximize layer caching
- Place commands that change frequently (like code changes) after commands that change less frequently (like dependency installation)
- Use `.dockerignore` to prevent unnecessary files from being included in the build context
- Combine related RUN commands with `&&` to reduce layer count
- Consider using COPY --chown to set permissions in one step

## Security Practices

- Avoid running containers as root - use `USER` instruction to specify a non-root user
- Remove build tools and unnecessary packages from the final image
- Scan the final image for vulnerabilities
- Set restrictive file permissions
- Use multi-stage builds to avoid including build secrets in the final image

## Performance Considerations

- Use build arguments for configuration that might change between environments
- Leverage build cache efficiently by ordering layers from least to most frequently changing
- Consider parallelization in build steps when possible
- Set appropriate environment variables like NODE_ENV=production to optimize runtime behavior
- Use appropriate healthchecks for the application type with the HEALTHCHECK instruction

## Language-Specific Best Practices

### Node.js
- Use `npm ci` instead of `npm install` for deterministic builds
- Copy `package*.json` first to leverage cache for dependency layers
- Remove dev dependencies in runtime stage
- Use `NODE_ENV=production`

### Python
- Use `pip install --no-cache-dir` to reduce image size
- Copy requirements.txt first for better caching
- Use virtual environments in builder stages
- Consider using `python:slim` or `python:alpine` for runtime

### Go
- Use Go modules and vendor directory for dependencies
- Leverage Go's static linking capabilities for minimal runtime images
- Consider distroless images for Go applications
- Use `CGO_ENABLED=0` for fully static binaries

### Java
- Use multi-stage builds with Maven or Gradle in builder stage
- Consider using JRE instead of JDK for runtime
- Use appropriate JVM flags for container environments
- Consider using distroless Java images

## Example Structure

```dockerfile
# Build stage
FROM language:version AS builder
WORKDIR /app
COPY dependency-files ./
RUN install-dependencies
COPY source-code ./
RUN build-application

# Test stage (optional)
FROM builder AS tester
RUN run-tests

# Runtime stage
FROM language:runtime-version AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
COPY --from=builder --chown=appuser:appgroup /app/built-artifacts ./
USER appuser
EXPOSE port
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:port/health || exit 1
CMD ["run-command"]
```

When creating Dockerfiles, analyze the project structure and dependencies to determine the most efficient multi-stage approach for the specific language and framework being used.
