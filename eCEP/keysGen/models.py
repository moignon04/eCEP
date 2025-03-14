from django.db import models
import uuid
from core.models import User
# Create your models here.

class License(models.Model):
    id = models.UUIDField(auto_created=True,primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, default=None)  # Allow null for now
    serial_number = models.CharField(max_length=50, unique=True, default=uuid.uuid4)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)
    expiration_date = models.DateField()  # Allow null for now
    
    def __str__(self):
        return str(self.serial_number)

    def generate_key(cls):
        new_key = cls()
        new_key.save()
        return new_key.serial_number

    def clean(self):
        """Valide la clé de licence."""
        if not isinstance(self.serial_number, uuid.UUID):
            raise ValidationError("La clé de licence doit être un UUID valide.")
        super().clean()

    def renew(self, duration_months):
        if self.expiration_date:
            self.expiration_date += datetime.timedelta(days=duration_months * 30)
        else:
            self.expiration_date = datetime.date.today() + datetime.timedelta(days=duration_months * 30)
        self.save()

    def is_expired(self):
        return self.expiration_date < datetime.datetime.now()

