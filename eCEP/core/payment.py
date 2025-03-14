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