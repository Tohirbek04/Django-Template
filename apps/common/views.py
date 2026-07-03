from django.core.cache import cache
from django.db import connection
from django.http import HttpRequest, JsonResponse


def healthz(request: HttpRequest) -> JsonResponse:
    """Health check endpoint for container orchestration and Traefik."""
    health_status: dict = {"status": "healthy", "checks": {}}

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        health_status["checks"]["database"] = "ok"
    except Exception as exc:  # noqa: BLE001 — health endpoint must never raise
        health_status["checks"]["database"] = f"error: {exc}"
        health_status["status"] = "unhealthy"

    try:
        cache.set("healthz", "ok", 10)
        if cache.get("healthz") == "ok":
            health_status["checks"]["cache"] = "ok"
        else:
            health_status["checks"]["cache"] = "error: cache read failed"
            health_status["status"] = "unhealthy"
    except Exception as exc:  # noqa: BLE001
        health_status["checks"]["cache"] = f"error: {exc}"
        health_status["status"] = "unhealthy"

    status_code = 200 if health_status["status"] == "healthy" else 503
    return JsonResponse(health_status, status=status_code)
