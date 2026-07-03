import uuid

import pytest
from django.contrib.auth import get_user_model


@pytest.mark.django_db
def test_user_has_uuid_pk_and_timestamps() -> None:
    user = get_user_model().objects.create_user(
        username="alice", password="s3cret!pass"
    )
    assert isinstance(user.pk, uuid.UUID)
    assert user.created_at is not None
    assert user.updated_at is not None


@pytest.mark.django_db
def test_auth_user_model_is_custom() -> None:
    assert get_user_model()._meta.label == "users.User"
