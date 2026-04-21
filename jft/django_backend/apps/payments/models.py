from django.db import models

class PaymentRecord(models.Model):
    GATEWAY_CHOICES = [('esewa', 'eSewa'), ('khalti', 'Khalti')]
    STATUS_CHOICES  = [('pending', 'Pending'), ('success', 'Success'), ('failed', 'Failed')]

    gateway        = models.CharField(max_length=10, choices=GATEWAY_CHOICES)
    transaction_id = models.CharField(max_length=255, unique=True)
    device_id      = models.CharField(max_length=255)
    amount         = models.DecimalField(max_digits=10, decimal_places=2)
    access_type    = models.CharField(max_length=20, default='full')
    status         = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    raw_response   = models.JSONField(default=dict)
    created_at     = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.gateway} | {self.transaction_id} | {self.status}"