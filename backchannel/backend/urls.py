from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.contrib import admin
admin.autodiscover()

from backend import views

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'backchannel.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
    url(r'^auth/', views.auth, name='auth'),
    url(r'^verify/', views.verify, name='verify'),
    url(r'^vote/', views.vote, name='vote'),
    url(r'^stream/', views.stream, name='stream'),
    url(r'^resendemail/', views.resendemail, name='resendemail'),
)

urlpatterns += staticfiles_urlpatterns()
