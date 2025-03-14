
# Register your models here.
# keysGen/admin.py
from django.contrib import admin
from .models import License

@admin.register(License)
class ActivationKeyAdmin(admin.ModelAdmin):
    list_display = ('serial_number', 'user', 'expiration_date')  # Champs valides
    list_filter = ('expiration_date',)
    search_fields = ('serial_number', 'user__username')