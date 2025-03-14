from django.core.files.storage import FileSystemStorage
from django.conf import settings
import os
import hashlib

class SecureFileStorage(FileSystemStorage):
    def __init__(self):
        super().__init__(location=settings.MEDIA_ROOT)

    def get_valid_name(self, name):
        """Génère un nom de fichier sécurisé"""
        ext = os.path.splitext(name)[1]
        name_hash = hashlib.sha256(name.encode()).hexdigest()
        return f"{name_hash}{ext}"

    def get_available_name(self, name, max_length=None):
        """S'assure que le nom du fichier est unique"""
        if self.exists(name):
            dir_name, file_name = os.path.split(name)
            file_root, file_ext = os.path.splitext(file_name)
            counter = 1
            while self.exists(name):
                name = os.path.join(dir_name, f"{file_root}_{counter}{file_ext}")
                counter += 1
        return name