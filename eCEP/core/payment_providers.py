import requests
import uuid
from datetime import datetime
from django.conf import settings

def get_provider_config(provider):
    """Récupère la configuration du fournisseur de paiement"""
    from .models import MobilePaymentConfig
    try:
        return MobilePaymentConfig.objects.get(
            provider=provider,
            is_active=True
        )
    except MobilePaymentConfig.DoesNotExist:
        return None

def generate_reference():
    """Génère une référence unique pour le paiement"""
    return f"PAY-{datetime.now().strftime('%Y%m%d')}-{uuid.uuid4().hex[:8]}"

def initiate_mobile_payment(payment):
    """Initie un paiement mobile avec le fournisseur approprié"""
    config = get_provider_config(payment.provider)
    if not config:
        return False, None
    
    if payment.provider == 'orange':
        return initiate_orange_money_payment(payment, config)
    elif payment.provider == 'mtn':
        return initiate_mtn_money_payment(payment, config)
    elif payment.provider == 'ligdicash':
        return initiate_ligdicash_payment(payment, config)
    
    return False, None

def check_payment_status(payment):
    """Vérifie le statut d'un paiement"""
    config = get_provider_config(payment.provider)
    if not config:
        return 'failed'
    
    if payment.provider == 'orange':
        return check_orange_money_status(payment, config)
    elif payment.provider == 'mtn':
        return check_mtn_money_status(payment, config)
    elif payment.provider == 'ligdicash':
        return check_ligdicash_status(payment, config)
    return 'failed'

import logging

logger = logging.getLogger(__name__)

def initiate_orange_money_payment(payment, config):
    """Initie un paiement Orange Money"""
    reference = generate_reference()
    
    headers = {
        'Authorization': f'Bearer {config.api_key}',
        'Content-Type': 'application/json'
    }
    
    payload = {
        'merchant_id': config.merchant_id,
        'reference': reference,
        'amount': str(payment.payment.amount),
        'currency': payment.payment.currency,
        'phone_number': payment.phone_number,
        'callback_url': f"{config.callback_url}/orange/{reference}/",
        'description': f"Paiement {payment.payment.license.type}"
    }
    
    try:
        response = requests.post(
            f"{config.api_url}/payment/initiate",
            json=payload,
            headers=headers
        )
        
        if response.status_code == 200:
            return True, reference
        else:
            logger.error(f"Échec de l'initiation du paiement Orange Money: {response.status_code} - {response.text}")
            return False, None   
    except requests.exceptions.RequestException as e:
        logger.error(f"Erreur lors de l'initiation du paiement Orange Money: {e}")
        return False, None

def initiate_mtn_money_payment(payment, config):
    """Initie un paiement MTN Mobile Money"""
    reference = generate_reference()
    
    headers = {
        'X-API-Key': config.api_key,
        'Content-Type': 'application/json'
    }
    
    payload = {
        'merchant': config.merchant_id,
        'reference': reference,
        'amount': str(payment.payment.amount),
        'currency': payment.payment.currency,
        'phone': payment.phone_number,
        'callback': f"{config.callback_url}/mtn/{reference}/",
        'description': f"Paiement {payment.payment.license.type}"
    }
    
    try:
        response = requests.post(
            f"{config.api_url}/collections/initiate",
            json=payload,
            headers=headers
        )
        
        if response.status_code == 200:
            return True, reference
        return False, None
        
    except requests.exceptions.RequestException:
        return False, None

def initiate_ligdicash_payment(payment, config):
    reference = generate_reference()
    
    headers = {
        'X-API-Key': config.api_key,
        'Content-Type': 'application/json'
    }
    
    payload = {
        'merchant': config.merchant_id,
        'reference': reference,
        'amount': str(payment.payment.amount),
        'currency': payment.payment.currency,
        'phone': payment.phone_number,
        'callback': f"{config.callback_url}/ligdicash/{reference}/",
        'description': f"Paiement {payment.payment.license.type}"
    }
    
    try:
        response = requests.post(
            f"{config.api_url}/collections/initiate",
            json=payload,
            headers=headers
        )
        
        if response.status_code == 200:
            return True, reference
        return False, None
        
    except requests.exceptions.RequestException:
        return False, None

def check_orange_money_status(payment, config):
    """Vérifie le statut d'un paiement Orange Money"""
    headers = {
        'Authorization': f'Bearer {config.api_key}',
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.get(
            f"{config.api_url}/payment/status/{payment.reference}",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            return data.get('status', 'failed')
        return 'failed'
        
    except requests.exceptions.RequestException:
        return 'failed'

def check_mtn_money_status(payment, config):
    """Vérifie le statut d'un paiement MTN Mobile Money"""
    headers = {
        'X-API-Key': config.api_key,
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.get(
            f"{config.api_url}/collections/status/{payment.reference}",
            headers=headers
        )
        
        if response.status_code == 200:
            data = response.json()
            return data.get('status', 'failed')
        return 'failed'
        
    except requests.exceptions.RequestException:
        return 'failed'

def check_ligdicash_status(payment, config):
    # Décrire la facture et le client
    from eCEP.core.models import Payment


    invoice = ligdicash.Invoice(
        currency="xof",
        description="Facture pour l'achat de vêtements sur MaSuperBoutique.com",
        customer_firstname="Cheik",
        customer_lastname="Cissé",
        customer_email="cheikcisse@gmail.com",
        store_name="MaSuperBoutique",
        store_website_url="masuperboutique.com",
    )

    # Ajouter des éléments(produit, service, etc) à la facture
    invoice.add_item(
        name="Premier produit",
        description="__description_du_produit__",
        quantity=3,
        unit_price=3500,
    )

    payment = Payment.object.create(
        user=user,
        amount=invoice.total_amount,
        payment_type='mobile',
        )

    response = invoice.pay_with_redirection(
        return_url="https://masuperboutique.com/success",
        callback_url="https://masuperboutique.com/cancel",
        callback_url="https://backend.masuperboutique.com/callback",
        custom_data={
            "order_id": "ORD-1234567890",
            "customer_id": "CUST-1234567890",
        },
    ) 

    payment_url = response.response_text
    redirect_user(payment_url)