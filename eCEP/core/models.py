

from enum import unique
from random import choices
from turtle import title
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import duration, timezone
from django.core.exceptions import ValidationError
from datetime import timedelta

from .storage import SecureFileStorage

from django.db import models
import uuid


class User(AbstractUser):
    ROLE_CHOICES = [
        ('student', 'Étudiant'),
        ('teacher', 'Professeur'),
        ('parent', 'Parent'),
        ('admin', 'Administrateur'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='student')
    created_at = models.DateTimeField(default=timezone.now)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.username

    def authenticate(self):
        """Authentifie l'utilisateur"""
        return self.is_authenticated

    def update_profile(self, **kwargs):
        """Met à jour le profil de l'utilisateur"""
        for key, value in kwargs.items():
            setattr(self, key, value)
        self.save()

from keysGen.models import License

class Student(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    grade = models.CharField(max_length=50)
    level = models.IntegerField(default=1)
    points = models.PositiveBigIntegerField(default=0)
    total_exercises_completed = models.IntegerField(default=0)
    streak_days = models.IntegerField(default=0)
    last_activity_date = models.DateField(null=True, blank=True)

    def add_points(self, points):
        """Ajoute des points à l'étudiant"""
        self.points += points
        self.save()
        from .rewards import calculate_level, check_and_award_badges
        
        # Met à jour le niveau si nécessaire
        new_level = calculate_level(self.points)
        if new_level > self.level:
            self.level = new_level
            self.save()
            
        # Vérifie les badges
        check_and_award_badges(self)

    def update_streak(self):
        """Met à jour la série de jours d'activité"""
        today = timezone.now().date()
        
        if self.last_activity_date == today:
            return
        
        if self.last_activity_date == today - timezone.timedelta(days=1):
            self.streak_days += 1
        else:
            self.streak_days = 1
            
        self.last_activity_date = today
        self.save()

    def get_progress_to_next_level(self):
        """Obtient la progression vers le niveau suivant"""
        from .rewards import calculate_progress_to_next_level
        return calculate_progress_to_next_level(self.points)

    def get_recent_achievements(self):
        """Obtient les réalisations récentes"""
        return self.badges.order_by('-id')[:5]

    def get_statistics(self):
        """Obtient les statistiques de l'étudiant"""
        return {
            'total_points': self.points,
            'current_level': self.level,
            'progress_to_next_level': self.get_progress_to_next_level(),
            'exercises_completed': self.total_exercises_completed,
            'streak_days': self.streak_days,
            'badges_count': self.badges.count(),
            'recent_achievements': [
                {
                    'name': badge.name,
                    'description': badge.description,
                    'image_url': badge.image.url if badge.image else None
                }
                for badge in self.get_recent_achievements()
            ]
        }

    def submit_exercise(self, exercise, answers):
        """Soumet un exercice pour évaluation"""
        # Logique pour soumettre et évaluer un exercice
        score = exercise.evaluate(answers)
        Progress.objects.create(
            student=self,
            course=exercise.course,
            score=score
        )
        return score

    def access_course(self, course):
        """Accède à un cours"""
        if course in self.classes.all().values_list('courses', flat=True):
            return True
        raise ValidationError("Vous n'avez pas accès à ce cours")

    def download_content(self, resource):
        """Télécharge une ressource"""
        if resource.offline_available:
            return resource.url
        raise ValidationError("Cette ressource n'est pas disponible hors ligne")

    def get_summary_by_subject(self):
        return Progress.objects.filter(student=self).values('exercise__course__subject').annotate(
            total_exercises=Count('id'),
            avg_score=Avg('score'),
            total_time=Sum('completion_time')
        )

class Teacher(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    def create_exam(self, **kwargs):
        """Crée un nouvel examen"""
        return Exam.objects.create(**kwargs)

    def evaluate_student(self, student, course):
        """Évalue un étudiant"""
        progress = Progress.objects.select_related('student', 'course').filter(student=student)
        return progress.aggregate(models.Avg('score'))['score__avg']

    def create_content(self, course, **kwargs):
        """Crée du contenu pour un cours"""
        return Resource.objects.create(course=course, **kwargs)

    def manage_course(self, course, **kwargs):
        """Gère un cours"""
        for key, value in kwargs.items():
            setattr(course, key, value)
        course.save()

class Parent(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    children = models.ManyToManyField(Student, related_name='parents')

    def view_progress(self, child):
        """Consulte la progression d'un enfant"""
        if child in self.children.all():
            return Progress.objects.filter(student=child)
        raise ValidationError("Vous n'avez pas accès aux informations de cet étudiant")

    def receive_notifications(self):
        """Reçoit les notifications"""
        return Notification.objects.filter(recipient=self.user)

    def communicate_with_teacher(self, teacher, message):
        """Communique avec un professeur"""
        Notification.objects.create(
            type='info',
            message=message,
            recipient=teacher.user
        )

class Admin(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    def manage_users(self):
        """Gère les utilisateurs"""
        return User.objects.all()

    def moderate_content(self, content):
        """Modère le contenu"""
        content.is_approved = True
        content.save()

    def generate_reports(self):
        """Génère des rapports"""
        # Logique pour générer des rapports
        pass

    def configure_system(self, **settings):
        """Configure le système"""
        for key, value in settings.items():
            # Logique pour mettre à jour les paramètres système
            pass

class Video(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    file = models.FileField(upload_to='videos/')

class Pdf(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    file = models.FileField(upload_to='pdfs/')

class Audio(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    file = models.FileField(upload_to='audios/')



class Course(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200)
    subject = models.CharField(max_length=100)
    description = models.TextField()
    progress = models.IntegerField()
    image = models.ImageField(upload_to='courses/')
    isDownloaded = models.BooleanField(default=False)
    chapters = models.ManyToManyField('Chapter', related_name='courses')
    created_at = models.DateTimeField(auto_now_add=True)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='courses')
    totalLessons = models.IntegerField()
    totalExercises = models.IntegerField()

    # Ajoutez les champs pour les fichiers multimédias
    # video_file = models.FileField(upload_to='videos/', blank=True, null=True)
    video_file = models.ManyToManyField(Video, blank=True)
    # pdf_file = models.FileField(upload_to='pdfs/', blank=True, null=True)
    pdf_file = models.ManyToManyField(Pdf,  blank=True)
    # audio_file = models.FileField(upload_to='audios/', blank=True, null=True)
    audio_file = models.ManyToManyField(Audio, blank=True)

    def __str__(self):
        return self.title
    
    def create_lesson(self, **kwargs):
        """Crée une nouvelle leçon"""
        return Resource.objects.create(course=self, **kwargs)

    def update_content(self, **kwargs):
        """Met à jour le contenu du cours"""
        for key, value in kwargs.items():
            setattr(self, key, value)
        self.save()

    def update_progress(self):
        completed_exercises = self.exercises.filter(progress__student__in=self.classes.values('students')).count()
        self.progress = (completed_exercises / self.totalExercises) * 100 if self.totalExercises else 0
        self.save()

from django.core.validators import RegexValidator, FileExtensionValidator

# Validateur pour les formats de fichiers
file_validator = FileExtensionValidator(
    allowed_extensions=['pdf', 'mp4', 'mp3'],
    message="Seuls les fichiers PDF, MP4 et MP3 sont autorisés."
)

from django.core.files.storage import FileSystemStorage
from django.core.files.base import ContentFile
import subprocess

class CompressedFileStorage(FileSystemStorage):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    def save(self, name, content, max_length=None):
        # Compresser le fichier avant de le sauvegarder
        compressed_content = self.compress_file(content)
        return super().save(name, compressed_content, max_length)

    def compress_file(self, content):
        # Logique de compression (exemple avec FFmpeg pour les vidéos)
        compressed_file = ContentFile(b'')
        subprocess.run(['ffmpeg', '-i', content.temporary_file_path(), '-vf', 'scale=640:360', '-c:v', 'libx264', '-crf', '28', compressed_file.temporary_file_path()])
        return compressed_file

class Resource(models.Model):
    TYPE_CHOICES = [
        ('pdf', 'PDF'),
        ('video', 'Vidéo'),
        ('audio', 'Audio'),
        ('other', 'Autre'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='resources')
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    url = models.URLField()
    title = models.CharField(max_length=200)
    offline_available = models.BooleanField(default=False)
    file = models.FileField(
        upload_to='resources/%Y/%m/%d/',
        validators=[file_validator],
        storage=SecureFileStorage(),
        null=True,
        blank=True
    )
    file_size = models.IntegerField(default=0)
    download_count = models.IntegerField(default=0)
    last_downloaded = models.DateTimeField(null=True, blank=True)
    
    def save(self, *args, **kwargs):
        if self.file:
            self.file_size = self.file.size
        super().save(*args, **kwargs)

    def increment_download(self):
        self.download_count += 1
        self.last_downloaded = timezone.now()
        self.save()

    def download(self):
        """Télécharge la ressource"""
        return self.url

    def stream(self):
        """Diffuse la ressource"""
        if self.type in ['video', 'audio']:
            return self.url
        raise ValidationError("Cette ressource ne peut pas être diffusée")

class Exo(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    file = models.FileField(upload_to='exercices/')

class Choice(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    text = models.CharField(max_length=255)

class Question(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    text = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    choices = models.ManyToManyField(Choice, related_name='questions_choices')
    correctAnswer = models.CharField(max_length=255)

class Exercise(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='exercises')
    title = models.CharField(max_length=200)
    type = models.CharField(max_length=50) # Ex: 'qcm' , 'text'
    difficulty = models.IntegerField()
    points = models.IntegerField()
    isCompleted = models.BooleanField(default=False)
    score = models.IntegerField()
    questions = models.ManyToManyField(Question, related_name='exercises_questions')
    created_at = models.DateTimeField(auto_now_add=True)

    def evaluate(self, answers):
        total_score = 0
        for question in self.questions.all():
            if question.type == 'qcm':
                total_score += 1 if answers.get(str(question.id)) == question.correctAnswer else 0
            elif question.type == 'text':
                total_score += 1 if answers.get(str(question.id)).strip().lower() == question.correctAnswer.strip().lower() else 0
        return (total_score / self.questions.count()) * self.points if self.questions.count() else 0

    def submit_answer(self, student, answers):
        """Soumet une réponse"""
        score = self.evaluate(answers)
        return Progress.objects.create(
            student=student,
            course=self.course,
            score=score
        )

class Progress(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='progress')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='student_progress')
    score = models.FloatField()
    completion_time = models.DurationField(null=True, blank=True)
    completed_at = models.DateTimeField(auto_now=True)

    def update_progress(self, new_score):
        """Met à jour la progression"""
        self.score = new_score
        self.save()

    def generate_report(self):
        """Génère un rapport de progression"""
        return {
            'student': self.student.user.get_full_name(),
            'course': self.course.title,
            'score': self.score,
            'completed_at': self.completed_at
        }

class Class(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE, related_name='classes')
    students = models.ManyToManyField(Student, related_name='classes')
    courses = models.ManyToManyField(Course, related_name='classes')

    def add_student(self, student):
        """Ajoute un étudiant à la classe"""
        self.students.add(student)

    def remove_student(self, student):
        """Retire un étudiant de la classe"""
        self.students.remove(student)

    def assign_course(self, course):
        """Assigne un cours à la classe"""
        self.courses.add(course)

    def remove_course(self, course):
        """Retire un cours de la classe"""
        self.courses.remove(course)

class Badge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    description = models.TextField()
    image = models.ImageField(upload_to='badges/')
    isUnlocked = models.BooleanField(default=False)
    progress = models.IntegerField(default=0)
    targetProgress = models.IntegerField(default=0)
    required_points = models.IntegerField(default=0)
    students = models.ManyToManyField(Student, related_name='badges')

    def award(self, student):
        """Décerne le badge à un étudiant"""
        if student.points >= self.required_points:
            self.students.add(student)
            return True
        return False

    def check_eligibility(self, student):
        """Vérifie l'éligibilité d'un étudiant pour le badge"""
        return student.points >= self.required_points

class Challenge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    description = models.TextField()
    goal = models.CharField(max_length=50)  # Ex: 'complete_5_exercises'
    target_value = models.IntegerField()  # Ex: 5
    reward_points = models.IntegerField()
    reward_badge = models.ForeignKey(Badge, null=True, blank=True, on_delete=models.SET_NULL)

    def check_completion(self, student):
        sc = StudentChallenge.objects.get(student=student, challenge=self)
        return sc.progress >= self.target_value

class StudentChallenge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE)
    progress = models.IntegerField(default=0)
    completed = models.BooleanField(default=False)

    def update_progress(self, increment=1):
        self.progress += increment
        if self.progress >= self.challenge.target_value and not self.completed:
            self.completed = True
            self.student.add_points(self.challenge.reward_points)
            if self.challenge.reward_badge:
                self.challenge.reward_badge.award(self.student)
        self.save()

class Lesson(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    duration = models.IntegerField()
    isCompleted = models.BooleanField(default=False)

    def assign_course(self, course):
        """Assigne un cours à la classe"""
        self.courses.add(course)

    def remove_course(self, course):
        """Retire un cours de la classe"""
        self.courses.remove(course)

class Chapter(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255)
    progress = models.IntegerField(default=0)
    lessons = models.ManyToManyField(Lesson, related_name='chapters_lesson')
    exercise = models.ManyToManyField(Exercise, related_name="chapter_exercise")



from pyfcm import FCMNotification

class Notification(models.Model):
    TYPE_CHOICES = [
        ('info', 'Information'),
        ('success', 'Succès'),
        ('warning', 'Avertissement'),
        ('error', 'Erreur'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    read = models.BooleanField(default=False)

    # def send_push_notification(self):
    #     """Envoie une notification push à l'utilisateur."""
    #     if self.recipient.fcm_token:
    #         message_title = "Nouvelle notification"
    #         message_body = self.message
    #         result = push_service.notify_single_device(
    #             registration_id=self.recipient.fcm_token,
    #             message_title=message_title,
    #             message_body=message_body
    #         )
    #         return result
    #     return None

    def mark_as_read(self):
        """Marque la notification comme lue"""
        self.read = True
        self.save()

class Exam(models.Model):
    from .exam_management import ExamSession
    EXAM_TYPES = [
        ('practice', 'Examen Blanc'),
        ('final', 'Examen Final'),
        ('quiz', 'Quiz'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=200)
    type = models.CharField(max_length=20, choices=EXAM_TYPES, default='practice')
    date = models.DateTimeField()
    duration = models.DurationField(default=timedelta(hours=2))
    total_points = models.FloatField()
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='exams')
    exercises = models.ManyToManyField(Exercise, related_name='exams')
    is_practice = models.BooleanField(default=False)
    passing_score = models.FloatField(default=60.0)
    instructions = models.TextField(blank=True)
    allowed_attempts = models.IntegerField(default=1)
    
    class Meta:
        ordering = ['-date']
    
    def get_active_sessions(self):
        """Récupère les sessions d'examen actives"""
        from .exam_management import ExamSession
        return ExamSession.objects.filter(
            exam=self,
            end_time__isnull=True
        )
    
    def start_session(self, student):
        """Démarre une nouvelle session d'examen"""
        from .exam_management import ExamSession
        return ExamSession(self, student)
    
    def grade_exam(self, student_answers):
        """Note l'examen complet"""
        total_score = 0
        results = []
        
        for exercise, answer in student_answers.items():
            score = exercise.evaluate(answer)
            total_score += score * exercise.points
            
            results.append({
                'exercise': exercise,
                'score': score,
                'max_points': exercise.points
            })
        
        final_score = (total_score / self.total_points) * 100
        return {
            'score': final_score,
            'passed': final_score >= self.passing_score,
            'details': results
        }
    
    def get_statistics(self):
        """Obtient les statistiques de l'examen"""
        from .exam_management import analyze_exam_results
        return analyze_exam_results(self)
    
    def schedule_for_class(self, class_group):
        """Planifie l'examen pour une classe"""
        from .exam_management import schedule_exam
        schedule_exam(self, class_group)
    
    def generate_student_report(self, student):
        """Génère un rapport détaillé pour un étudiant"""
        from .exam_management import generate_exam_report
        return generate_exam_report(self, student)

class Payment(models.Model):
    from keysGen.models import License
    PAYMENT_TYPES = [
        ('mobile', 'Paiement Mobile'),
        ('card', 'Carte Bancaire'),
        ('transfer', 'Virement Bancaire'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('refunded', 'Remboursé'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    license = models.ForeignKey(License, on_delete=models.CASCADE, related_name='payments')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='XAF')
    payment_type = models.CharField(max_length=20, choices=PAYMENT_TYPES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    transaction_id = models.CharField(max_length=100, unique=True)
    payment_date = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-payment_date']
    
    from django.db import transaction
    @transaction.atomic
    def process_payment(self):
        """Traite le paiement"""
        from .payment_processing import process_payment
        success = process_payment(self)
        
        if success:
            self.status = 'completed'
            self.license.status = 'active'
            self.license.save()
        else:
            self.status = 'failed'
        
        self.save()
        return success
    
    def generate_receipt(self):
        """Génère un reçu de paiement"""
        from .payment_processing import generate_receipt
        return generate_receipt(self)

class Subscription(models.Model):
    from keysGen.models import License
    """Gère les abonnements récurrents"""
    INTERVAL_CHOICES = [
        ('monthly', 'Mensuel'),
        ('quarterly', 'Trimestriel'),
        ('yearly', 'Annuel'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='subscriptions')
    license = models.ForeignKey(License, on_delete=models.CASCADE, related_name='subscription')
    interval = models.CharField(max_length=20, choices=INTERVAL_CHOICES)
    auto_renew = models.BooleanField(default=True)
    next_billing_date = models.DateTimeField()
    
    def process_renewal(self):
        """Traite le renouvellement automatique"""
        if not self.auto_renew:
            return False
            
        payment = Payment.objects.create(
            user=self.user,
            license=self.license,
            amount=self.get_renewal_amount(),
            payment_type=self.user.preferred_payment_method
        )
        
        success = payment.process_payment()
        if success:
            self.update_next_billing_date()
        return success
    
    def update_next_billing_date(self):
        """Met à jour la prochaine date de facturation"""
        intervals = {
            'monthly': 1,
            'quarterly': 3,
            'yearly': 12
        }
        months = intervals.get(self.interval, 1)
        self.next_billing_date = timezone.now() + timedelta(days=30 * months)
        self.save()
    
    def get_renewal_amount(self):
        """Calcule le montant du renouvellement"""
        from .payment_processing import calculate_subscription_amount
        return calculate_subscription_amount(self.license.type, self.interval)

from django.core.validators import RegexValidator

phone_validator = RegexValidator(
    regex=r'^\+?[0-9]{9,15}$',
    message="Le numéro de téléphone doit être au format international."
)

class MobilePayment(models.Model):
    PROVIDER_CHOICES = [
        ('ligdicash', 'LigdiCash'),
        ('orange', 'Orange Money'),
        ('mtn', 'MTN Mobile Money'),
    ]
    
    STATUS_CHOICES = [
        ('initiated', 'Initié'),
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('cancelled', 'Annulé'),
    ]
    
    payment = models.OneToOneField(
        Payment,
        on_delete=models.CASCADE,
        related_name='mobile_payment'
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    provider = models.CharField(max_length=20, choices=PROVIDER_CHOICES)
    phone_number = models.CharField(max_length=20, validators=[phone_validator], blank=True, null=True)
    reference = models.CharField(max_length=100, unique=True)
    status = models.CharField(max_length=20,choices=STATUS_CHOICES,default='initiated')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='mobile_payments')
    callback_url = models.URLField(blank=True, null=True)
    callback_data = models.JSONField(default=dict)
    initiated_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-initiated_at']

    def __str__(self):
        return f"{self.reference} - {self.status}"

    def initiate_payment(self):
        # Code pour initier un paiement via LigdiCash
        from .payment_providers import initiate_mobile_payment
        success, reference = initiate_mobile_payment(self)
        
        if success:
            self.reference = reference
            self.status = 'pending'
            self.save()
        return success
    
    def check_status(self):
        # Code pour vérifier le statut du paiement auprès de LigdiCash
        from .payment_providers import check_payment_status
        status = check_payment_status(self)
        
        if status != self.status:
            self.status = status
            if status == 'completed':
                self.completed_at = timezone.now()
                self.payment.status = 'completed'
                self.payment.save()
            elif status in ['failed', 'cancelled']:
                self.payment.status = 'failed'
                self.payment.save()
            self.save()
        
        return status
    
    def process_callback(self, data):
        # Traiter les callbacks reçus de LigdiCash
        self.callback_data = data
        status = data.get('status')
        
        if status in dict(self.STATUS_CHOICES):
            self.status = status
            if status == 'completed':
                self.completed_at = timezone.now()
                self.payment.status = 'completed'
                self.payment.save()
            elif status in ['failed', 'cancelled']:
                self.payment.status = 'failed'
                self.payment.save()
        
        self.save()
        return self.status

class MobilePaymentConfig(models.Model):
    """Configuration des fournisseurs de paiement mobile"""
    PROVIDER_CHOICES = [
        ('orange', 'Orange Money'),
        ('mtn', 'MTN Mobile Money'),
    ]
    
    provider = models.CharField(
        max_length=20,
        choices=PROVIDER_CHOICES,
        unique=True
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    merchant_id = models.CharField(max_length=100)
    api_key = models.CharField(max_length=100)
    api_secret = models.CharField(max_length=100)
    api_url = models.URLField()
    callback_url = models.URLField()
    is_active = models.BooleanField(default=True)
    test_mode = models.BooleanField(default=False)
    
    def get_credentials(self):
        """Retourne les informations d'authentification"""
        return {
            'merchant_id': self.merchant_id,
            'api_key': self.api_key,
            'api_secret': self.api_secret,
            'api_url': self.api_url,
            'callback_url': self.callback_url,
            'test_mode': self.test_mode
        }

class LicensePayment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE)
    license = models.ForeignKey(License, on_delete=models.CASCADE, null=True, blank=True)
    payment_type = models.CharField(max_length=20, choices=[('new', 'New License'), ('renew', 'Renew License')])
    duration_months = models.IntegerField()

class ExamSessionModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE)
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    start_time = models.DateTimeField(default=timezone.now)
    answers = models.JSONField(default=dict)
    completed = models.BooleanField(default=False)

    def submit_answer(self, exercise_id, answer):
        self.answers[str(exercise_id)] = {
            'answer': answer,
            'time': timezone.now().isoformat()
        }
        self.save()

    def complete(self):
        self.completed = True
        self.save()
        score = self.exam.grade_exam(self.answers)
        Progress.objects.create(
            student=self.student,
            course=self.exam.course,
            score=score['score'],
            completion_time=timezone.now() - self.start_time
        )
        return score
        