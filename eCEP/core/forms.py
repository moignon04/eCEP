# from django import forms
# from django.contrib.auth.forms import UserCreationForm
# from core.models import User
# from keysGen.models import License
# from django.core.exceptions import ValidationError

# class LoginForm(forms.Form):
#     username = forms.CharField(widget=forms.TextInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre Nom'
#     })),
#     password = forms.CharField(widget=forms.PasswordInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre mot de passe'
#     })),

# class SignUpForm(UserCreationForm):
#     first_name = forms.CharField(max_length=30, required=True, widget=forms.TextInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre prénom'
#     }))
#     last_name = forms.CharField(max_length=30, required=True, widget=forms.TextInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre nom'
#     }))
#     username = forms.CharField(widget=forms.TextInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre nom'
#     }))
#     email = forms.EmailField(widget=forms.EmailInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre email',
#     }))
#     role = forms.ChoiceField(choices=User.ROLE_CHOICES, widget=forms.Select(attrs={
#         'class': 'form-control'
#     }))
#     password1 = forms.CharField(widget=forms.PasswordInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Entrez votre mot de passe'
#     }))
#     password2 = forms.CharField(widget=forms.PasswordInput(attrs={
#         'class': 'form-control',
#         'placeholder': 'Confirmez votre mot de passe'
#     }))

#     class Meta:
#         model = User
#         fields = ('first_name', 'last_name', 'username', 'email', 'role', 'password1', 'password2')

#     def clean_username(self):
#         username = self.cleaned_data.get('username')
#         if User.objects.filter(username=username).exists():
#             raise ValidationError("Ce nom d'utilisateur est déjà pris.")
#         return username

# class LicenseForm(forms.ModelForm):
#     serial_number = forms.CharField(
#         max_length=17,
#         min_length=17,
#         widget=forms.TextInput(attrs={
#             'class': 'form-control',
#             'placeholder': 'Entrez le numéro de série (17 chiffres)'
#         })
#     )
    
#     description = forms.CharField(
#         widget=forms.Textarea(attrs={
#             'class': 'form-control',
#             'placeholder': 'Entrez la description'
#         })
#     )

#     class Meta:
#         model = License
#         fields = ['serial_number', 'description']

#     def clean_serial_number(self):
#         serial_number = self.cleaned_data.get('serial_number')
#         if not serial_number.isdigit():
#             raise forms.ValidationError("Le numéro de série doit contenir uniquement des chiffres.")
#         if LicenseKey.objects.filter(serial_number=serial_number).exists():
#             raise forms.ValidationError("Ce numéro de série existe déjà.")
#         return serial_number

# from .models import Course

# class CourseForm(forms.ModelForm):
#     class Meta:
#         model = Course
#         fields = ['title', 'description', 'level', 'video_file', 'pdf_file', 'audio_file']
    