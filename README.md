# Django Template

Production-ready Django REST API template with modern tooling.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | **Python 3.13** |
| Framework | **Django 5.2 LTS** |
| API toolkit | **Django REST Framework 3.17** |
| Admin | **django-unfold** |
| Database | **PostgreSQL 18** + **PgBouncer 1.25** (connection pooling) |
| Cache / broker | **Redis 8** |
| Task queue | **Celery 5.6** + beat (DB-backed scheduler) |
| Reverse proxy / TLS | **Traefik v3** (auto-HTTPS via Let's Encrypt) |
| Static files | **WhiteNoise** (served from the image) |
| Observability | **Prometheus v3** + **Grafana 13** + **Sentry** |
| Package manager | **uv** |
| Linter / formatter | **ruff** |
| Container runtime | **Docker** + **docker-rollout** (zero-downtime deploys) |
| Image registry | **GHCR** (`sha-<commit>` tags) |

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) package manager
- Docker & Docker Compose (for local services and production)

## Quick Start

```bash
cp example.env .env
make dev-up      # postgres 18 + redis 8 in docker
make install     # uv sync --frozen
make migrate
make run         # http://localhost:8000 (swagger at /)
make test
make lint
```

## Development Commands

```bash
# Package management
make install          # Install dependencies (uv sync --frozen)
make dev              # Install with dev dependencies
make add pkg=name     # Add a package
make add-dev pkg=name # Add a dev package
make lock             # Update lock file

# Django
make run              # Run development server
make migrate          # Run migrations
make makemigrations   # Create migrations
make mig              # Make and run migrations
make shell            # Django shell
make createsuperuser  # Create admin user
make collectstatic    # Collect static files

# Code quality
make lint             # Run ruff check + ruff format --check
make format           # Format with ruff format + ruff check --fix
make typecheck        # Run mypy
make quality          # Run all quality checks

# Testing
make test             # Run tests (pytest)
make test-cov         # Run tests with coverage

# Local dev services
make dev-up           # Start postgres 18 + redis 8 via docker-compose.dev.yml
make dev-down         # Stop local dev services

# Celery (local)
make worker           # Start Celery worker
make beat             # Start Celery beat scheduler

# Utilities
make secret-key       # Generate Django secret key
make clean            # Remove cache files
make help             # Show all commands
```

## Production Deployment

### CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) runs these jobs on every push to `master`:

1. **Lint** — `ruff check` + `ruff format --check`
2. **Test** — `pytest` against PostgreSQL 18 + Redis 8 service containers
3. **Build & Push** — Docker image built and pushed to GHCR with tags `sha-<commit>` and `latest` (runs only on push to `master`, requires lint + test to pass)
4. **Deploy** — SSH into the production server, then:
   - `docker compose pull`
   - Bring up `db`, `pgbouncer`, `redis`
   - One-off migration: `docker compose run --rm --no-deps backend python manage.py migrate --noinput`
   - Zero-downtime backend rollout: `docker rollout backend`
   - `docker compose up -d --remove-orphans`
   - Telegram notification on failure

**Rollback:** re-run the deploy workflow with the desired image tag set in `DOCKER_IMAGE` (e.g., `ghcr.io/your-org/your-repo:sha-<older-sha>`).

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | Private key for SSH access to the production server |
| `SSH_HOST` | Production server hostname or IP |
| `SSH_USER` | SSH login user |
| `DJANGO_SECRET_KEY` | Django `SECRET_KEY` |
| `DATABASE_USER` | PostgreSQL username |
| `DATABASE_PASSWORD` | PostgreSQL password |
| `DATABASE_NAME` | PostgreSQL database name |
| `REDIS_PASSWORD` | Redis `requirepass` password |
| `DOMAIN` | Production domain (e.g. `example.com`) |
| `LETSENCRYPT_EMAIL` | Email for Let's Encrypt TLS certificates |
| `GRAFANA_PASSWORD` | Grafana admin password |
| `TRAEFIK_DASHBOARD_AUTH` | htpasswd string for Traefik dashboard basic auth |
| `GHCR_PULL_TOKEN` | GitHub PAT used by the server to pull from GHCR |
| `SENTRY_DSN` | Sentry DSN (optional — leave empty to disable) |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token for failure notifications |
| `TELEGRAM_CHAT_ID` | Telegram chat ID for failure notifications |

