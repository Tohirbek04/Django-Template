from celery import shared_task


@shared_task
def ping() -> str:
    """Smoke-test task: verifies the Celery pipeline end to end."""
    return "pong"
