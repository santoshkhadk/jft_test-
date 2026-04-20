from django.urls import path
from . import views
urlpatterns = [
    path('esewa/verify/',      views.esewa_verify,   name='esewa-verify'),
    path('esewa/success/',     views.esewa_success,  name='esewa-success'),
    path('esewa/failure/',     views.esewa_failure,  name='esewa-failure'),
    path('khalti/initiate/',   views.khalti_initiate, name='khalti-initiate'),
    path('khalti/verify/',     views.khalti_verify,   name='khalti-verify'),
    path('khalti/callback/',   views.khalti_callback, name='khalti-callback'),
]