import re
import logging
import time, datetime
import settings
import simplejson
import pytz
import random
import ordereddict

from django.shortcuts import render
from django.http import Http404, HttpResponse, HttpResponseNotFound, QueryDict, HttpResponseRedirect
from django.shortcuts import render_to_response, redirect
from django.core.urlresolvers import reverse
from django.views.decorators.csrf import csrf_exempt

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
        pass

# Create your views here.

def auth(request):
    return HttpResponse("auth")

def vote(request):
    return HttpResponse("vote")

def stream(request):
    return HttpResponse("stream")

def resendemail(request):
    return HttpResponse("resendemail")
