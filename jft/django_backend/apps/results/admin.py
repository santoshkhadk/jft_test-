from django.contrib import admin
from .models import TestResult

@admin.register(TestResult)
class TestResultAdmin(admin.ModelAdmin):
    list_display  = ('device_id','question_set','score','total_questions','percentage','passed','completed_at')
    list_filter   = ('passed','question_set')
    search_fields = ('device_id',)
    ordering      = ('-completed_at',)