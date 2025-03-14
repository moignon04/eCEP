from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Student, Progress, Badge, Exercise

# Définition des niveaux et points requis
LEVEL_THRESHOLDS = {
    1: 0,
    2: 100,
    3: 250,
    4: 500,
    5: 1000,
    6: 2000,
    7: 3500,
    8: 5000,
    9: 7500,
    10: 10000
}

# Définition des badges par défaut
DEFAULT_BADGES = [
    {
        'name': 'Débutant',
        'description': 'Premier pas dans l\'apprentissage',
        'required_points': 0,
        'image': 'badges/beginner.png'
    },
    {
        'name': 'Apprenti',
        'description': 'Progression constante',
        'required_points': 500,
        'image': 'badges/apprentice.png'
    },
    {
        'name': 'Expert',
        'description': 'Maîtrise avancée',
        'required_points': 2000,
        'image': 'badges/expert.png'
    },
    {
        'name': 'Maître',
        'description': 'Excellence académique',
        'required_points': 5000,
        'image': 'badges/master.png'
    }
]

def calculate_level(points):
    """Calcule le niveau en fonction des points"""
    for level, threshold in sorted(LEVEL_THRESHOLDS.items(), reverse=True):
        if points >= threshold:
            return level
    return 1

def calculate_progress_to_next_level(points):
    """Calcule la progression vers le niveau suivant"""
    current_level = calculate_level(points)
    next_level = current_level + 1
    
    if next_level > max(LEVEL_THRESHOLDS.keys()):
        return 100
    
    current_threshold = LEVEL_THRESHOLDS[current_level]
    next_threshold = LEVEL_THRESHOLDS[next_level]
    
    progress = ((points - current_threshold) / 
                (next_threshold - current_threshold)) * 100
    return min(progress, 100)

@receiver(post_save, sender=Progress)
def update_student_points(sender, instance, created, **kwargs):
    """Met à jour les points de l'étudiant après une progression"""
    if created:
        try:
            student = instance.student
            # Ajoute les points basés sur le score
            points_earned = int(instance.score * instance.exercise.points / 100)
            student.points += points_earned
            
            # Met à jour le niveau
            new_level = calculate_level(student.points)
            if new_level > student.level:
                student.level = new_level
            
            student.save()
            
            # Vérifie les badges
            check_and_award_badges(student)
        except Exception as e:
            # Log l'erreur ou notifier l'administrateur
            print(f"Erreur lors de la mise à jour des points de l'étudiant : {str(e)}")

def check_and_award_badges(student):
    """Vérifie et attribue les badges si l'étudiant est éligible"""
    available_badges = Badge.objects.all()
    
    for badge in available_badges:
        if badge.check_eligibility(student) and not student.badges.filter(id=badge.id).exists():
            badge.award(student)
