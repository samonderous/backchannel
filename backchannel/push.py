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
	apns = APNs(use_sandbox=False, cert_file='/home/ubuntu/apns/BackchannelProdCert.pem', 
				key_file='/home/ubuntu/apns/BackchannelProdKey.pem')
	user = User.objects.get(id=146)
	token = user.device_token
	print "%s" % token 

    # backchannel.it: 259
	payload = Payload(alert="David, did you get this?", 
						sound="default", 
						custom={'type': 'stream_view'})
	apns.gateway_server.send_notification(token, payload)


	#payload = Payload(alert="TEST: A few more coworkers joined your Backchannel", 
	#					sound="default", 
	#					custom={'type': 'detail_view', 'sid': 259})
	#apns.gateway_server.send_notification(token, payload)


if __name__ == '__main__':
    pushonce()
