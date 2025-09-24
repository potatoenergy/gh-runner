# GH Runner Docker

Self-hosted GitHub Actions Runner in Docker Container

## Compliance Statement

⚠️ **Runner Usage Requirements**
- Register only **one runner per container**
- Use ephemeral mode for security-sensitive workflows
- Keep runner updated to latest version
- Limit network exposure of runner
- Do not store secrets in runner configuration

## Environment Variables

`.env` configuration example:
```dotenv
# Runner configuration
RUNNER_VERSION=2.328.0
RUNNER_URL=https://github.com/OWNER/REPO
RUNNER_TOKEN=PASTE_REGISTRATION_TOKEN_HERE
RUNNER_NAME=gh-runner
RUNNER_LABELS=self-hosted,linux
RUNNER_WORK=_work
EPHEMERAL=false
```

| Variable | Purpose | Default |
|----------|---------|---------|
| `RUNNER_VERSION` | GitHub Actions runner version | 2.328.0 |
| `RUNNER_URL` | Repository URL for runner registration | - |
| `RUNNER_TOKEN` | Registration token from GitHub | - |
| `RUNNER_LABELS` | Comma-separated runner labels | self-hosted,linux |
| `EPHEMERAL` | One-time use runner | false |
| `RUNNER_NAME` | Custom runner name | gh-runner |
| `RUNNER_WORK` | Working directory | _work |

## Key Features

**1. Multi-architecture Support:**
```bash
# Build for all supported platforms
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t ghcr.io/owner/gh-runner:latest .
```

**2. Ephemeral Mode:**
```bash
# One-time runner that self-destructs after workflow
EPHEMERAL=true
```

**3. Automatic Configuration:**
```text
1. Container starts
2. Registers with GitHub
3. Creates health check file
4. Starts listening for jobs
5. Automatically unregisters on exit
```

## Configuration Examples

**Basic setup:**
```bash
RUNNER_URL=https://github.com/ponfertato/ponfertato
RUNNER_TOKEN=abcdef1234567890
```

**Custom labels for specific workflows:**
```bash
RUNNER_LABELS=self-hosted,linux,arm64,cpu-intensive
```

**Ephemeral runner for security:**
```bash
# Only runs one workflow then unregisters
EPHEMERAL=true
```

## Technical Architecture

**Runner Lifecycle:**
1. Container startup
2. GitHub registration
3. Health check initialization
4. Job execution
5. Automatic cleanup on exit

**Multi-arch Support:**
```text
x86_64 → linux-x64
arm64  → linux-arm64
armv7  → linux-arm
```

## Deployment

### 1. Build the Runner Image

Build the multi-architecture Docker image locally:

```bash
docker compose -f gh-runner/docker-compose.yml build
```

This creates a local Docker image with the specified runner version.

### 2. Start the Runner Service

Launch the runner container in the background:

```bash
docker compose -f gh-runner/docker-compose.yml up -d
```

The runner will automatically:
- Register with GitHub using your provided token
- Start listening for workflow jobs
- Create a health check file when ready
- Unregister itself on container shutdown

### 3. Scale Your Runners (Optional)

To run multiple instances simultaneously:

```bash
# Update .env file
REPLICAS=3

# Recreate the service
docker compose -f gh-runner/docker-compose.yml up -d --force-recreate
```

This creates 3 identical runners that can handle multiple concurrent workflows.

## Scaling Configuration

**Horizontal scaling:**
```env
# .env file
REPLICAS=3
```

**Distributed workloads:**
```yaml
# docker-compose.yml
deploy:
  replicas: ${REPLICAS}
```

## License

MIT License