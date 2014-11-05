import random
import logging
import time
import os
import string
import optparse
from optparse import OptionParser
from apns import APNs, Payload, Frame

from datetime import datetime
import pytz

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backchannel.settings")
from backend.models import *
from backend.tasks import * 

groups = {}

try:
	logging.basicConfig(
	level = logging.DEBUG,
	format = '%(asctime)s %(levelname)s %(message)s',
	filename = '/tmp/debug.log',
	filemode = 'w')
except:
	pass

def pingonce():
	user = User.objects.get(id=171)
	send_notification_on_new_coworkers_joined.delay(user)

if __name__ == '__main__':
    pingonce()
