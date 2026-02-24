# Django Template

Production-ready Django REST API template with modern tooling.

## Tech Stack

- **Python 3.13** - Latest Python version
- **Django 5.1** - Web framework
- **Django REST Framework** - API toolkit
- **PostgreSQL 16** - Database
- **Redis 7** - Cache & message broker
- **Caddy 2** - Reverse proxy with automatic HTTPS
- **uv** - Fast Python package manager
- **Uvicorn** - ASGI server
- **Docker** - Containerization
- **Prometheus + Grafana** - Monitoring

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) package manager
- Docker & Docker Compose (for production)
- PostgreSQL 16 (for local development)
- Redis 7 (for local development)

## Quick Start

### 1. Clone the repository

```bash
git clone <repository-url>
cd Django-Template
```

### 2. Install dependencies

```bash
# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install project dependencies
make install

# Or with dev dependencies
make dev
```

### 3. Configure environment

```bash
cp example.env .env
# Edit .env with your settings
```

### 4. Setup database

```bash
# Start PostgreSQL container (optional)
make db-start

# Run migrations
make mig
```

### 5. Run development server

```bash
make run
```

The API will be available at `http://localhost:8000`

## Development Commands

```bash
# Package management
make install          # Install dependencies
make dev              # Install with dev dependencies
make add pkg=name     # Add a package
make add-dev pkg=name # Add a dev package
make lock             # Update lock file

# Django
make run              # Run development server
make mig              # Make and run migrations
make shell            # Django shell
make createsuperuser  # Create admin user
make collectstatic    # Collect static files

# Code quality
make lint             # Run flake8
make format           # Format with black & isort
make typecheck        # Run mypy
make quality          # Run all quality checks

# Testing
make test             # Run tests
make test-cov         # Run tests with coverage

# Database
make db-start         # Start PostgreSQL container
make db-shell         # Access PostgreSQL CLI
make redis-start      # Start Redis container

# Utilities
make secret-key       # Generate Django secret key
make clean            # Remove cache files
make help             # Show all commands
```

## Production Deployment

### Using Docker Compose

```bash
# Build and start all services
cd deployment
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Services

| Service | Port | Description |
|---------|------|-------------|
| backend | 8001 | Django application (2 replicas) |
| caddy | 80, 443 | Reverse proxy with auto HTTPS |
| db | 5432 | PostgreSQL 16 |
| pgbouncer | 6432 | Connection pooling |
| redis | 6379 | Cache & broker |
| postgres-exporter | - | PostgreSQL metrics exporter |
| redis-exporter | - | Redis metrics exporter |
| db_backup | - | Automated daily backups |
| prometheus | 9091 | Metrics collection |
| grafana | 3000 | Dashboards |

### Environment Variables

```bash
# Required
DATABASE_USER=
DATABASE_PASSWORD=
DATABASE_NAME=
DJANGO_SECRET_KEY=
REDIS_PASSWORD=
DOMAIN=
LETSENCRYPT_EMAIL=
DOCKER_USERNAME=
DOCKER_PASSWORD=

# Optional
DJANGO_DEBUG=False
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
GRAFANA_PASSWORD=
```

## Project Structure

```
Django-Template/
├── apps/                   # Django applications
├── conf/                   # Project configuration
│   ├── settings.py         # Django settings
│   ├── urls.py             # URL routing
│   ├── asgi.py             # ASGI config
│   └── wsgi.py             # WSGI config
├── deployment/             # Production deployment
│   ├── Dockerfile          # Docker image
│   ├── docker-compose.yml  # Container orchestration
│   ├── send_backup.sh      # Backup notification script
│   └── server/
│       └── Caddyfile       # Caddy configuration
├── prometheus/             # Monitoring config
│   └── prometheus.yml
├── templates/              # Django templates
├── pyproject.toml          # Project dependencies
├── uv.lock                 # Lock file
├── Makefile                # Development commands
├── entrypoint.sh           # Docker entrypoint
└── manage.py               # Django CLI
```

## API Documentation

When `DEBUG=True`, API documentation is available at:

- **Swagger UI**: `http://localhost:8001/`
- **ReDoc**: `http://localhost:8001/api/schema/redoc/`
- **OpenAPI Schema**: `http://localhost:8001/api/schema/`

## Health Check

Health check endpoint for container orchestration:

```bash
GET /healthz/
```

Response:
```json
{
  "status": "healthy",
  "checks": {
    "database": "ok",
    "cache": "ok"
  }
}
```

## Monitoring

### Prometheus Metrics

Django metrics are exposed at `/metrics` endpoint.

Prometheus is available at `http://localhost:9091`

### Grafana Dashboards

Grafana is available at `http://localhost:3000`

Default credentials: `admin` / `admin` (or `GRAFANA_PASSWORD`)

## CI/CD

GitHub Actions workflow includes:

1. **Build** - Docker image build and push to Docker Hub
2. **Deploy** - SSH deployment to production server with health verification

Required GitHub Secrets:
- `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- `SSH_PRIVATE_KEY`, `SSH_HOST`, `SSH_USER`
- `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_NAME`
- `DJANGO_SECRET_KEY`, `REDIS_PASSWORD`
- `DOMAIN`, `LETSENCRYPT_EMAIL`
- `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` (optional)

## Security Features

- HTTPS with automatic certificate renewal (Caddy)
- CSRF protection
- CORS configuration
- Rate limiting
- Security headers (HSTS, XSS, etc.)
- Non-root Docker user
- Connection pooling (PgBouncer)

## License

MIT
