from math import log
from django.utils import timezone
from datetime import timedelta
from django.db.models import Avg, Count
from .models import Exercise, Student, Notification, Progress
import logging
from django.core.exceptions import ValidationError

logger = logging.getLogger(__name__)

class ExamSession:
    def __init__(self, exam, student):
        self.exam = exam
        self.student = student
        self.start_time = timezone.now()
        self.answers = {}
        logger.info(f"Exam session started for {student.id} on {exam.id}")
        
    def submit_answer(self, exercise_id, answer):
        """Enregistre la réponse à un exercice"""
        try:
            if not Exercise.objects.get(id=exercise_id, exams=self.exam):
                logger.error(f"Exercice {exercise_id} non trouvé dans l'examen {self.exam.id}")
                raise ValidationError("Exercice non trouvé")
            self.answers[exercise_id] = {
                'answer': answer,
                'time': timezone.now()
            }
            logger.info(f'Réponse soumise pour l\'exercice {exercise_id} par {self.student.id}')
        except Exercise.DoesNotExist:
            logger.error(f"Erreur lors de la soumission de la réponse: {str(e)}")
            raise ValidationError("Exercice non trouvé")
    
    def get_remaining_time(self):
        """Calcule le temps restant pour l'examen"""
        elapsed = timezone.now() - self.start_time
        remaining = max(timedelta(0), self.exam.duration - elapsed)
        logger.debug(f'Temps restant pour l\'examen {self.exam.id} : {remaining}')
        return remaining
    
    def is_time_up(self):
        """Vérifie si le temps est écoulé"""
        time_up = self.get_remaining_time() == timedelta(0)
        if time_up:
            logger.info(f"Tempps écoulé pour la session d'examen {self.exam.id} de l'étudiant {self.student.id}")

        return time_up

def create_practice_exam(subject, difficulty, num_exercises=10, duration_minutes=30):
    """Crée un examen blanc basé sur le sujet et la difficulté"""
    from core.models import Exam
    try:
        exercises = Exercise.objects.filter(
            course__subject=subject,
            difficulty=difficulty
        ).order_by('?')[:num_exercises]

        if not exercises:
            logger.error(f"Aucun exercice trouvé pour {subject} avec une difficulté de {difficulty}")
            return None
        
        exam = Exam.objects.create(
            title=f"Examen blanc - {subject}",
            date=timezone.now(),
            duration=timedelta(minutes=duration_minutes),
            total_points=sum(ex.points for ex in exercises),
            is_practice=True
        )
        exam.exercises.set(exercises)
        logger.info(f"Examen blanc creé : {exam.id}")
        return exam
    except ValidationError as e:
        logger.error(f"Erreur lors de la création de l'examen blanc : {str(e)}")
        return None
    

def analyze_exam_results(exam):
    """Analyse les résultats d'un examen"""
    try:
        results = Progress.objects.filter(exercise__exams=exam)

        completion_rate = 0
        if results.exists() and exam.exercises.exists():
            # Compter uniquement les étudiants concernés par l'examen via les classes associées
            relevant_students = Student.objects.filter(classes__courses__exams=exam).count()
            if relevant_students:
                completion_rate = (results.count() / (exam.exercises.count() * relevant_students)) * 100

        stats = {
            'average_score': results.aggregate(Avg('score'))['score__avg'] or 0,
            'completion_rate': completion_rate,
            'difficulty_distribution': results.values(
                'exercise__difficulty'
            ).annotate(
                count=Count('id'),
                avg_score=Avg('score')
            ),
            'time_distribution': results.filter(completion_time__isnull=False).values(
                'completion_time'
            ).annotate(
                count=Count('id')
            )
        }
        logger.info(f"Analyse des résultats pour l'examen {exam.id}: {stats}")
        return stats
    except Exception as e:
        logger.error(f"Erreur lors de l'analyse des résultats de l'examen {exam.id}: {str(e)}")
        return {}

