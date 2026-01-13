.PHONY: install dev sync lock run migrate makemigrations shell test lint format clean docker-build docker-up docker-down docker-logs

# Package management with uv
install:
	uv sync --frozen

dev:
	uv sync --frozen --all-extras

sync:
	uv sync

lock:
	uv lock

add:
	uv add $(pkg)

add-dev:
	uv add --dev $(pkg)

remove:
	uv remove $(pkg)

# Django commands
run:
	uv run python manage.py runserver

migrate:
	uv run python manage.py migrate

makemigrations:
	uv run python manage.py makemigrations

mig: makemigrations migrate

shell:
	uv run python manage.py shell

createsuperuser:
	uv run python manage.py createsuperuser

collectstatic:
	uv run python manage.py collectstatic --noinput

check:
	uv run python manage.py check

# Remove migrations (use with caution)
unmig:
	find . -path "*/migrations/*.py" -not -name "__init__.py" -delete
	find . -path "*/migrations/*.pyc" -delete

# Testing
test:
	uv run pytest -v

test-cov:
	uv run pytest --cov=. --cov-report=html --cov-report=term

# Code quality
lint:
	uv run flake8 .

format:
	uv run black .
	uv run isort .

typecheck:
	uv run mypy .

quality: format lint typecheck

# Docker commands
docker-build:
	docker build -f deployment/Dockerfile -t django-template:latest .

docker-up:
	cd deployment && docker compose up -d

docker-down:
	cd deployment && docker compose down

docker-logs:
	cd deployment && docker compose logs -f

docker-ps:
	cd deployment && docker compose ps

docker-restart:
	cd deployment && docker compose restart

docker-clean:
	docker system prune -f
	docker image prune -f

# Database (local development)
db-start:
	docker start postgres_container || docker run -d --name postgres_container -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16-alpine

db-stop:
	docker stop postgres_container

db-shell:
	docker exec -it -u postgres postgres_container psql

redis-start:
	docker start redis_container || docker run -d --name redis_container -p 6379:6379 redis:7-alpine

redis-stop:
	docker stop redis_container

# Utilities
secret-key:
	@uv run python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true

# Help
help:
	@echo "Available commands:"
	@echo ""
	@echo "Package Management:"
	@echo "  install        - Install dependencies (frozen)"
	@echo "  dev            - Install with dev dependencies"
	@echo "  sync           - Sync dependencies"
	@echo "  lock           - Update lock file"
	@echo "  add pkg=name   - Add a package"
	@echo "  add-dev pkg=n  - Add a dev package"
	@echo ""
	@echo "Django:"
	@echo "  run            - Run development server"
	@echo "  migrate        - Run migrations"
	@echo "  makemigrations - Create migrations"
	@echo "  mig            - Make and run migrations"
	@echo "  shell          - Django shell"
	@echo "  createsuperuser- Create admin user"
	@echo "  collectstatic  - Collect static files"
	@echo ""
	@echo "Testing & Quality:"
	@echo "  test           - Run tests"
	@echo "  test-cov       - Run tests with coverage"
	@echo "  lint           - Run linter"
	@echo "  format         - Format code"
	@echo "  typecheck      - Run type checker"
	@echo "  quality        - Run all quality checks"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-up      - Start containers"
	@echo "  docker-down    - Stop containers"
	@echo "  docker-logs    - View logs"
	@echo ""
	@echo "Utilities:"
	@echo "  secret-key     - Generate Django secret key"
	@echo "  clean          - Remove cache files"
