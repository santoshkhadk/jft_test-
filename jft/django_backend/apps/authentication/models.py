from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    email       = models.EmailField(unique=True)
    device_id   = models.CharField(max_length=255, blank=True)
    has_access  = models.BooleanField(default=False)
    access_type = models.CharField(max_length=20, blank=True)
    created_at  = models.DateTimeField(auto_now_add=True)
    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['username']
    def __str__(self): return self.email

class AccessToken(models.Model):
    token          = models.CharField(max_length=255, unique=True)
    device_id      = models.CharField(max_length=255)
    transaction_id = models.CharField(max_length=255, unique=True)
    access_type    = models.CharField(max_length=20, default='full')
    created_at     = models.DateTimeField(auto_now_add=True)
    expires_at     = models.DateTimeField(null=True, blank=True)
    def __str__(self): return f"{self.device_id} [{self.access_type}]"