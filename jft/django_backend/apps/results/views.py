from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import TestResult
from .serializers import TestResultSerializer

class ResultCreate(generics.CreateAPIView):
    queryset         = TestResult.objects.all()
    serializer_class = TestResultSerializer
    permission_classes = [AllowAny]

class ResultList(generics.ListAPIView):
    serializer_class = TestResultSerializer
    permission_classes = [AllowAny]
    def get_queryset(self):
        device_id = self.request.query_params.get('device_id')
        if device_id: return TestResult.objects.filter(device_id=device_id)
        return TestResult.objects.none()