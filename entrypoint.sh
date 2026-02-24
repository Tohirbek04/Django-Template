#!/bin/bash
set -e

# Use the environment variables defined in docker-compose
DB_HOST="${DATABASE_HOST:-db}"
DB_PORT="${DATABASE_PORT:-5432}"
DB_USER="${DATABASE_USER:-postgres}"
REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PWD="${REDIS_PASSWORD:-}"

echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
while ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; do
  sleep 1
done
echo "PostgreSQL is ready!"

echo "Waiting for Redis at $REDIS_HOST..."
if [ -n "$REDIS_PWD" ]; then
  auth_args="-a $REDIS_PWD"
else
  auth_args=""
fi
until redis-cli -h "$REDIS_HOST" $auth_args ping >/dev/null 2>&1; do
  sleep 1
done
echo "Redis is ready!"

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting application..."
exec "$@"