
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('core.api.urls')),  # Les URLs de notre API
    path('core/', include('core.urls')),
    path('keysGen/', include('keysGen.urls')),  # Les URLs de notre application de génération de clé d'activation
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
