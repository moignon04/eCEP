from django.db.models.signals import post_save
from django.dispatch import receiver
from datetime import timedelta
from django.utils import timezone
import logging
from django.core.exceptions import ValidationError
from core.models import Progress

logger = logging.getLogger(__name__)

# Points bonus pour différentes actions
STREAK_BONUS = {
    7: 100,    # Bonus pour 7 jours consécutifs
    30: 500,   # Bonus pour 30 jours consécutifs
    90: 1500,  # Bonus pour 90 jours consécutifs
}

DIFFICULTY_MULTIPLIER = {
    1: 1.0,  # Facile
    2: 1.2,  # Moyen
    3: 1.5,  # Difficile
    4: 2.0,  # Expert
}

SPEED_BONUS_THRESHOLD = 0.7  # 70% du temps moyen

def calculate_exercise_points(exercise, score, completion_time=None):
    """Calcule les points pour un exercice en fonction de la difficulté et du temps"""
    if not (0 <= score <= 100):
        logger.error("Score invalide: %s", score)
        raise ValueError("Score invalide")
    
    base_points = exercise.points
    difficulty_bonus = DIFFICULTY_MULTIPLIER.get(exercise.difficulty, 1.0)
    
    points = base_points * difficulty_bonus * (score / 100)
    
    # Bonus de vitesse si applicable
    if completion_time and exercise.average_completion_time:
        try:

            if completion_time < exercise.average_completion_time * SPEED_BONUS_THRESHOLD:
                points *= 1.2  # 20% bonus pour rapidité
                logger.info(f"Bonus de vitesse attribué: {points}")
        except Exception as e:
            logger.error(f"Erreur lors du calcul du bonus de vitesse: {str(e)}")
    
    final_point = int(points)
    logger.info(f"Points calculés pour l'exercice {exercise.id}: {final_point}")
    return final_point

def check_streak_bonus(student):
    """Vérifie et attribue les bonus de série"""
    for days, bonus in STREAK_BONUS.items():
        if student.streak_days == days:
            try:
                student.add_points(bonus)
                logger.info(f"Bonus de série ({days} jours) attribué à l'étudiant {student.id}: {bonus} points")
                return True
            except Exception as e:
                logger.error(f"Erreur lors du bonus de série: {str(e)}")
                return False
    return False

@receiver(post_save, sender='core.Progress')
def handle_exercise_completion(sender, instance, created, **kwargs):
    """Gère les événements après la complétion d'un exercice"""
    if not created:
        return
    
    try:
        student = instance.student
        exercise = instance.exercise
        
        # Met à jour le compteur d'exercices
        student.total_exercises_completed += 1
        logger.info(f"Exercice {exercise.id} complété par l'étudiant {student.id}")
    
        # Calcule et ajoute les points
        points = calculate_exercise_points(
            exercise,
            instance.score,
            instance.completion_time
        )
        student.add_points(points)
        logger.info(f"Points ajoutés ({points}) à l'étudiant {student.id}")
        
        # Met à jour la série d'activités
        student.update_streak()
        logger.info(f"Série d'activités mise à jour pour l'étudiant {student.id}")
    
        # Vérifie les bonus de série
        if check_streak_bonus(student):
            logger.info(f"Bonus de série attribué à l'étudiant {student.id}")
    
        student.save()
    except Exception as e:
        logger.error(f"Erreur lors de la gestion de l'exercice {exercise.id}: {str(e)}")

def award_special_achievement(student, achievement_type, points=0):
    """Attribue des réalisations spéciales"""
    """Attribue des réalisations spéciales"""
    from core.models import Badge
    
    SPECIAL_ACHIEVEMENTS = {
        'first_perfect_score': {
            'name': 'Premier 100%',
            'description': 'Premier exercice parfait',
            'points': 100
        },
        'subject_mastery': {
            'name': 'Maître du sujet',
            'description': 'Excellence dans une matière',
            'points': 500
        },
        'speed_demon': {
            'name': 'Éclair',
            'description': 'Completion rapide avec précision',
            'points': 200
        }
    }
    
    if achievement_type not in SPECIAL_ACHIEVEMENTS:
        logger.error(f"Realisation speciale invalide: {achievement_type}")
        return

    achievement = SPECIAL_ACHIEVEMENTS[achievement_type]
    try:
        if not Badge.objects.filter(name=achievement['name']).exists():
            badge = Badge.objects.create(
                name=achievement['name'],
                description=achievement['description'],
                required_points=0  # Badge spécial
            )
            badge.award(student)
            total_points = achievement['points'] + points
            student.add_points(total_points)
            logger.info(f"Badge spécial attribué à l'étudiant {student.id} : {achievement['name']}")
            logger.info(f"Points ajoutés ({total_points}) à l'étudiant {student.id}")
        else:
            logger.info(f"Badge spécial déjà attribué à l'étudiant {student.id} : {achievement['name']}")
    except Exception as e:
        logger.error(f"Erreur lors de la gestion de la realization speciale {achievement_type}: {str(e)}")