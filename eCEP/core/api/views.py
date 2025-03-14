from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from core.exam_management import ExamSession
from core.models import Payment
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import License, SubscriptionSerializer, ParentSerializer, UserSerializer, ExamSessionSerializer, ExamStatisticsSerializer, AdminSerializer
from core.models import Parent, MobilePaymentConfig
from core.models import (
    User, Student, Teacher, Parent, Admin, Course, Resource, Exercise, Progress,
    Class, Badge, Notification, Exam, Payment, Subscription, MobilePayment,
    MobilePaymentConfig, Challenge, StudentChallenge, ExamSessionModel,
    Video, Pdf, Audio, Choice, Question, Exo, Lesson, Chapter
)

from .serializers import (
    UserSerializer, StudentSerializer, TeacherSerializer, ParentSerializer, AdminSerializer,
    CourseSerializer, ResourceSerializer, ExerciseSerializer, ProgressSerializer,
    ClassSerializer, BadgeSerializer, NotificationSerializer, ExamSerializer,
    UserRegistrationSerializer, LicenseSerializer, PaymentSerializer, SubscriptionSerializer,
    MobilePaymentSerializer, MobilePaymentConfigSerializer, ChallengeSerializer,
    StudentChallengeSerializer, ExamSessionModelSerializer, VideoSerializer, PdfSerializer,
    AudioSerializer, ChoiceSerializer, QuestionSerializer, ExoSerializer, LessonSerializer,
    ChapterSerializer
)
import os
import logging
from rest_framework import generics, permissions
from keysGen.models import License
from rest_framework.permissions import AllowAny
from rest_framework.serializers import ModelSerializer
from .serializers import StudentDashboardSerializer
import requests
from django.http import FileResponse

logger = logging.getLogger(__name__)

