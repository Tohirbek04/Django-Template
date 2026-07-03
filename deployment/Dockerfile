# --- Builder: install dependencies with uv ---
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# --- Production: minimal runtime ---
FROM python:3.13-slim-bookworm AS production

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH" \
    DJANGO_SETTINGS_MODULE=conf.settings.prod

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash appuser

COPY --from=builder --chown=appuser:appuser /app/.venv /app/.venv
COPY --chown=appuser:appuser . .

# Collect static at build time (WhiteNoise serves from the image).
# Dummy env values satisfy settings import; no DB/Redis connection is made.
RUN DJANGO_SECRET_KEY=build-only-dummy \
    DATABASE_URL=postgres://build:build@db:5432/build \
    CACHE_URL=redis://redis:6379/1 \
    DOMAIN=example.com \
    python manage.py collectstatic --noinput \
    && mkdir -p /app/media \
    && chown -R appuser:appuser /app/staticfiles /app/media

USER appuser

EXPOSE 8001

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -fsS http://localhost:8001/healthz/ || exit 1

CMD ["uvicorn", "conf.asgi:application", "--host", "0.0.0.0", "--port", "8001", "--workers", "4", "--log-level", "info"]
