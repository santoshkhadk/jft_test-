from django.urls import path
from . import views
urlpatterns = [
    path('',      views.ResultCreate.as_view(), name='result-create'),
    path('list/', views.ResultList.as_view(),   name='result-list'),
]