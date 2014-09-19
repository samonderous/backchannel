"""
Django settings for backchannel project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'epy39e-z_fp3^6=k2g^6t97!qa181g9h#)^7(6h1lbr3+l%n^j'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'backend',
    'djcelery',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'backchannel.urls'

WSGI_APPLICATION = 'backchannel.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'backchannel',
        'USER': 'root',
        'PASSWORD': 'password',
    }
}

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

TEMPLATE_DIRS = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    '/home/ubuntu/Backchannel/backchannel/backchannel/templates',
)

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.messages.context_processors.messages',
    'django.contrib.auth.context_processors.auth',
)

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = ''

#Email Settings
EMAIL_USE_TLS = True
EMAIL_HOST = 'smtp.sendgrid.com'
EMAIL_HOST_USER = 'samonderous'
EMAIL_HOST_PASSWORD = '##work##story!'
EMAIL_PORT = 587


#broker
BROKER_URL = 'amqp://guest:guest@localhost:5672//'

import djcelery
from celery.schedules import crontab
from datetime import timedelta

djcelery.setup_loader()

CELERYBEAT_SCHEDULER = "djcelery.schedulers.DatabaseScheduler"
CELERYBEAT_PIDFILE = '/tmp/celerybeat.pid'
#CELERYBEAT_SCHEDULE = {
#    'add-every-10-seconds': {
#        'task': 'tasks.update_skills_index_long',
#        'schedule': timedelta(seconds=10),
#        'args': ()
#    },
#}
