from rest_framework import serializers
from django.contrib.auth import authenticate
from core.models import Payment,Subscription
from keysGen.models import License
from core.models import (
    User, Student, Teacher, Parent, Admin, Course, Resource, Exercise, Progress,
    Class, Badge, Notification, Exam, Payment, Subscription, MobilePayment,
    MobilePaymentConfig, Challenge, StudentChallenge, ExamSessionModel,
    Video, Pdf, Audio, Choice, Question, Exo, Lesson, Chapter
)
import uuid # Pour générer des références uniques si nécessaires

class SubjectSummarySerializer(serializers.Serializer):
    subject = serializers.CharField(source='exercise__course__subject')
    total_exercises = serializers.IntegerField()
    avg_score = serializers.FloatField()
    total_time = serializers.DurationField()

class TeacherDashboardSerializer(serializers.ModelSerializer):
    class_stats = serializers.SerializerMethodField()

    class Meta:
        model = Teacher
        fields = ('id', 'class_stats')

    def get_class_stats(self, obj):
        return Class.objects.filter(teacher=obj).values('name').annotate(
            total_students=Count('students'),
            avg_progress=Avg('students__progress__score')
        )

class ExerciseInteractiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = ('id', 'title', 'type', 'difficulty', 'content')

class StudentDashboardSerializer(serializers.ModelSerializer):
    summary_by_subject = SubjectSummarySerializer(many=True)

    class Meta:
        model = Student
        fields = ('id', 'points', 'streak_days', 'total_exercises_completed', 'summary_by_subject')

    def get_summary_by_subject(self, obj):
        return obj.get_summary_by_subject()

class AdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admin
        fields = '__all__'  # ou spécifiez les champs que vous voulez inclure

class SubscriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subscription  # Assurez-vous que Subscription est importé
        fields = '__all__'  # ou spécifiez les champs que vous voulez inclure

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = '__all__'  # ou spécifiez les champs que vous voulez inclure

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Le montant doit être positif.")
        return value

    def validate_status(self, value):
        allowed_statuses = ['pending', 'completed', 'falled']
        if value not in allowed_statuses:
            raise serializers.ValidationError(f"Le statut doit être l'un des suivants : {allowed_statuses}")
        return value

        
class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(
            username=data.get('username'),
            password=data.get('password')
        )
        if user is None:
            raise serializers.ValidationError("Nom d'utilisateur ou mot de passe incorrect.")
        self.context['user'] = user
        return {'user': user} # Retourne l'utilisateur validé

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'password', 'role')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class StudentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = Student
        fields = ('id', 'user', 'grade', 'level', 'points')

class TeacherSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = Teacher
        fields = ('id', 'user')

class ParentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    children = StudentSerializer(many=True, read_only=True)
    class Meta:
        model = Parent
        fields = ('id', 'user', 'children')

class ResourceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Resource
        fields = ('id', 'type', 'url', 'title', 'offline_available', 'file')

class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Question
        fields = ('id', 'question', 'type', 'points', 'options')

class ChallengeSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, read_only=True)
    class Meta:
        model = Challenge
        fields = ('id', 'title', 'type', 'points', 'questions')

class StudentChallengeSerializer(serializers.ModelSerializer):
    challenge = ChallengeSerializer()
    class Meta:
        model = StudentChallenge
        fields = ('id', 'challenge', 'progress', 'completed')
        
class ExerciseSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, read_only=True)
    class Meta:
        model = Exercise
        fields = ('id', 'title', 'type', 'difficulty', 'points', 'questions')

class CourseSerializer(serializers.ModelSerializer):
    resources = ResourceSerializer(many=True, read_only=True)
    exercises = ExerciseSerializer(many=True, read_only=True)
    video_file = serializers.SerializerMethodField()
    pdf_file = serializers.SerializerMethodField()
    audio_file = serializers.SerializerMethodField()
    chapters = serializers.SerializerMethodField()

    class Meta:
        model = Course
        fields = ('id', 'title', 'subject', 'description', 'progress', 'created_at', 'teacher',
                  'resources', 'exercises', 'video_file', 'pdf_file', 'audio_file', 'chapters')

    def get_video_file(self, obj):
        videos = obj.video_file.all()
        return VideoSerializer(videos, many=True).data

    def get_pdf_file(self, obj):
        pdfs = obj.pdf_file.all()
        return PdfSerializer(pdfs, many=True).data

    def get_audio_file(self, obj):
        audios = obj.audio_file.all()
        return AudioSerializer(audios, many=True).data

    def get_chapters(self, obj):
        chapters = obj.chapters.all()
        return ChapterSerializer(chapters, many=True).data

class VideoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Video
        fields = ('id', 'file')

class PdfSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pdf
        fields = ('id', 'file')

class AudioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Audio
        fields = ('id', 'file')

class ChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Choice
        fields = ('id', 'text')

class QuestionSerializer(serializers.ModelSerializer):
    choices = ChoiceSerializer(many=True, read_only=True)
    class Meta:
        model = Question
        fields = ('id', 'text', 'type', 'choices', 'correctAnswer')

class ExoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exo
        fields = ('id', 'file')

class LessonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lesson
        fields = ('id', 'title', 'type', 'duration', 'isCompleted')

