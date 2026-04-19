import uuid, base64, json, hmac, hashlib
import requests
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from apps.authentication.models import AccessToken
from .models import PaymentRecord

def _issue_token(device_id, transaction_id, access_type):
    token = str(uuid.uuid4())
    AccessToken.objects.create(
        token=token, device_id=device_id,
        transaction_id=transaction_id, access_type=access_type)
    return token

# ── eSewa ────────────────────────────────────────────────────────────────
@api_view(['POST'])
@permission_classes([AllowAny])
def esewa_verify(request):
    encoded_data = request.data.get('encoded_data', '')
    device_id    = request.data.get('device_id', '')
    try:
        decoded = json.loads(base64.b64decode(encoded_data).decode())
        txn_id  = decoded.get('transaction_uuid', str(uuid.uuid4()))
        amount  = decoded.get('total_amount', 0)

        # Verify with eSewa
        resp = requests.get(settings.ESEWA_VERIFY_URL, params={
            'product_code': settings.ESEWA_CLIENT_ID,
            'total_amount': amount,
            'transaction_uuid': txn_id,
        }, timeout=10)
        data = resp.json()

        if data.get('status') == 'COMPLETE':
            rec, _ = PaymentRecord.objects.get_or_create(
                transaction_id=txn_id,
                defaults={'gateway': 'esewa', 'device_id': device_id,
                          'amount': amount, 'status': 'success', 'raw_response': data})
            token = _issue_token(device_id, txn_id, 'full')
            return Response({'success': True, 'access_token': token})
        return Response({'success': False, 'detail': 'Payment not complete'}, status=400)
    except Exception as e:
        return Response({'success': False, 'detail': str(e)}, status=400)

@api_view(['GET'])
@permission_classes([AllowAny])
def esewa_success(request):
    return Response({'message': 'eSewa payment received. Verifying...'})

@api_view(['GET'])
@permission_classes([AllowAny])
def esewa_failure(request):
    return Response({'message': 'eSewa payment failed.'}, status=400)

# ── Khalti ───────────────────────────────────────────────────────────────
@api_view(['POST'])
@permission_classes([AllowAny])
def khalti_initiate(request):
    payload = {
        'return_url':           request.data.get('return_url'),
        'website_url':          request.data.get('website_url', 'https://jftmocktest.com'),
        'amount':               request.data.get('amount'),
        'purchase_order_id':    request.data.get('purchase_order_id'),
        'purchase_order_name':  request.data.get('purchase_order_name'),
    }
    headers = {'Authorization': f'key {settings.KHALTI_SECRET_KEY}'}
    try:
        resp = requests.post(settings.KHALTI_INITIATE_URL, json=payload, headers=headers, timeout=10)
        data = resp.json()
        if resp.status_code == 200:
            return Response({'payment_url': data.get('payment_url'), 'pidx': data.get('pidx')})
        return Response({'error': data}, status=400)
    except Exception as e:
        return Response({'error': str(e)}, status=500)

@api_view(['POST'])
@permission_classes([AllowAny])
def khalti_verify(request):
    pidx      = request.data.get('pidx', '')
    device_id = request.data.get('device_id', '')
    headers   = {'Authorization': f'key {settings.KHALTI_SECRET_KEY}'}
    try:
        resp = requests.post(settings.KHALTI_VERIFY_URL, json={'pidx': pidx}, headers=headers, timeout=10)
        data = resp.json()
        if data.get('status') == 'Completed':
            txn_id = data.get('transaction_id', str(uuid.uuid4()))
            amount = data.get('total_amount', 0) / 100
            PaymentRecord.objects.get_or_create(
                transaction_id=txn_id,
                defaults={'gateway': 'khalti', 'device_id': device_id,
                          'amount': amount, 'status': 'success', 'raw_response': data})
            token = _issue_token(device_id, txn_id, 'full')
            return Response({'success': True, 'access_token': token})
        return Response({'success': False, 'detail': 'Not completed'}, status=400)
    except Exception as e:
        return Response({'success': False, 'detail': str(e)}, status=400)

@api_view(['GET'])
@permission_classes([AllowAny])
def khalti_callback(request):
    return Response({'message': 'Khalti callback received.'})