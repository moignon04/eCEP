from decimal import Decimal
from datetime import datetime, timedelta
from django.template.loader import render_to_string
from django.conf import settings

def process_payment(payment):
    """
    Traite un paiement selon son type
    """
    if payment.payment_type == 'mobile':
        return True  # Le traitement est géré par le module payment_providers
    elif payment.payment_type == 'card':
        return process_card_payment(payment)
    elif payment.payment_type == 'transfer':
        return process_transfer_payment(payment)
    return False

def process_card_payment(payment):
    """
    Traite un paiement par carte
    À implémenter avec un processeur de paiement par carte
    """
    return False

def process_transfer_payment(payment):
    """
    Traite un paiement par virement
    Le statut sera mis à jour manuellement
    """
    return True

def calculate_subscription_amount(license_type, interval):
    """
    Calcule le montant d'un abonnement selon le type de licence et l'intervalle
    """
    base_prices = {
        'basic': Decimal('5000'),    # 5,000 XAF par mois
        'premium': Decimal('10000'), # 10,000 XAF par mois
        'school': Decimal('50000')   # 50,000 XAF par mois
    }
    
    interval_multipliers = {
        'monthly': 1,
        'quarterly': 2.7,  # 10% de réduction
        'yearly': 10      # 17% de réduction
    }
    
    base_price = base_prices.get(license_type, Decimal('5000'))
    multiplier = Decimal(str(interval_multipliers.get(interval, 1)))
    
    return base_price * multiplier

def generate_receipt(payment):
    """
    Génère un reçu de paiement au format HTML
    """
    context = {
        'payment': payment,
        'user': payment.user,
        'license': payment.license,
        'company_name': 'eCEP',
        'company_address': 'Yaoundé, Cameroun',
        'company_phone': '+226 6X XX XX XX',
        'company_email': 'contact@ecep.cm',
        'generated_at': datetime.now(),
    }
    
    html_content = render_to_string('payment.html', context)
    return {
        'html': html_content,
        'payment_id': payment.id,
        'amount': str(payment.amount),
        'date': payment.payment_date.strftime('%Y-%m-%d %H:%M:%S')
    }

def send_payment_notification(payment):
    """
    Envoie une notification de paiement à l'utilisateur
    """
    from .models import Notification
    
    if payment.status == 'completed':
        message = f"Votre paiement de {payment.amount} {payment.currency} a été confirmé."
    elif payment.status == 'failed':
        message = f"Votre paiement de {payment.amount} {payment.currency} a échoué."
    else:
        return
    
    Notification.objects.create(
        user=payment.user,
        type='payment',
        message=message,
        data={
            'payment_id': payment.id,
            'amount': str(payment.amount),
            'status': payment.status
        }
    )

def check_expired_subscriptions():
    """
    Vérifie et traite les abonnements expirés
    À exécuter quotidiennement via une tâche cron
    """
    from .models import Subscription
    
    today = datetime.now()
    expiring_soon = today + timedelta(days=7)
    
    # Trouve les abonnements qui expirent bientôt
    subscriptions = Subscription.objects.filter(
        next_billing_date__lte=expiring_soon,
        auto_renew=True
    )
    
    for subscription in subscriptions:
        if subscription.next_billing_date <= today:
            # Tente le renouvellement
            subscription.process_renewal()
        else:
            # Envoie un rappel
            send_renewal_reminder(subscription)

def send_renewal_reminder(subscription):
    """
    Envoie un rappel de renouvellement
    """
    from .models import Notification
    
    days_left = (subscription.next_billing_date - datetime.now()).days
    amount = calculate_subscription_amount(
        subscription.license.type,
        subscription.interval
    )
    
    message = (
        f"Votre abonnement sera renouvelé automatiquement dans {days_left} jours. "
        f"Montant : {amount} FCFA"
    )
    
    Notification.objects.create(
        user=subscription.user,
        type='renewal_reminder',
        message=message,
        data={
            'subscription_id': subscription.id,
            'days_left': days_left,
            'amount': str(amount)
        }
    )

import qrcode
from io import BytesIO
from django.core.files.base import ContentFile

def generate_qr_code(payment):
    """
    Génère un QR code pour le paiement
    """
    # Lien ou texte à encoder
    qr_data = f"https://ecep.cm/verify/{payment.transaction_id}"
    
    # Créer le QR code
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(qr_data)
    qr.make(fit=True)

    # Créer une image du QR code
    img = qr.make_image(fill_color="black", back_color="white")

    # Enregistrer l'image dans un buffer
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)

    # Créer un fichier ContentFile pour l'enregistrement
    qr_code_file = ContentFile(buffer.read(), name=f"qr_code_{payment.transaction_id}.png")
    
    # Retourner le fichier QR code
    return qr_code_file