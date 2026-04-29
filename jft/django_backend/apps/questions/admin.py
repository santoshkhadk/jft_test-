from django.contrib import admin
from .models import QuestionSet, Question

class QuestionInline(admin.TabularInline):
    model  = Question
    extra  = 1
    fields = ('question_text','question_text_ja','options','correct_option_index',
              'explanation','category','difficulty','order')

@admin.register(QuestionSet)
class QuestionSetAdmin(admin.ModelAdmin):
    list_display  = ('title','category','level','duration_minutes','question_count','is_active','order')
    list_filter   = ('category','level','is_active')
    search_fields = ('title',)
    ordering      = ('order',)
    inlines       = [QuestionInline]

@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display  = ('question_text','question_set','category','difficulty','order')
    list_filter   = ('category','difficulty','question_set')
    search_fields = ('question_text',)