from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.contrib import admin
admin.autodiscover()


urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'backchannel.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
    #url(r'^$', 'backend.views.init', name='init'),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^backend/', include('backend.urls')),
)

urlpatterns += staticfiles_urlpatterns()
