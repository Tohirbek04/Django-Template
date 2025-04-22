# from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

from conf import settings

urlpatterns = [
    path('admin/', admin.site.urls),
    # path('api/v1/', include('apps.urls')),
]
if settings.DEBUG:


    import debug_toolbar

    urlpatterns += [
        path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
        # Optional UI:
        path('', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
        path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
        path('__debug__', include(debug_toolbar.urls)),
    ]
