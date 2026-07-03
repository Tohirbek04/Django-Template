import uuid

from django.db.models import DateTimeField, Model, UUIDField


class BaseModel(Model):
    """Abstract base: UUID primary key + created/updated timestamps."""

    id = UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ["-created_at"]
