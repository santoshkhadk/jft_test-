from rest_framework import serializers
from .models import QuestionSet, Question

class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Question
        fields = ('id','question_text','question_text_ja','options',
                  'correct_option_index','explanation','explanation_ja',
                  'category','difficulty','audio_url','image_url')

class QuestionSetListSerializer(serializers.ModelSerializer):
    question_count = serializers.ReadOnlyField()
    class Meta:
        model  = QuestionSet
        fields = ('id','title','title_ja','category','level',
                  'duration_minutes','passing_percentage','question_count')

class QuestionSetDetailSerializer(serializers.ModelSerializer):
    questions = QuestionSerializer(many=True, read_only=True)
    class Meta:
        model  = QuestionSet
        fields = ('id','title','title_ja','category','level',
                  'duration_minutes','passing_percentage','questions')