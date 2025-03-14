from django.shortcuts import render
from .models import License
from django.http import JsonResponse

# Create your views here.

def generate_activation_key(request):
    if request.method == 'POST':
        serial_number = License.generate_key()
        return JsonResponse({'status': 'success', 'key': str(serial_number)})
    return JsonResponse({'status': 'error', 'message': 'Méthode non autorisée'})