from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    class Meta:
        model  = User
        fields = ('email', 'username', 'password')
    def create(self, data):
        return User.objects.create_user(
            email=data['email'], username=data.get('username', data['email']),
            password=data['password'])

class LoginSerializer(serializers.Serializer):
    email    = serializers.EmailField()
    password = serializers.CharField(write_only=True)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = ('id', 'email', 'username', 'has_access', 'access_type')