def schedule_exam(exam, class_group):
    """Planifie un examen pour une classe"""
    # Notifie les étudiants
    try:
        # Notifie les étudiants
        for student in class_group.students.all():
            Notification.objects.create(
                recipient=student.user,
                type='exam',
                message=f"Nouvel examen prévu : {exam.title} le {exam.date}",
            )
            logger.info(f"Notification d'examen créée pour l'étudiant {student.id} pour l'examen {exam.id}")

            # Crée des rappels
            reminder_dates = [
                exam.date - timedelta(days=7),
                exam.date - timedelta(days=1),
                exam.date - timedelta(hours=1)
            ]

            for date in reminder_dates:
                if date > timezone.now():
                    Notification.objects.create(
                        recipient=student.user,
                        type='reminder',
                        message=f"Rappel : Examen {exam.title} prévu le {exam.date}",
                        scheduled_for=date
                    )
                    logger.info(f"Rappel programmé pour l'étudiant {student.id} à {date}")
    except Exception as e:
        logger.error(f"Erreur lors de la planification de l'examen {exam.id}: {str(e)}")

def generate_exam_report(exam, student):
    """Génère un rapport détaillé pour un étudiant"""
    try:
        progress_items = Progress.objects.filter(
            student=student,
            exercise__exams=exam
        )

        total_points = sum(p.score * p.exercise.points / 100 for p in progress_items)
        max_points = exam.total_points or 1  # Évite la division par zéro

        time_spent = timedelta()
        for p in progress_items:
            if p.completion_time:
                time_spent += p.completion_time

        report = {
            'student': {
                'name': student.user.get_full_name() or student.user.username,
                'grade': student.grade
            },
            'exam': {
                'title': exam.title,
                'date': exam.date,
                'duration': exam.duration
            },
            'results': {
                'total_score': (total_points / max_points) * 100,
                'exercises_completed': progress_items.count(),
                'total_exercises': exam.exercises.count(),
                'time_spent': time_spent,
                'exercise_details': [
                    {
                        'title': p.exercise.title,
                        'score': p.score,
                        'time_spent': p.completion_time,
                        'difficulty': p.exercise.difficulty
                    }
                    for p in progress_items
                ]
            },
            'recommendations': generate_recommendations(student, progress_items)
        }
        logger.info(f"Rapport généré pour l'étudiant {student.id} sur l'examen {exam.id}")
        return report
    except Exception as e:
        logger.error(f"Erreur lors de la génération du rapport pour l'étudiant {student.id}: {str(e)}")
        return {}

def generate_recommendations(student, progress_items):
    """Génère des recommandations basées sur les performances"""
    try:
        weak_areas = []
        low_score_items = [item for item in progress_items if item.score < 60]

        for item in low_score_items:
            recommended_exercises = Exercise.objects.filter(
                course__subject=item.exercise.course.subject,
                difficulty__lte=item.exercise.difficulty
            ).exclude(
                progress__student=student
            )[:3]
            weak_areas.append({
                'subject': item.exercise.course.subject,
                'topic': item.exercise.title,
                'recommended_exercises': recommended_exercises
            })

        recommended_difficulty = 1
        low_performance_items = [item for item in progress_items if item.score < 70]
        if low_performance_items:
            recommended_difficulty = max(min(item.exercise.difficulty for item in low_performance_items), 1)

        recommendations = {
            'weak_areas': weak_areas,
            'suggested_practice': bool(weak_areas),
            'recommended_difficulty': recommended_difficulty
        }
        logger.info(f"Recommandations générées pour l'étudiant {student.id}: {recommendations}")
        return recommendations
    except Exception as e:
        logger.error(f"Erreur lors de la génération des recommandations pour l'étudiant {student.id}: {str(e)}")
        return {'weak_areas': [], 'suggested_practice': False, 'recommended_difficulty': 1}
