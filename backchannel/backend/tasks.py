import logging

from apns import APNs, Payload, Frame
from celery import task
from backend.models import *

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
    pass



@task()
def send_notifications_on_new_comment(secret, comment):
	apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
				key_file='/home/ubuntu/apns/BackchannelKey.pem')

	owner = secret.user
	if owner.device_token and owner != comment.user:
		payload = Payload(alert="A coworker just commented on your post.", 
							sound="default", 
							custom={'type': 'detail_view', 'sid': secret.id})
		apns.gateway_server.send_notification(owner.device_token, payload)

	followers = Comment.objects.filter(secret=secret)
	for follower in followers:
		if follower.user == comment.user or owner == comment.user:
			continue

		if follower.user.device_token:
			payload = Payload(alert="A coworker just added to your comment on a post.", 
								sound="default", 
								custom={'type': 'detail_view', 'sid': secret.id})
			apns.gateway_server.send_notification(follower.user.device_token, payload)


@task()
def send_notification_on_new_vote(usersecret):
	apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
				key_file='/home/ubuntu/apns/BackchannelKey.pem')
	owner = usersecret.secret.user
	if not owner.device_token or owner == usersecret.user:
		return
	payload = Payload(alert="A coworker just voted on your post.", 
						sound="default", 
						custom={'type': 'detail_view', 'sid': usersecret.secret.id})
	apns.gateway_server.send_notification(owner.device_token, payload)


@task()
def send_notification_on_new_coworkers_joined(newuser):
	apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
				key_file='/home/ubuntu/apns/BackchannelKey.pem')
	users = User.objects.filter(org=newuser.org)
	for user in users:
		if not user.device_token or newuser == user:
			continue

		payload = Payload(alert="A few more coworkers just joined your backchannel.", 
							sound="default", 
							custom={'type': 'stream_view'})
		apns.gateway_server.send_notification(user.device_token, payload)
