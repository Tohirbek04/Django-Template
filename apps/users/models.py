from django.contrib.auth.models import AbstractUser

from apps.common.models import BaseModel


class User(BaseModel, AbstractUser):
    """Project user. Extend with profile fields as needed."""

    class Meta(AbstractUser.Meta):
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return self.username
