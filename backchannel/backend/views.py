import re
import logging
import time, datetime
import simplejson
import pytz
import random
import ordereddict
import string

from django.shortcuts import render
from django.http import Http404, HttpResponse, HttpResponseNotFound, QueryDict, HttpResponseRedirect
from django.shortcuts import render_to_response, redirect
from django.core.urlresolvers import reverse
from django.views.decorators.csrf import csrf_exempt

from backend import send_email
from backend.models import *

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
        pass

# Create your views here.

@csrf_exempt
def auth(request):
    response = {'status': 1, 'domain': ''}
    email = request.POST.get('email', '')
    udid = request.POST.get('udid')

    if re.match('^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$', email) is None:
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    domain = email.split('@')[1]
    try:
        org = Org.objects.get(domain=domain)
        # TODO: Make async
        send_email.send_verify_email(org, email, udid)
    except Exception, e:
        response['status'] = 2
        waitlistorg = WaitlistOrg()
        waitlistorg.email = email
        waitlistorg.save()
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    emp_count = User.objects.filter(org=org).count()
    response = {'status': 0, 'email': email, 'emp_count': emp_count}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")

@csrf_exempt
def verify(request):
    if request.method == "POST":
        email = request.POST.get('email')
        udid = request.POST.get('udid')

        try:
            user = User.objects.get(udid=udid)
            response = {'status': 0}
            return HttpResponse(simplejson.dumps(response), content_type="application/json")
        except Exception, e:
            pass

        user = User()
        user.udid = udid
        user.email = string.lower(email)
        domain = email.split('@')[1]
        org = Org.objects.get(domain=domain)
        user.org = org
        user.save()
        response = {'status': 0, 'name': org.name, 'domain': org.domain}
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    return render_to_response('verify.html', {'u' : request.GET.get('u') })

@csrf_exempt
def vote(request):
    response = {'status': 1}
    if request.method != "POST":
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    udid = request.POST.get('udid')
    vote = request.POST.get('vote')
    sid = request.POST.get('sid')

    user = User.objects.get(udid=udid)
    secret = Secret.objects.get(id=sid)
    us = UserSecret()
    us.user = user
    us.secret = secret
    if vote == 'agree':
        us.vote = UserSecret.VOTE_AGREE
        secret.agrees += 1
    else:
        us.vote = UserSecret.VOTE_DISAGREE
        secret.disagrees += 1
    us.save() 
    secret.save()

    response = {'status': 0}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")

@csrf_exempt
def createsecret(request):
    response = {'status': 1}
    if request.method != "POST":
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    udid = request.POST.get('udid')
    text = request.POST.get('text')

    try:
        user = User.objects.get(udid=udid)
    except Exception, e:
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    secret = Secret()
    secret.secrettext = text
    secret.time_created = int(time.time())
    secret.user = user
    secret.org = user.org
    secret.agrees = 0
    secret.disagrees = 0

    secret.save()
 
    response = {'status': 0, 'sid': secret.id}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")

def _time_str(time_delta):
    time_str = ""
    if time_delta <= 10:
        time_str = "few seconds ago"
    elif time_delta > 10 and time_delta < 60:
        time_str = "%ss" % time_delta
    elif time_delta >= 60 and time_delta < 3600:
        time_str = "%sm" % (time_delta / 60)
    elif time_delta >= 3600 and time_delta < 86400:
        time_str = "%sh" % (time_delta / 60 / 60)
    else:
        time_str = "a few days ago"

    return time_str

def stream(request):

    response = {'status': 1}
    udid = request.GET.get('udid')
    
    try:
        user = User.objects.get(udid=udid)
    except Exception, e:
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    secrets = Secret.objects.filter(org=user.org).order_by('-id')[:50]

    secrets_list = []
    for s in secrets:
        try:
            us = UserSecret.objects.get(secret=s, user=user)
            vote = us.vote
        except Exception, e:
            vote = UserSecret.VOTE_NONE

        time_ago = int(time.time()) - s.time_created
        secret_dict = {
            'sid': s.id,
            'secrettext': s.secrettext,
            'time_created': s.time_created,
            'time_ago': _time_str(time_ago),
            'agrees': s.agrees,
            'disagrees': s.disagrees,
            'vote': vote
        }
        secrets_list.append(secret_dict)

    response = {'status': 0, 'secrets': secrets_list}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")

def getlatestposts(request):

    response = {'status': 1}
    udid = request.GET.get('udid')
    stid = request.GET.get('tsid')
 
    try:
        user = User.objects.get(udid=udid)
    except Exception, e:
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    # TODO: Fix this up if traffic ever warrants [:50] will be an issue
    secrets = Secret.objects.filter(org=user.org, id__gt=stid).order_by('-id')[:50]

    secrets_list = []
    for s in secrets:
        try:
            us = UserSecret.objects.get(secret=s, user=user)
            vote = us.vote
        except Exception, e:
            vote = UserSecret.VOTE_NONE

        time_ago = int(time.time()) - s.time_created
        secret_dict = {
            'sid': s.id,
            'secrettext': s.secrettext,
            'time_created': s.time_created,
            'time_ago': _time_str(time_ago),
            'agrees': s.agrees,
            'disagrees': s.disagrees,
            'vote': vote
        }
        secrets_list.append(secret_dict)

    response = {'status': 0, 'secrets': secrets_list}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")

def getolderposts(request):

    response = {'status': 1}
    udid = request.GET.get('udid')
    slid = request.GET.get('lsid')

    try:
        user = User.objects.get(udid=udid)
    except Exception, e:
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    # TODO: Fix this up if traffic ever warrants [:50] will be an issue
    secrets = Secret.objects.filter(org=user.org, id__lt=slid).order_by('id')[:10]

    secrets_list = []
    for s in secrets:
        try:
            us = UserSecret.objects.get(secret=s, user=user)
            vote = us.vote
        except Exception, e:
            vote = UserSecret.VOTE_NONE

        time_ago = int(time.time()) - s.time_created
        secret_dict = {
            'sid': s.id,
            'secrettext': s.secrettext,
            'time_created': s.time_created,
            'time_ago': _time_str(time_ago),
            'agrees': s.agrees,
            'disagrees': s.disagrees,
            'vote': vote
        }
        secrets_list.append(secret_dict)

    response = {'status': 0, 'secrets': secrets_list}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")


def resendemail(request):
    email = request.GET.get('email')
    udid = request.GET.get('udid')

    try:
        domain = email.split('@')[1]
        org = Org.objects.get(domain=domain)
        send_email.send_verify_email(org, email, udid)
    except Exception, e:
        response = {'status': 1}
        return HttpResponse(simplejson.dumps(response), content_type="application/json")

    response = {'status': 0}
    return HttpResponse(simplejson.dumps(response), content_type="application/json")


def signup(request):
    ic = request.GET.get('c')
    try:
        tc = TrackClick.objects.get(invite_code=ic)
        tc.clicked = 1
        tc.save()
    except Exception, e:
        pass

    return redirect('http://signup.backchannel.it')
