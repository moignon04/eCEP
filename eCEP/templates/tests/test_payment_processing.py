from django.test import TestCase
from core.models import User, License, Payment, MobilePayment
from core.payment_processing import generate_qr_code
from core.models import Student, Exam, Exercise, Progress
from core.exam_management import create_practice_exam

class MobilePaymentTests(TestCase):
    def setUp(self):
        # Créez un utilisateur pour le test
        self.user = User.objects.create_user(username='testuser', password='testpass')
        self.mobile_payment = MobilePayment.objects.create(amount=100, user=self.user)

    def test_mobile_payment_creation(self):
        self.assertEqual(self.mobile_payment.amount, 100)

class MobilePaymentCreationTests(TestCase):
    def test_mobile_payment_creation(self):
        # Test pour vérifier la création d'un paiement mobile
        payment = MobilePayment.objects.create(amount=100)
        self.assertEqual(payment.amount, 100)

class ExamManagementTests(TestCase):

    def setUp(self):
        self.student = Student.objects.create(user=self.user)
        self.exercise = Exercise.objects.create(title="Exercise 1", points=10, difficulty=1)
        self.exam = create_practice_exam("Math", 1, num_exercises=5)

    def test_create_practice_exam(self):
        self.assertIsNotNone(self.exam)
        self.assertEqual(self.exam.exercises.count(), 5)

    def test_analyze_exam_results(self):
        # Simuler des résultats de progrès pour l'examen
        Progress.objects.create(student=self.student, exercise=self.exercise, score=80)
        results = analyze_exam_results(self.exam)
        self.assertGreaterEqual(results['average_score'], 0)

    # Ajoutez d'autres tests pour les autres fonctions

class PaymentProcessingTests(TestCase):

    def setUp(self):
        # Créer un utilisateur de test
        self.user = User.objects.create_user(
            username='testuser',
            password='password',
            email='testuser@example.com'
        )
        # Créer une licence de test
        self.license = License.objects.create(
            user=self.user,
            type='basic',
            start_date='2025-01-01',
            end_date='2026-01-01'
        )
        # Créer un paiement de test
        self.payment = Payment.objects.create(
            user=self.user,
            license=self.license,
            amount=Decimal('10000.00'),
            currency='XAF',
            payment_type='mobile',
            status='completed',
            transaction_id='TRANS12345'
        )

    def test_generate_qr_code(self):
        qr_code_file = generate_qr_code(self.payment)
        self.assertIsNotNone(qr_code_file)
        self.assertTrue(qr_code_file.name.startswith('qr_code_'))
        self.assertTrue(qr_code_file.name.endswith('.png'))

    def test_payment_receipt_generation(self):
        receipt = generate_receipt(self.payment)
        self.assertIn('html', receipt)
        self.assertIn('payment_id', receipt)
        self.assertIn('amount', receipt)
        self.assertIn('date', receipt)

    def tearDown(self):
        self.user.delete()
        self.license.delete()
        self.payment.delete()