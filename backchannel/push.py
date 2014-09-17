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

groups = {}

try:
	logging.basicConfig(
	level = logging.DEBUG,
	format = '%(asctime)s %(levelname)s %(message)s',
	filename = '/tmp/debug.log',
	filemode = 'w')
except:
	pass

def pushonce():
	apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
				key_file='/home/ubuntu/apns/BackchannelKey.pem')
	user = User.objects.get(id=172)
	token = user.device_token
	print "%s" % token 

	payload = Payload(alert="TEST: A few more coworkers joined your Backchannel", 
						sound="default", 
						custom={'type': 'detail_view', 'sid': 294})
	apns.gateway_server.send_notification(token, payload)


if __name__ == '__main__':
    pushonce()
