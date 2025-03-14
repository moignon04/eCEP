import token
from django import forms
from django.http import response
from django.shortcuts import render, redirect, get_object_or_404
from django.utils.ipv6 import is_valid_ipv6_address
from .models import Payment, Teacher, User
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.forms import UserCreationForm
from . import forms
from django.contrib import messages
from firebase_admin import messaging
from django.http import JsonResponse

@login_required
def register_fcm_token(request):
    if request.method == 'POST':
        token = request.POST.get('token')
        if token:
            request.user.fcm_token = token
            request.user.save()
            return JsonResponse({'status': 'success'})
        return JsonResponse({'status': 'error', 'message': 'Token maquant'})
    return JsonResponse({'status': 'error', 'message': 'Méthode non autorisée'})

def send_push_notification(token, title, body):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=token
    )
    response = messaging.send(message)
    return response


from django.core.validators import validate_email
from django.core.exceptions import ValidationError

def register(request):
    if request.method == 'POST':
        form = forms.SignUpForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            try:
                validate_email(email)  # Valider le format de l'email
            except ValidationError:
                messages.error(request, 'Adresse email invalide')
                return redirect('register')
                
            if User.objects.filter(email=email).exists():
                messages.error(request, 'Un compte existe déjà avec cette adresse email')
                return redirect('register')
                
            user = form.save(commit=False)
            user.first_name = form.cleaned_data['first_name']
            user.last_name = form.cleaned_data['last_name']
            user.username = form.cleaned_data['username']
            user.email = email
            user.save()  
            login(request, user)
            return redirect('login')
    else:
        form = forms.SignUpForm()
    return render(request, 'register.html', {'form': form})


def login_view(request):
    if request.method == 'POST':
        form = AuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                return redirect('receipts_home')  # Rediriger vers la page d'accueil après la connexion
    else:
        form = AuthenticationForm()
    return render(request, 'login.html', {'form': form})

def home(request):
    return render(request, 'home.html')

def paymentMobile(request):
    return render(request, 'paymentMobile.html')


@login_required
def payment(request):
    if request.method == 'POST':
        amount = request.POST.get('amount')
        try:
            amount = float(amount)
            if amount <= 0:
                raise ValueError("Le montant doit être positif")
        except (ValueError, TypeError):
            messages.error(request, 'Montant invalide')
            return redirect('payment')
        
        license = License.objects.filter(user=request.user).first()
        if not license:
            return render(request, 'core/payment.html', {'error': 'Aucune licence trouvée'})
        Payment.objects.create(
            user=request.user,
            amount=amount,
            status='pending',
            license=license
        )
        return redirect('receipts_home')
    return render(request, 'payment.html')

def receipts_home(request):
    return render(request, 'receipts_home.html')

from .models import Course

def course_list(request):
    courses = Course.objects.select_related('teacher__user').all()
    return render(request, 'course_list.html', {'courses': courses})

# core/views.py
@login_required
def course_create(request):
    if request.method == 'POST':
        form = forms.CourseForm(request.POST, request.FILES)
        if form.is_valid():
            try:
                course = form.save(commit=False)
                course.teacher = Teacher.objects.get(user=request.user)
                course.save()
                return redirect('course_list')
            except Teacher.DoesNotExist:
                messages.error(request, 'Vous devez être un enseignant pour créer un cours.')
                return redirect('course_create')
            except Exception as e:
                messages.error(request, f'Une erreur s\'est produite : {str(e)}')
                return redirect('course_create')
    else:
        form = forms.CourseForm()
    return render(request, 'course_create.html', {'form': form})

@login_required
def course_edit(request, course_id):
    course = Course.objects.get(id=course_id)
    if request.method == 'POST':
        form = forms.CourseForm(request.POST, instance=course)
        if form.is_valid():
            form.save()
            return redirect('course_list')
    else:
        form = forms.CourseForm(instance=course)
    return render(request, 'course_create.html', {'form': form})

@login_required
def course_detail(request, course_id):
    course = get_object_or_404(Course, id=course_id)
    return render(request, 'course_detail.html', {'course': course})

