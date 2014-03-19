import re
import logging
import time, datetime
import simplejson
import pytz
import random
import ordereddict

from django.shortcuts import render
from django.http import Http404, HttpResponse, HttpResponseNotFound, QueryDict, HttpResponseRedirect
from django.shortcuts import render_to_response, redirect
from django.core.urlresolvers import reverse
from django.views.decorators.csrf import csrf_exempt

from backend import send_email

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
        pass

# Create your views here.

ORG_DOMAIN_LIST = [
    'google.com',
    'hightail.com',
    'gmail.com',
]


@csrf_exempt
def auth(request):
    response = {'status': 1, 'domain': ''}
    email = request.POST.get('email')
    domain = ''
    try:
        domain = email.split('@')[1]
        if not domain or domain not in ORG_DOMAIN_LIST:
            raise
        print "HELLO NOW HERE"
        send_email.send_verify_email()
    except Exception, e:
        print "%s" % e
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    response = {'status': 0, 'domain': domain}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")


def vote(request):
    return HttpResponse("vote")

def stream(request):
    return HttpResponse("stream")

def resendemail(request):
    return HttpResponse("resendemail")