class LigdiCashPaymentViewSet(viewsets.ModelViewSet):
    queryset = MobilePayment.objects.filter(provider='ligdicash')
    serializer_class = MobilePaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Vérifier si l'utilisateur a un numéro de téléphone
        if not hasattr(request.user, 'phone_number') or not request.user.phone_number:
            logger.warning(f"Utilisateur {request.user} doit avoir un numéro de téléphone pour effectuer un paiement")
            return Response(
                {'error': 'Numéro de téléphone requis pour le paiement'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Initier un paiement via LigdiCash
        payment_data = {
            'amount': serializer.validated_data['amount'],
            'reference': serializer.validated_data['reference'],
            'phone_number': request.user.phone_number,  # Assurez-vous que l'utilisateur a un numéro de téléphone
        }
        
        # Appel à l'API LigdiCash (remplacez par l'URL réelle)
        try:
            api_url = os.getenv('LIGDICASH_API_URL', 'https://api.ligdicash.com/v1/payments')
            api_key = os.getenv('LIGDICASH_API_KEY')
            response = requests.post(
                api_url,  # URL fictive, utilisez la vraie
                json={
                    'amount': payment_data['amount'],
                    'reference': payment_data['reference'],
                    'phone_number': payment_data['phone_number'],
                    'return_url': os.getenv('RETURN_URL', 'https://masuperboutique.com/success'),
                    'callback_url': os.getenv('CALLBACK_URL', 'http://localhost:8000/callback'),
                },
                headers={
                    'Authorization': f'Bearer {api_key}'
                }
            )

            if response.status_code == 200:
                mobile_payment = serializer.save(provider='ligdicash', status='initiated')
                logger.info(f"Paiement initié avec succès: {mobile_payment.id}")
                return Response(
                    MobilePaymentSerializer(mobile_payment).data,
                    status=status.HTTP_201_CREATED
                )
            else:
                logger.error(f"Échec de l'initiation du paiement: {response.text}")
                return Response(
                    {'error': 'Échec de l\'initiation du paiement', 'details': response.text},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
        except requests.RequestException as e:
            logger.error(f"Erreur de connexion à LigdiCash: {str(e)}")
            return Response(
                {'error': 'Erreur de connexion à LigdiCash', 'details': str(e)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )

    @action(detail=True, methods=['get'])
    def check_status(self, request, pk=None):
        mobile_payment = self.get_object()

        # Vérifier le statut du paiement auprès de LigdiCash
        try:
            response = requests.get(
                f'https://api.ligdicash.com/v1/payments/{mobile_payment.reference}',  # URL fictive
                headers={
                    'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZF9hcHAiOjI3NSwiaWRfYWJvbm5lIjo3MjI5LCJkYXRlY3JlYXRpb25fYXBwIjoiMjAyNC0wNC0wOCAwODozMjoyNSJ9.DBrJVmNYz2LYx9Dm9kEECIobsRjAONt8N1NFqZ0uqEU'
                }
            )

            if response.status_code == 200:
                status_data = response.json()
                mobile_payment.status = status_data.get('status', 'unknown')
                mobile_payment.save()
                return Response({'status': mobile_payment.status})
            else:
                return Response(
                    {'error': 'Impossible de vérifier le statut', 'details': response.text},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except requests.RequestException as e:
            return Response(
                {'error': 'Erreur de connexion', 'details': str(e)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )


    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        mobile_payment = self.get_object()

        if mobile_payment.status not in ['initiated', 'pending']:
            return Response(
                {'error': 'Ce paiement ne peut plus être annulé'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            response = requests.post(
                f'https://api.ligdicash.com/v1/payments/{mobile_payment.reference}/cancel',  # URL fictive
                headers={
                    'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZF9hcHAiOjI3NSwiaWRfYWJvbm5lIjo3MjI5LCJkYXRlY3JlYXRpb25fYXBwIjoiMjAyNC0wNC0wOCAwODozMjoyNSJ9.DBrJVmNYz2LYx9Dm9kEECIobsRjAONt8N1NFqZ0uqEU'
                }
            )

            if response.status_code == 200:
                mobile_payment.status = 'cancelled'
                mobile_payment.save()
                return Response({'message': 'Paiement annulé'})
            else:
                return Response(
                    {'error': 'Échec de l\'annulation', 'details': response.text},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except requests.RequestException as e:
            return Response(
                {'error': 'Erreur de connexion', 'details': str(e)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )

import json        
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from core.models import Payment, LicensePayment
from keysGen.models import License
import datetime
import json

@csrf_exempt
def callback(request):
    try:
        payload = request.body
        event = json.loads(payload)
        token = event['token']
        transaction_id = event['transaction_id']
        status = event['status']

        payment = Payment.objects.get(token=token)

        if payment.status == "pending" and status == "completed":
            payment.status = "completed"
            payment.save()

            # Gérer l'activation ou le renouvellement de la licence
            license_payment = LicensePayment.objects.get(payment=payment)
            if license_payment.payment_type == 'new':
                expiration_date = datetime.date.today() + datetime.timedelta(days=license_payment.duration_months * 30)
                license = License.objects.create(user=payment.user, expiration_date=expiration_date)
                license_payment.license = license
                license_payment.save()
            elif license_payment.payment_type == 'renew':
                license = license_payment.license
                license.renew(duration_months=license_payment.duration_months)
                license_payment.save()

        return JsonResponse({"status": "success"})
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)
        
class RegisterSerializer(ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

# Vue pour l'inscription
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]
from .serializers import UserLoginSerializer

class UserLoginView(APIView):
    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            })
        return Response(serializer.errors, status=400)
    
class UserRegistrationView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Utilisateur créé avec succès"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MobilePaymentViewSet(viewsets.ModelViewSet):
    queryset = MobilePayment.objects.all()
    serializer_class = MobilePaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'admin'):
            return MobilePayment.objects.all()
        return MobilePayment.objects.filter(payment__user=user)
    
    def create(self, request, *args, **kwargs):
        payment_type = request.data.get('payment_type')
        license_id = request.data.get('license_id')
        duration_months = request.data.get('duration_months')

        if not payment_type or not duration_months:
            return Response(
                {'error': 'payment_type and duration_months are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if payment_type == 'renew' and not license_id:
            return Response(
                {'error': 'license_id is required for renewal'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Créer le paiement
        payment_data = {
            'user': request.user,
            'amount': request.data['amount'],
            # autres champs de paiement si nécessaires
        }
        payment_serializer = PaymentSerialiser(data=payment_data)
        if not payment_serializer.is_valid():
            return Response(payment_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        payment = payment_serializer.save()

        # Créer le paiement mobile
        mobile_payment_data = {
            'payment': payment,
            'provider': 'ligdicash',
            'phone_number': request.user.phone_number,
            'reference': request.data['reference'],
        }
        mobile_payment_serializer = MobilePaymentSerialiser(data=mobile_payment_data)
        if not mobile_payment_serializer.is_valid():
            return Response(mobile_payment_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        mobile_payment = mobile_payment_serializer.save()

        # Créer l'enregistrement LicensePayment
        license_payment_data = {
            'payment': payment,
            'payment_type': payment_type,
            'duration_months': duration_months,
        }

        if payment_type == 'renew':
            license = get_object_or_404(License, id=license_id, user=request.user)
            license_payment_data['license'] = license
        license_payment_serializer = LicensePaymentSerialiser(data=license_payment_data)
        
        if not license_payment_serializer.is_valid():
            return Response(license_payment_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        license_payment = license_payment_serializer.save()

        # Initier le paiement
        success = mobile_payment.initiate_payment()
        if not success:
            # Nettoyage en cas d'échec
            mobile_payment.delete()
            payment.delete()
            license_payment.delete()
            return Response(
                {'error': 'Échec de l\'initiation du paiement'},
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response(
            MobilePaymentSerialiser(mobile_payment).data,
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=True, methods=['get'])
    def check_status(self, request, pk=None):
        """Vérifie le statut d'un paiement"""
        mobile_payment = self.get_object()
        current_status = mobile_payment.check_status()
        
        return Response({
            'status': current_status,
            'payment': MobilePaymentSerializer(mobile_payment).data
        })
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Annule un paiement en attente"""
        mobile_payment = self.get_object()
        
        if mobile_payment.status not in ['initiated', 'pending']:
            return Response(
                {'error': 'Ce paiement ne peut plus être annulé'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        mobile_payment.status = 'cancelled'
        mobile_payment.save()
        
        mobile_payment.payment.status = 'failed'
        mobile_payment.payment.save()
        
        return Response({
            'message': 'Paiement annulé',
            'payment': MobilePaymentSerializer(mobile_payment).data
        })


class MobilePaymentConfigViewSet(viewsets.ModelViewSet):
    queryset = MobilePaymentConfig.objects.all()
    serializer_class = MobilePaymentConfigSerializer
    permission_classes = [permissions.IsAuthenticated]

class ProgressViewSet(viewsets.ModelViewSet):
    queryset = Progress.objects.all()
    serializer_class = ProgressSerializer
    permission_classes = [permissions.IsAuthenticated]

class AdminViewSet(viewsets.ModelViewSet):
    queryset = Admin.objects.all()
    serializer_class = AdminSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'])
    def manage_user(self, request):
        """Active/désactive un utilisateur"""
        user_id = request.data.get('user_id')
        active = request.data.get('active', True)
        user = User.objects.get(id=user_id)
        user.is_active = active
        user.save()
        return Response({'message': f'Utilisateur {"activé" if active else "désactivé"}'})

    @action(detail=False, methods=['post'])
    def moderate_content(self, request):
        """Valide un contenu"""
        resource_id = request.data.get('resource_id')
        approved = request.data.get('approved', True)
        resource = Resource.objects.get(id=resource_id)
        resource.offline_available = approved  # Exemple de validation
        resource.save()
        return Response({'message': f'Contenu {"approuvé" if approved else "rejeté"}'})

from .serializers import ParentDashboardSerializer
class ParentViewSet(viewsets.ModelViewSet):
    queryset = Parent.objects.all()
    serializer_class = ParentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @action(detail=True, methods=['get'])
    def dashboard(self, request, pk=None):
        """Tableau de bord pour les parents"""
        parent = self.get_object()
        serializer = ParentDashboardSerializer(parent)
        return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from core.models import Challenge, StudentChallenge
from .serializers import ChallengeSerializer, StudentChallengeSerializer
class ChallengeViewSet(viewsets.ModelViewSet):
    queryset = Challenge.objects.all()
    serializer_class = ChallengeSerializer
    permission_classes = [permissions.IsAuthenticated]

class StudentChallengeViewSet(viewsets.ModelViewSet):
    queryset = StudentChallenge.objects.all()
    serializer_class = StudentChallengeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Filtrer les défis par étudiant connecté si non-admin"""
        user = self.request.user
        if hasattr(user, 'student'):
            return StudentChallenge.objects.filter(student=user.student)
        elif hasattr(user, 'teacher') or hasattr(user, 'admin'):
            return StudentChallenge.objects.all()
        return StudentChallenge.objects.none()

    @action(detail=True, methods=['post'])
    def update_progress(self, request, pk=None):
        """Met à jour la progression d’un défi étudiant"""
        student_challenge = self.get_object()
        progress_increment = request.data.get('progress', 1)
        student_challenge.progress += progress_increment
        if student_challenge.progress >= student_challenge.challenge.target_value:
            student_challenge.completed = True
            student_challenge.student.add_points(student_challenge.challenge.reward_points)
            if student_challenge.challenge.reward_badge:
                student_challenge.student.badges.add(student_challenge.challenge.reward_badge)
        student_challenge.save()
        return Response(StudentChallengeSerializer(student_challenge).data)

    @action(detail=True, methods=['get'])
    def status(self, request, pk=None):
        """Récupère le statut du défi"""
        student_challenge = self.get_object()
        serializer = StudentChallengeSerializer(student_challenge)
        return Response(serializer.data)
        
class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def challenges(self, request, pk=None):
        """Récupère les défis de l’étudiant"""
        student = self.get_object()
        challenges = StudentChallenge.objects.filter(student=student)
        serializer = StudentChallengeSerializer(challenges, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def update_challenge(self, request, pk=None):
        """Met à jour la progression d’un défi"""
        student = self.get_object()
        challenge_id = request.data.get('challenge_id')
        progress_increment = request.data.get('progress', 1)
        sc, created = StudentChallenge.objects.get_or_create(student=student, challenge_id=challenge_id)
        sc.progress += progress_increment
        if sc.progress >= sc.challenge.target_value:
            sc.completed = True
            student.add_points(sc.challenge.reward_points)
            if sc.challenge.reward_badge:
                sc.challenge.reward_badge.award(student)
        sc.save()
        return Response(StudentChallengeSerializer(sc).data)

    @action(detail=True, methods=['get'])
    def dashboard(self, request, pk=None):
        """Récupère le tableau de bord récapitulatif de l'étudiant"""
        student = self.get_object()
        serializer = StudentDashboardSerializer(student)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def progress(self, request, pk=None):
        student = self.get_object()
        progress = Progress.objects.filter(student=student)
        serializer = ProgressSerializer(progress, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def badges(self, request, pk=None):
        student = self.get_object()
        badges = student.badges.all()
        serializer = BadgeSerializer(badges, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def achievements(self, request, pk=None):
        """Récupère toutes les réalisations de l'étudiant"""
        student = self.get_object()
        data = student.get_achievement_summary()
        return Response(data)

    @action(detail=True, methods=['get'])
    def learning_path(self, request, pk=None):
        """Récupère le parcours d'apprentissage personnalisé"""
        student = self.get_object()
        data = student.get_learning_path_status()
        return Response({
            'current_status': data,
            'recommended_exercises': ExerciseSerializer(
                data['recommended_exercises'],
                many=True
            ).data
        })

    @action(detail=True, methods=['get'])
    def subject_progress(self, request, pk=None):
        """Récupère la progression par matière"""
        student = self.get_object()
        subject = request.query_params.get('subject')
        if not subject:
            return Response(
                {'error': 'Le paramètre subject est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        data = student.get_subject_progress(subject)
        return Response(data)


class TeacherViewSet(viewsets.ModelViewSet):
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def dashboard(self, request, pk=None):
        """Récupère le tableau de bord statistique pour l’enseignant"""
        teacher = self.get_object()
        serializer = TeacherDashboardSerializer(teacher)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def courses(self, request, pk=None):
        teacher = self.get_object()
        courses = Course.objects.filter(teacher=teacher)
        serializer = CourseSerializer(courses, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def classes(self, request, pk=None):
        teacher = self.get_object()
        classes = Class.objects.filter(teacher=teacher)
        serializer = ClassSerializer(classes, many=True)
        return Response(serializer.data)

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def resources(self, request, pk=None):
        course = self.get_object()
        resources = Resource.objects.filter(course=course)
        serializer = ResourceSerializer(resources, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def videos(self, request, pk=None):
        course = self.get_object()
        videos = course.video_file.all()
        serializer = VideoSerializer(videos, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def pdfs(self, request, pk=None):
        course = self.get_object()
        pdfs = course.pdf_file.all()
        serializer = PdfSerializer(pdfs, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def audios(self, request, pk=None):
        course = self.get_object()
        audios = course.audio_file.all()
        serializer = AudioSerializer(audios, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def chapters(self, request, pk=None):
        course = self.get_object()
        chapters = course.chapters.all()
        serializer = ChapterSerializer(chapters, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def exercises(self, request, pk=None):
        course = self.get_object()
        exercises = Exercise.objects.filter(course=course)
        serializer = ExerciseSerializer(exercises, many=True)
        return Response(serializer.data)


class VideoViewSet(viewsets.ModelViewSet):
    queryset = Video.objects.all()
    serializer_class = VideoSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        video = self.get_object()
        response = FileResponse(video.file, content_type='video/mp4')
        response['Content-Disposition'] = f'attachment; filename="{video.file.name}"'
        return response

class PdfViewSet(viewsets.ModelViewSet):
    queryset = Pdf.objects.all()
    serializer_class = PdfSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        pdf = self.get_object()
        response = FileResponse(pdf.file, content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="{pdf.file.name}"'
        return response

class AudioViewSet(viewsets.ModelViewSet):
    queryset = Audio.objects.all()
    serializer_class = AudioSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        audio = self.get_object()
        response = FileResponse(audio.file, content_type='audio/mpeg')
        response['Content-Disposition'] = f'attachment; filename="{audio.file.name}"'
        return response

# Nouvelle classe pour Choice
class ChoiceViewSet(viewsets.ModelViewSet):
    queryset = Choice.objects.all()
    serializer_class = ChoiceSerializer
    permission_classes = [permissions.IsAuthenticated]

# Nouvelle classe pour Question
class QuestionViewSet(viewsets.ModelViewSet):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def choices(self, request, pk=None):
        question = self.get_object()
        choices = question.choices.all()
        serializer = ChoiceSerializer(choices, many=True)
        return Response(serializer.data)

# Nouvelle classe pour Exo
class ExoViewSet(viewsets.ModelViewSet):
    queryset = Exo.objects.all()
    serializer_class = ExoSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        exo = self.get_object()
        response = FileResponse(exo.file, content_type='application/octet-stream')
        response['Content-Disposition'] = f'attachment; filename="{exo.file.name}"'
        return response

# Nouvelle classe pour Lesson
class LessonViewSet(viewsets.ModelViewSet):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def assign_course(self, request, pk=None):
        lesson = self.get_object()
        course_id = request.data.get('course_id')
        course = get_object_or_404(Course, id=course_id)
        lesson.assign_course(course)
        return Response({'message': 'Cours assigné avec succès'})

    @action(detail=True, methods=['post'])
    def remove_course(self, request, pk=None):
        lesson = self.get_object()
        course_id = request.data.get('course_id')
        course = get_object_or_404(Course, id=course_id)
        lesson.remove_course(course)
        return Response({'message': 'Cours retiré avec succès'})

# Nouvelle classe pour Chapter
class ChapterViewSet(viewsets.ModelViewSet):
    queryset = Chapter.objects.all()
    serializer_class = ChapterSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def lessons(self, request, pk=None):
        chapter = self.get_object()
        lessons = chapter.lessons.all()
        serializer = LessonSerializer(lessons, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def exercises(self, request, pk=None):
        chapter = self.get_object()
        exercises = chapter.exercise.all()
        serializer = ExerciseSerializer(exercises, many=True)
        return Response(serializer.data)


class ResourceViewSet(viewsets.ModelViewSet):
    queryset = Resource.objects.all()
    serializer_class = ResourceSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def offline_bundle(self, request):
        """Prépare un bundle pour le mode hors ligne"""
        resources = Resource.objects.filter(offline_available=True)
        bundle = [{'id': r.id, 'file': r.file.url, 'title': r.title} for r in resources]
        return Response({'bundle': bundle})

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        resource = self.get_object()
        if not resource.file:
            return Response(
                {'error': 'Aucun fichier disponible'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        resource.increment_download()
        response = FileResponse(resource.file)
        response['Content-Disposition'] = f'attachment; filename="{resource.file.name}"'
        return response

    @action(detail=False, methods=['get'])
    def offline_available(self, request):
        """Liste toutes les ressources disponibles hors ligne"""
        resources = Resource.objects.filter(offline_available=True)
        serializer = self.get_serializer(resources, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def metadata(self, request, pk=None):
        """Récupère les métadonnées pour le stockage hors ligne"""
        resource = self.get_object()
        data = {
            'id': resource.id,
            'title': resource.title,
            'type': resource.type,
            'file_size': resource.file_size,
            'last_modified': resource.modified_at,
            'checksum': resource.get_checksum(),
        }
        return Response(data)

    @action(detail=True, methods=['post'])
    def mark_offline(self, request, pk=None):
        resource = self.get_object()
        resource.offline_available = True
        resource.save()
        return Response({'message': 'Ressource marquée comme disponible hors ligne'})

    @action(detail=True, methods=['get'])
    def stream(self, request, pk=None):
        """Diffuse un fichier multimédia"""
        resource = self.get_object()
        if not resource.file:
            return Response({'error': 'Aucun fichier multimédia disponible'}, status=404)
        return FileResponse(resource.file, content_type=f'{resource.type}/mp4')


class ExerciseViewSet(viewsets.ModelViewSet):
    queryset = Exercise.objects.all()
    serializer_class = ExerciseSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def validate_answer(self, request, pk=None):
        """Valide une réponse interactive en temps réel"""
        exercise = self.get_object()
        answer = request.data.get('answer')
        if not answer:
            return Response({'error': 'Réponse manquante'}, status=400)

        if exercise.type == 'qcm':
            correct_answer = exercise.content.get('correct_option')
            is_correct = answer == correct_answer
        elif exercise.type == 'text':
            correct_answer = exercise.content.get('expected_text')
            is_correct = answer.strip().lower() == correct_answer.strip().lower()
        else:
            return Response({'error': 'Type d’exercice non supporté'}, status=400)

        return Response({'is_correct': is_correct, 'points': exercise.points if is_correct else 0})

    @action(detail=True, methods=['post'])
    def submit_answer(self, request, pk=None):
        exercise = self.get_object()
        student = request.user.student
        answers = request.data.get('answers', {})
        
        progress = exercise.submit_answer(student, answers)
        return Response({
            'score': progress.score,
            'message': 'Réponse soumise avec succès'
        })

class ClassViewSet(viewsets.ModelViewSet):
    queryset = Class.objects.all()
    serializer_class = ClassSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def add_student(self, request, pk=None):
        class_obj = self.get_object()
        student_id = request.data.get('student_id')
        student = get_object_or_404(Student, id=student_id)
        class_obj.add_student(student)
        return Response({'message': 'Étudiant ajouté avec succès'})

class ExamViewSet(viewsets.ModelViewSet):
    queryset = Exam.objects.all()
    serializer_class = ExamSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def start_persistent(self, request, pk=None):
        """Démarre une session persistante"""
        exam = self.get_object()
        student = request.user.student
        session, created = ExamSessionModel.objects.get_or_create(exam=exam, student=student, completed=False)
        return Response(ExamSessionModelSerializer(session).data)

    @action(detail=True, methods=['post'])
    def grade_manual(self, request, pk=None):
        """Permet à un enseignant de corriger manuellement"""
        exam = self.get_object()
        session_id = request.data.get('session_id')
        scores = request.data.get('scores', {})  # {exercise_id: score}
        session = ExamSessionModel.objects.get(id=session_id, exam=exam)
        for ex_id, score in scores.items():
            Progress.objects.create(
                student=session.student,
                exercise_id=ex_id,
                score=score,
                completion_time=timezone.now() - session.start_time
            )
        session.completed = True
        session.save()
        return Response({'message': 'Correction terminée'})

    def get_queryset(self):
        """Filtre les examens selon le rôle de l'utilisateur"""
        user = self.request.user
        if hasattr(user, 'teacher'):
            return Exam.objects.filter(course__teacher=user.teacher)
        elif hasattr(user, 'student'):
            return Exam.objects.filter(course__classes__students=user.student)
        return Exam.objects.none()

    @action(detail=True, methods=['post'])
    def start(self, request, pk=None):
        """Démarre une session d'examen"""
        exam = self.get_object()
        student = request.user.student
        
        # Vérifie si l'étudiant peut passer l'examen
        if not exam.course.classes.filter(students=student).exists():
            return Response(
                {'error': 'Vous n\'êtes pas autorisé à passer cet examen'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifie le nombre de tentatives
        attempts = Progress.objects.filter(
            student=student,
            exercise__exams=exam
        ).count()
        
        if attempts >= exam.allowed_attempts:
            return Response(
                {'error': 'Nombre maximum de tentatives atteint'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        session = exam.start_session(student)
        return Response({
            'session_id': session.id,
            'remaining_time': str(exam.duration),
            'total_exercises': exam.exercises.count()
        })

    @action(detail=True, methods=['post'])
    def submit_answer(self, request, pk=None):
        """Soumet une réponse pendant l'examen"""
        exam = self.get_object()
        exercise_id = request.data.get('exercise_id')
        answer = request.data.get('answer')
        session_id = request.data.get('session_id')
        
        if not all([exercise_id, answer, session_id]):
            return Response(
                {'error': 'Données manquantes'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            exercise = Exercise.objects.get(id=exercise_id, exams=exam)
            session = ExamSession.objects.get(id=session_id)
            
            if session.is_time_up():
                return Response(
                    {'error': 'Le temps est écoulé'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            session.submit_answer(exercise_id, answer)
            return Response({'message': 'Réponse enregistrée'})
            
        except Exercise.DoesNotExist:
            return Response(
                {'error': 'Exercice non trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=True, methods=['post'])
    def finish(self, request, pk=None):
        """Termine l'examen et calcule le score"""
        exam = self.get_object()
        session_id = request.data.get('session_id')
        
        if not hasattr(request.user, 'student'):
            return Response(
                {'error': 'Seuls les étudiants peuvent terminer un examen'},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            session = ExamSession.objects.get(id=session_id)
            results = exam.grade_exam(session.answers)
            
            # Enregistre les résultats
            for detail in results['details']:
                Progress.objects.create(
                    student=request.user.student,
                    exercise=detail['exercise'],
                    score=detail['score'],
                    completion_time=session.get_completion_time()
                )
            
            # Génère le rapport
            report = exam.generate_student_report(request.user.student)
            
            return Response({
                'score': results['score'],
                'passed': results['passed'],
                'report': report
            })
            
        except ExamSession.DoesNotExist:
            return Response(
                {'error': 'Session non trouvée'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=True, methods=['get'])
    def statistics(self, request, pk=None):
        """Récupère les statistiques de l'examen"""
        exam = self.get_object()
        if not hasattr(request.user, 'teacher'):
            return Response(
                {'error': 'Accès non autorisé'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        stats = exam.get_statistics()
        return Response(stats)

    @action(detail=True, methods=['post'])
    def schedule(self, request, pk=None):
        """Planifie l'examen pour une classe"""
        exam = self.get_object()
        class_id = request.data.get('class_id')
        
        if not class_id:
            return Response(
                {'error': 'ID de classe requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            class_group = Class.objects.get(id=class_id)
            exam.schedule_for_class(class_group)
            return Response({'message': 'Examen planifié avec succès'})
            
        except Class.DoesNotExist:
            return Response(
                {'error': 'Classe non trouvée'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def create_practice(self, request):
        """Crée un examen blanc"""
        subject = request.data.get('subject')
        difficulty = request.data.get('difficulty', 1)
        num_exercises = request.data.get('num_exercises', 10)
        
        if not subject:
            return Response(
                {'error': 'Sujet requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        from .exam_management import create_practice_exam
        exam = create_practice_exam(subject, difficulty, num_exercises)
        
        if not exam:
            return Response(
                {'error': 'Impossible de créer l\'examen blanc'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = self.get_serializer(exam)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def submit(self, request, pk=None):
        exam = self.get_object()
        student_answers = request.data.get('answers', {})
        score = exam.grade(student_answers)
        return Response({
            'score': score,
            'message': 'Examen soumis avec succès'
        })
from .utils import send_push_notification
class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['post'])
    def send_push(self, request, pk=None):
        """Envoie une notification push"""
        notification = self.get_object()
        send_push_notification(notification.recipient, "Nouvelle notification", notification.message)
        return Response({'message': 'Notification push envoyée'})

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)

    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        notification.mark_as_read()
        return Response({'message': 'Notification marquée comme lue'})

class BadgeViewSet(viewsets.ModelViewSet):
    queryset = Badge.objects.all()
    serializer_class = BadgeSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def available(self, request):
        """Liste les badges disponibles pour l'étudiant"""
        student = request.user.student
        badges = Badge.objects.exclude(students=student)
        serializer = self.get_serializer(badges, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def earned(self, request):
        """Liste les badges gagnés par l'étudiant"""
        student = request.user.student
        badges = student.badges.all()
        serializer = self.get_serializer(badges, many=True)
        return Response(serializer.data)
from .serializers import LicenseActivationSerializer
class LicenseViewSet(viewsets.ModelViewSet):
    queryset = License.objects.all()
    serializer_class = LicenseSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @action(detail=False, methods=['post'])
    def activate(self, request):
        """Valide un code d’activation"""
        serial_number = request.data.get('serial_number')
        license = License.objects.filter(serial_number=serial_number, user=request.user).first()
        if not license or license.expiration_date < timezone.now():
            return Response({'error': 'Code invalide ou expiré'}, status=400)
        return Response(LicenseActivationSerializer(license).data)

    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'admin'):
            return License.objects.all()
        return License.objects.filter(user=user)
    
    @action(detail=True, methods=['post'])
    def renew(self, request, pk=None):
        """Renouvelle une licence"""
        license = self.get_object()
        duration = request.data.get('duration', 1)
        
        try:
            license.renew(duration_months=duration)
            return Response({
                'message': 'Licence renouvelée avec succès',
                'license': LicenseSerializer(license).data
            })
        except ValidationError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'admin'):
            return Payment.objects.all()
        return Payment.objects.filter(user=user)
    
    @action(detail=True, methods=['post'])
    def process(self, request, pk=None):
        """Traite un paiement"""
        payment = self.get_object()
        
        if payment.status != 'pending':
            return Response(
                {'error': 'Ce paiement ne peut plus être traité'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        success = payment.process_payment()
        if success:
            return Response({
                'message': 'Paiement traité avec succès',
                'payment': PaymentSerializer(payment).data
            })
        return Response(
            {'error': 'Le paiement a échoué'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=True, methods=['get'])
    def receipt(self, request, pk=None):
        """Génère un reçu de paiement"""
        payment = self.get_object()
        
        if payment.status != 'completed':
            return Response(
                {'error': 'Aucun reçu disponible'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        receipt = payment.generate_receipt()
        return Response(receipt)

class SubscriptionViewSet(viewsets.ModelViewSet):
    queryset = Subscription.objects.all()
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'admin'):
            return Subscription.objects.all()
        return Subscription.objects.filter(user=user)
    
    @action(detail=True, methods=['post'])
    def toggle_auto_renew(self, request, pk=None):
        """Active/désactive le renouvellement automatique"""
        subscription = self.get_object()
        subscription.auto_renew = not subscription.auto_renew
        subscription.save()
        
        return Response({
            'message': 'Préférence de renouvellement mise à jour',
            'subscription': SubscriptionSerializer(subscription).data
        })
    
    @action(detail=True, methods=['post'])
    def change_interval(self, request, pk=None):
        """Change l'intervalle de facturation"""
        subscription = self.get_object()
        new_interval = request.data.get('interval')
        
        if new_interval not in dict(Subscription.INTERVAL_CHOICES):
            return Response(
                {'error': 'Intervalle invalide'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        subscription.interval = new_interval
        subscription.update_next_billing_date()
        
        return Response({
            'message': 'Intervalle de facturation mis à jour',
            'subscription': SubscriptionSerializer(subscription).data
        })


class MobilePaymentCallbackView(APIView):
    """Gère les callbacks des fournisseurs de paiement mobile"""
    queryset = MobilePayment.objects.all()
    serializer_class = MobilePaymentSerializer
    permission_classes = []  # Pas d'authentification requise
    
    def post(self, request, provider):
        reference = request.data.get('reference')
        if not reference:
            return Response(
                {'error': 'Référence manquante'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            mobile_payment = MobilePayment.objects.get(
                provider=provider,
                reference=reference
            )
            
            # Traite le callback
            new_status = mobile_payment.process_callback(request.data)
            
            return Response({
                'status': new_status,
                'message': 'Callback traité avec succès'
            })
            
        except MobilePayment.DoesNotExist:
            return Response(
                {'error': 'Paiement non trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )
