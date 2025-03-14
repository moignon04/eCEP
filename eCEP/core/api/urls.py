from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ParentViewSet, AdminViewSet
from rest_framework_simplejwt.views import TokenObtainPairView,TokenRefreshView
from .views import (
    UserViewSet, StudentViewSet, TeacherViewSet, ParentViewSet, AdminViewSet,
    CourseViewSet, ResourceViewSet, ExerciseViewSet, ProgressViewSet,
    ClassViewSet, BadgeViewSet, NotificationViewSet, ExamViewSet,
    MobilePaymentViewSet, MobilePaymentConfigViewSet, MobilePaymentCallbackView,
    RegisterView, callback, LigdiCashPaymentViewSet, ChallengeViewSet,
    StudentChallengeViewSet, VideoViewSet, PdfViewSet, AudioViewSet,
    ChoiceViewSet, QuestionViewSet, ExoViewSet, LessonViewSet, ChapterViewSet
)
from django.conf import settings
from django.conf.urls.static import static
from .views import ChallengeViewSet 

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'students', StudentViewSet, basename='student')
router.register(r'teachers', TeacherViewSet, basename='teacher')
router.register(r'parents', ParentViewSet, basename='parent')
router.register(r'admins', AdminViewSet, basename='admin')
router.register(r'courses', CourseViewSet, basename='course')
router.register(r'resources', ResourceViewSet, basename='resource')
router.register(r'exercises', ExerciseViewSet, basename='exercise')
router.register(r'progress', ProgressViewSet, basename='progress')
router.register(r'classes', ClassViewSet, basename='class')
router.register(r'badges', BadgeViewSet, basename='badge')
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'exams', ExamViewSet, basename='exam')
router.register(r'mobile-payments', MobilePaymentViewSet, basename='mobile-payment')
router.register(r'payment-configs', MobilePaymentConfigViewSet, basename='payment-config')
router.register(r'ligdicash-payments', LigdiCashPaymentViewSet, basename='ligdicash-payment')
router.register(r'challenges', ChallengeViewSet, basename='challenge')
router.register(r'student-challenges', StudentChallengeViewSet, basename='student-challenge')
router.register(r'videos', VideoViewSet, basename='video')
router.register(r'pdfs', PdfViewSet, basename='pdf')
router.register(r'audios', AudioViewSet, basename='audio')
router.register(r'choices', ChoiceViewSet, basename='choice')
router.register(r'questions', QuestionViewSet, basename='question')
router.register(r'exos', ExoViewSet, basename='exo')
router.register(r'lessons', LessonViewSet, basename='lesson')
router.register(r'chapters', ChapterViewSet, basename='chapter')

urlpatterns = [
    path('api/', include(router.urls)),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('callback/', callback, name='payment-callback'),
    path('mobile-payments/callback/<str:provider>/', MobilePaymentCallbackView.as_view(), name='mobile-payment-callback'),
    path('ligdicash/callback/<str:provider>/', MobilePaymentCallbackView.as_view(), name='ligdicash-callback'),
    # Routes personnalisées existantes (ajoutées précédemment)

    # Fonctionnalités spécifiques pour Student
    path('students/<uuid:pk>/add-points/', StudentViewSet.as_view({'post': 'add_points'}), name='student-add-points'),
    path('students/<uuid:pk>/update-streak/', StudentViewSet.as_view({'post': 'update_streak'}), name='student-update-streak'),
    path('students/<uuid:pk>/progress-to-next-level/', StudentViewSet.as_view({'get': 'get_progress_to_next_level'}), name='student-progress-to-next-level'),
    path('students/<uuid:pk>/recent-achievements/', StudentViewSet.as_view({'get': 'get_recent_achievements'}), name='student-recent-achievements'),
    path('students/<uuid:pk>/statistics/', StudentViewSet.as_view({'get': 'get_statistics'}), name='student-statistics'),
    path('students/<uuid:pk>/submit-exercise/<uuid:exercise_id>/', StudentViewSet.as_view({'post': 'submit_exercise'}), name='student-submit-exercise'),

    # Fonctionnalités spécifiques pour Teacher
    path('teachers/<uuid:pk>/create-exam/', TeacherViewSet.as_view({'post': 'create_exam'}), name='teacher-create-exam'),
    path('teachers/<uuid:pk>/evaluate-student/<uuid:student_id>/', TeacherViewSet.as_view({'get': 'evaluate_student'}), name='teacher-evaluate-student'),
    path('teachers/<uuid:pk>/create-content/<uuid:course_id>/', TeacherViewSet.as_view({'post': 'create_content'}), name='teacher-create-content'),

    # Fonctionnalités spécifiques pour Course
    path('courses/<uuid:pk>/update-progress/', CourseViewSet.as_view({'post': 'update_progress'}), name='course-update-progress'),
    path('courses/<uuid:pk>/create-lesson/', CourseViewSet.as_view({'post': 'create_lesson'}), name='course-create-lesson'),

    # Fonctionnalités spécifiques pour Parent
    path('parents/<uuid:pk>/view-progress/<uuid:child_id>/', ParentViewSet.as_view({'get': 'view_progress'}), name='parent-view-progress'),
    path('parents/<uuid:pk>/communicate-teacher/<uuid:teacher_id>/', ParentViewSet.as_view({'post': 'communicate_with_teacher'}), name='parent-communicate-teacher'),

    # Fonctionnalités spécifiques pour Badge
    path('badges/<uuid:pk>/award/<uuid:student_id>/', BadgeViewSet.as_view({'post': 'award'}), name='badge-award'),

    # Fonctionnalités spécifiques pour Exam
    path('exams/<uuid:pk>/start-session/<uuid:student_id>/', ExamViewSet.as_view({'post': 'start_session'}), name='exam-start-session'),
    path('exams/<uuid:pk>/grade/', ExamViewSet.as_view({'post': 'grade_exam'}), name='exam-grade'),

    # Paiements et callbacks
    path('mobile-payments/callback/<str:provider>/', MobilePaymentCallbackView.as_view(), name='mobile-payment-callback'),
    path('ligdicash/callback/<str:provider>/', MobilePaymentCallbackView.as_view(), name='ligdicash-callback'),
    path('callback/', callback, name='payment-callback'),  # Callback générique
]
# Ajouter les fichiers statiques en mode DEBUG
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)