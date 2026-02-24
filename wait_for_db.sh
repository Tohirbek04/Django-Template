#!/bin/bash
set -e

host="$1"
port="${2:-5432}"
shift 2 || shift 1

until pg_isready -h "$host" -p "$port" >/dev/null 2>&1; do
  >&2 echo "Postgres at $host:$port is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres at $host:$port is up - executing command"
exec "$@"