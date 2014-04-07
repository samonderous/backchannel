import datetime
import time
import logging

from django.core import mail
from django.core.mail import EmailMultiAlternatives
from django.template import loader, Context
from django.core.urlresolvers import reverse

from pytz import timezone

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
        pass

def send_verify_email(org, email, udid):

	to_email = email or 'saureen@gmail.com'
	subject = "Verify your email to join %s's Backchannel" % org.name

	link = "<a href='backchannel://backchannel.it/?u=%s'>Please click here</a>" % udid
	item_html = "%s on your iPhone to verify your account" % link

	footer = "<br /><br />Welcome,<br />The Backchannel Team"
	msg = EmailMultiAlternatives(subject, "", from_email = "Backchannel <backchannel@backchannel.it>", to=[to_email])
	msg.attach_alternative(item_html + footer, "text/html")

	try:
		msg.send()
	except Exception, e:
		print "send_email exception = %s" % e
