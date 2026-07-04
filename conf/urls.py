from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

from apps.common.views import healthz

urlpatterns = [
    path("admin/", admin.site.urls),
    path("healthz/", healthz, name="healthz"),
    # Prometheus metrics
    path("", include("django_prometheus.urls")),
    # API routes — project convention: DefaultRouter(trailing_slash=False)
    # from rest_framework.routers import DefaultRouter
    # router = DefaultRouter(trailing_slash=False)
    # router.register("things", ThingViewSet, basename="thing")
    # urlpatterns += [path("api/v1/", include(router.urls))]
]

if settings.DEBUG:
    import debug_toolbar

    urlpatterns += [
        path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
        path("", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
        path(
            "api/schema/redoc/",
            SpectacularRedocView.as_view(url_name="schema"),
            name="redoc",
        ),
        path("__debug__/", include(debug_toolbar.urls)),
    ]