class ChapterSerializer(serializers.ModelSerializer):
    lessons = LessonSerializer(many=True, read_only=True)
    exercise = ExerciseSerializer(many=True, read_only=True)
    class Meta:
        model = Chapter
        fields = ('id', 'title', 'progress', 'lessons', 'exercise')


class ProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Progress
        fields = ('id', 'student', 'course', 'score', 'completed_at')

class ClassSerializer(serializers.ModelSerializer):
    students = StudentSerializer(many=True, read_only=True)
    courses = CourseSerializer(many=True, read_only=True)
    
    class Meta:
        model = Class
        fields = ('id', 'name', 'teacher', 'students', 'courses')

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = ('id', 'name', 'description', 'image', 'required_points')

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ('id', 'type', 'message', 'created_at', 'recipient', 'read')

class ExamSerializer(serializers.ModelSerializer):
    exercises = ExerciseSerializer(many=True, read_only=True)
    duration_minutes = serializers.SerializerMethodField()
    
    class Meta:
        model = Exam
        fields = (
            'id', 'title', 'type', 'date', 'duration', 'duration_minutes',
            'total_points', 'course', 'exercises', 'is_practice',
            'passing_score', 'instructions', 'allowed_attempts'
        )
    
    def get_duration_minutes(self, obj):
        """Convertit la durée en minutes pour le frontend"""
        if hasattr(obj.duration, 'total_seconds'):  # Vérifie que c'est un timedelta
            return obj.duration.total_seconds() / 60
        return obj.duration  # Si c'est déjà en minutes ou autre format

class ExamSessionSerializer(serializers.Serializer):
    session_id = serializers.IntegerField()
    remaining_time = serializers.CharField()
    answers = serializers.DictField(child=serializers.DictField())
    
    class Meta:
        fields = ('session_id', 'remaining_time', 'answers')

class ExamResultSerializer(serializers.Serializer):
    score = serializers.FloatField()
    passed = serializers.BooleanField()
    details = serializers.ListField(child=serializers.DictField())
    completion_time = serializers.DurationField()
    
    class Meta:
        fields = ('score', 'passed', 'details', 'completion_time')

class ExamStatisticsSerializer(serializers.Serializer):
    average_score = serializers.FloatField()
    completion_rate = serializers.FloatField()
    difficulty_distribution = serializers.ListField(
        child=serializers.DictField()
    )
    time_distribution = serializers.ListField(
        child=serializers.DictField()
    )
    
    class Meta:
        fields = (
            'average_score', 'completion_rate',
            'difficulty_distribution', 'time_distribution'
        )


# Sérialiseurs pour l'inscription et l'authentification
class UserRegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password2', 
                 'first_name', 'last_name', 'role')
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError("Les mots de passe ne correspondent pas")
        return data

    def create(self, validated_data):
        validated_data.pop('password2') # Retirer password2
        # user = User.objects.create_user(**validated_data)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            # role=validated_data['role']
        )
        return user

class MobilePaymentSerializer(serializers.ModelSerializer):
    payment_details = PaymentSerializer(source='payment', read_only=True)
    
    class Meta:
        model = MobilePayment
        fields = (
            'id', 'payment', 'payment_details', 'provider',
            'phone_number', 'reference', 'status',
            'initiated_at', 'completed_at'
        )
        read_only_fields = (
            'reference', 'status', 'initiated_at',
            'completed_at'
        )
    
    def validate_phone_number(self, value):
        """Valide le format du numéro de téléphone"""
        import re
        pattern = r'^\+?[0-9]{9,15}$'
        if not re.match(pattern, value):
            raise serializers.ValidationError(
                "Format de numéro de téléphone invalide"
            )
        return value

    def create(self, validated_data):
        # Générer une référence unique pour le paiement
        # reference = generate_reference()
        # validated_data['reference'] = reference
        validated_data['reference'] = str(uuid.uuid4())
        return super().create(validated_data)
        

class MobilePaymentConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = MobilePaymentConfig
        fields = (
            'id', 'provider', 'merchant_id', 'api_url',
            'callback_url', 'is_active', 'test_mode',
            'api_key', 'api_secret'
        )
        extra_kwargs = {
            'api_key': {'write_only': True},
            'api_secret': {'write_only': True}
        }


class LicenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = License  # Assurez-vous que License est importé
        fields = '__all__' 


from core.models import Challenge
class ChallengeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Challenge
        fields = '__all__'

from core.models import StudentChallenge
class StudentChallengeSerializer(serializers.ModelSerializer):
    challenge = ChallengeSerializer()

    class Meta:
        model = StudentChallenge
        fields = ('id', 'challenge', 'progress', 'completed')
from core.models import ExamSessionModel
class ExamSessionModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExamSessionModel
        fields = '__all__'

class ParentDashboardSerializer(serializers.ModelSerializer):
    children_progress = serializers.SerializerMethodField()

    class Meta:
        model = Parent
        fields = ('id', 'children_progress')

    def get_children_progress(self, obj):
        return [generate_exam_report(exam, child) for child in obj.children.all() for exam in Exam.objects.filter(course__classes__students=child)]

class LicenseActivationSerializer(serializers.ModelSerializer):
    class Meta:
        model = License
        fields = ('serial_number', 'expiration_date')