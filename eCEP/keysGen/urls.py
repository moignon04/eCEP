# keysGen/urls.py
from django.urls import path
from .views import generate_activation_key

urlpatterns = [
    path('generate-key/', generate_activation_key, name='generate_activation_key'),
]