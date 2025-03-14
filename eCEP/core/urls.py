from django.urls import path, include
# from django.contrib.auth.views import LogoutView
# from . import views

urlpatterns = [
    path('api/', include('core.api.urls')),
    # path('', views.home, name='home'),
    # path('payment/', views.payment, name='payment'),
    # path('paymentMobile/', views.paymentMobile, name='paymentMobile'),
    # path('login/', views.login_view, name='login'),
    # path('logout/', LogoutView.as_view(next_page='home'), name='logout'),
    # path('register/', views.register, name='register'),
    # path('receipts_home/', views.receipts_home, name='receipts_home'),
    # path('courses/', views.course_list, name='course_list'),
    # path('courses/add/', views.course_create, name='course_create'),
    # path('courses/edit/<int:course_id>/', views.course_edit, name='course_edit'),
    # path('courses/<int:course_id>/', views.course_detail, name='course_detail'),
    # path('register-fcm-token/', views.register_fcm_token, name='register_fcm_token'),
] 