from django.test import TestCase
from .models import Payment, User, License

class PaymentTests(TestCase):
    def setUp(self):
        self.user = User.objects.create(username='testuser', role='student')
        self.license = License.objects.create(user=self.user, status='pending')
        self.payment = Payment.objects.create(
            user=self.user,
            license=self.license,
            amount=100.00,
            currency='XAF',
            payment_type='mobile',
            status='pending'
        )

    def test_payment_processing(self):
        """Teste le traitement d'un paiement."""
        success = self.payment.process_payment()
        self.assertTrue(success)
        self.assertEqual(self.payment.status, 'completed')
        self.assertEqual(self.license.status, 'active')