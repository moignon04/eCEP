import firebase_admin
from firebase_admin import messaging
from django.conf import settings

firebase_admin.initialize_app()

def send_push_notification(user, title, body):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=user.device_token  # Suppose un champ device_token dans User
    )
    response = messaging.send(message)
    return response