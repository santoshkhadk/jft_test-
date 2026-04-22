from django.contrib import admin
from .models import PaymentRecord

@admin.register(PaymentRecord)
class PaymentRecordAdmin(admin.ModelAdmin):
    list_display  = ('gateway', 'transaction_id', 'device_id', 'amount', 'status', 'created_at')
    list_filter   = ('gateway', 'status')
    search_fields = ('transaction_id', 'device_id')
    ordering      = ('-created_at',)