### Docker Compose Services

| Service | Description |
|---------|-------------|
| `traefik` | Traefik v3 reverse proxy — auto-HTTPS, dashboard at `/traefik` |
| `backend` | Django application (2 replicas) |
| `media` | Caddy file-server for `/media` uploads |
| `celery-worker` | Celery task worker |
| `celery-beat` | Celery periodic task scheduler (DB-backed) |
| `db` | PostgreSQL 18 |
| `pgbouncer` | PgBouncer 1.25 connection pooler |
| `redis` | Redis 8 |
| `db_backup` | Automated daily backups (7-day retention) |
| `postgres-exporter` | PostgreSQL metrics exporter |
| `redis-exporter` | Redis metrics exporter |
| `prometheus` | Prometheus v3 (internal, scrapes all exporters) |
| `grafana` | Grafana 13 — dashboards at `/grafana` |

> **PostgreSQL 16 → 18 upgrade warning**
>
> PostgreSQL does NOT auto-upgrade volume data between major versions. If you are migrating an existing server from PostgreSQL 16, you must:
> 1. `pg_dumpall` while still on PostgreSQL 16.
> 2. Stop all services and wipe the `postgres_data` Docker volume.
> 3. Start PostgreSQL 18 and restore the dump.
>
> Automated daily backups are stored in the `backup_data` volume — restore from there if needed.

## Project Structure

```
Django-Template/
├── apps/                   # Django applications
│   ├── common/             # BaseModel (UUID pk, timestamps), healthz endpoint
│   └── users/              # Custom User model (UUID pk), unfold admin
├── conf/                   # Project configuration
│   ├── settings/
│   │   ├── base.py         # Shared settings
│   │   ├── dev.py          # Development overrides
│   │   └── prod.py         # Production overrides
│   ├── celery.py           # Celery application
│   ├── urls.py             # URL routing
│   ├── asgi.py             # ASGI config
│   └── wsgi.py             # WSGI config
├── deployment/             # Production deployment
│   ├── Dockerfile          # Docker image (build-time collectstatic)
│   ├── docker-compose.yml  # Container orchestration
│   ├── send_backup.sh      # Backup notification script
│   ├── grafana/            # Grafana provisioning
│   └── server/
│       └── media.Caddyfile # Caddy media file-server config
├── prometheus/             # Monitoring config
│   └── prometheus.yml
├── docker-compose.dev.yml  # Local dev services (postgres 18 + redis 8)
├── pyproject.toml          # Project dependencies (uv)
├── uv.lock                 # Lock file
├── Makefile                # Development commands
└── manage.py               # Django CLI
```

## API Documentation

When `DEBUG=True`, API documentation is available at:

- **Swagger UI**: `http://localhost:8000/`
- **ReDoc**: `http://localhost:8000/api/schema/redoc/`
- **OpenAPI Schema**: `http://localhost:8000/api/schema/`

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

### Grafana

Grafana is available at `https://<domain>/grafana` (admin password set via `GRAFANA_PASSWORD`).

Recommended dashboard IDs to import:

| Dashboard | ID |
|-----------|----|
| PostgreSQL | `9628` |
| Redis | `763` |
| Traefik | `17346` |
| Django | `17658` |

### Traefik Dashboard

The Traefik dashboard is available at `https://<domain>/traefik` protected by HTTP basic auth. Generate the `TRAEFIK_DASHBOARD_AUTH` value with:

```bash
docker run --rm httpd:alpine htpasswd -nb admin <password>
```

### Prometheus

Prometheus scrapes Django metrics from the `/metrics` endpoint, as well as postgres-exporter and redis-exporter. It is internal-only — access metrics through Grafana.

## Security Features

- HTTPS with automatic certificate renewal (Traefik + Let's Encrypt)
- CSRF protection
- CORS configuration
- Security headers (HSTS, XSS, content-type nosniff, etc.)
- Non-root Docker user
- Connection pooling (PgBouncer)
- Traefik dashboard protected by HTTP basic auth

## License

MIT
