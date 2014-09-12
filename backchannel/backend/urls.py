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
    url(r'^createsecret/', views.createsecret, name='createsecret'),
    url(r'^getlatestsecrets/', views.getlatestposts, name='getlatestposts'),
    url(r'^getlatestposts/', views.getlatestposts, name='getlatestposts'),
    url(r'^getolderposts/', views.getolderposts, name='getolderposts'),
    url(r'^signup/', views.signup, name='signup'),
    url(r'^share/', views.share, name='share'),
    url(r'^invite/', views.invite, name='invite'),
    url(r'^comments/', views.comments, name='comments'),
    url(r'^createcomment/', views.createcomment, name='createcomment'),
)

urlpatterns += staticfiles_urlpatterns()
