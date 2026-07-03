import pytest
from django.test import Client


@pytest.mark.django_db
def test_healthz_returns_200_when_healthy() -> None:
    client = Client()
    response = client.get("/healthz/")
    payload = response.json()
    assert response.status_code == 200
    assert payload["status"] == "healthy"
    assert payload["checks"]["database"] == "ok"
    assert payload["checks"]["cache"] == "ok"


def test_base_model_is_abstract() -> None:
    from apps.common.models import BaseModel

    assert BaseModel._meta.abstract is True


def test_ping_task_runs_eagerly() -> None:
    from apps.common.tasks import ping

    result = ping.delay()
    assert result.get(timeout=5) == "pong"
