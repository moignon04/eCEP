from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from keysGen.models import License
from .models import (
    User, Student, Teacher, Parent, Admin,
    Course, Resource, Exercise, Progress,
    Class, Badge, Notification, Exam, 
    Payment, Subscription,
    MobilePayment, MobilePaymentConfig,#License
)

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'is_staff')
    list_filter = ('role', 'is_staff', 'is_active')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('username',)
    fieldsets = UserAdmin.fieldsets + (
        ('Informations supplémentaires', {'fields': ('role', 'created_at')}),
    )

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ('user', 'grade', 'level', 'points')
    list_filter = ('grade', 'level')
    search_fields = ('user__username', 'user__email')

@admin.register(Teacher)
class TeacherAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_courses_count')
    search_fields = ('user__username', 'user__email')

    def get_courses_count(self, obj):
        return obj.courses.count()
    get_courses_count.short_description = 'Nombre de cours'

@admin.register(Parent)
class ParentAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_children_count')
    search_fields = ('user__username', 'user__email')

    def get_children_count(self, obj):
        return obj.children.count()
    get_children_count.short_description = 'Nombre d\'enfants'

@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('title', 'subject', 'teacher', 'created_at')
    list_filter = ('subject', 'created_at')
    search_fields = ('title', 'description', 'teacher__user__username')
    date_hierarchy = 'created_at'

@admin.register(Resource)
class ResourceAdmin(admin.ModelAdmin):
    list_display = ('title', 'type', 'course', 'offline_available')
    list_filter = ('type', 'offline_available')
    search_fields = ('title', 'course__title')

@admin.register(Exercise)
class ExerciseAdmin(admin.ModelAdmin):
    list_display = ('title', 'course', 'type', 'difficulty', 'points')
    list_filter = ('type', 'difficulty')
    search_fields = ('title', 'course__title')

@admin.register(Progress)
class ProgressAdmin(admin.ModelAdmin):
    list_display = ('student', 'course', 'score', 'completed_at')
    list_filter = ('completed_at',)
    search_fields = ('student__user__username', 'course__title')
    date_hierarchy = 'completed_at'

@admin.register(Class)
class ClassAdmin(admin.ModelAdmin):
    list_display = ('name', 'teacher', 'get_students_count', 'get_courses_count')
    search_fields = ('name', 'teacher__user__username')

    def get_students_count(self, obj):
        return obj.students.count()
    get_students_count.short_description = 'Nombre d\'étudiants'

    def get_courses_count(self, obj):
        return obj.courses.count()
    get_courses_count.short_description = 'Nombre de cours'

@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ('name', 'required_points', 'get_awarded_count')
    search_fields = ('name', 'description')

    def get_awarded_count(self, obj):
        return obj.students.count()
    get_awarded_count.short_description = 'Nombre d\'attributions'

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('type', 'recipient', 'created_at', 'read')
    list_filter = ('type', 'read', 'created_at')
    search_fields = ('message', 'recipient__username')
    date_hierarchy = 'created_at'

@admin.register(Exam)
class ExamAdmin(admin.ModelAdmin):
    list_display = ('title', 'course', 'date', 'total_points')
    list_filter = ('date',)
    search_fields = ('title', 'course__title')
    date_hierarchy = 'date'

# @admin.register(License)
# class LicenseAdmin(admin.ModelAdmin):
#     list_display = ('user', 'type', 'status', 'start_date', 'end_date')
#     list_filter = ('type', 'status')
#     search_fields = ('user__username', 'user__email')
#     date_hierarchy = 'start_date'


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = (
        'user', 'license', 'amount', 'currency',
        'payment_type', 'status', 'payment_date'
    )
    list_filter = ('payment_type', 'status', 'currency')
    search_fields = ('user__username', 'transaction_id')
    date_hierarchy = 'payment_date'

@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = (
        'user', 'license', 'interval',
        'auto_renew', 'next_billing_date'
    )
    list_filter = ('interval', 'auto_renew')
    search_fields = ('user__username',)
    date_hierarchy = 'next_billing_date'

@admin.register(MobilePayment)
class MobilePaymentAdmin(admin.ModelAdmin):
    list_display = (
        'payment', 'provider', 'phone_number',
        'status', 'initiated_at', 'completed_at'
    )
    list_filter = ('provider', 'status')
    search_fields = ('phone_number', 'reference')
    date_hierarchy = 'initiated_at'
    readonly_fields = ('reference', 'callback_data')

@admin.register(MobilePaymentConfig)
class MobilePaymentConfigAdmin(admin.ModelAdmin):
    list_display = (
        'provider', 'merchant_id',
        'is_active', 'test_mode'
    )
    list_filter = ('provider', 'is_active', 'test_mode')
    search_fields = ('merchant_id',)
    
    def get_readonly_fields(self, request, obj=None):
        if obj:
            return ('provider',)
        return ()

from .models import Video, Pdf, Audio, Chapter, Lesson, Choice, Question, Exo, Challenge, StudentChallenge, LicensePayment, ExamSessionModel

admin.site.register(Video)
admin.site.register(Pdf)
admin.site.register(Audio)
admin.site.register(Chapter)
admin.site.register(Lesson)
admin.site.register(Choice)
admin.site.register(Question)
admin.site.register(Exo)
admin.site.register(Challenge)
admin.site.register(StudentChallenge)
admin.site.register(LicensePayment)
admin.site.register(ExamSessionModel)