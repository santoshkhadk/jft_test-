from rest_framework import serializers
from .models import TestResult

class TestResultSerializer(serializers.ModelSerializer):
    class Meta:
        model  = TestResult
        fields = ('id','device_id','question_set','score','total_questions',
                  'percentage','passed','time_taken_seconds','completed_at')
        read_only_fields = ('id','completed_at')