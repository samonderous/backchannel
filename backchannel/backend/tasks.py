import logging

from apns import APNs, Payload, Frame
from celery import task
from backend.models import *
from backchannel import settings

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
	if not settings.PRODUCTION:
		apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelKey.pem')
	else:
		apns = APNs(use_sandbox=False, cert_file='/home/ubuntu/apns/BackchannelProdCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelProdKey.pem')
		

	owner = secret.user
	if owner.device_token and owner != comment.user:
		payload = Payload(alert="A coworker just commented on your post.", 
							sound="default", 
							custom={'type': 'detail_view', 'sid': secret.id})
		apns.gateway_server.send_notification(owner.device_token, payload)

	followers = Comment.objects.filter(secret=secret).order_by('-id')

	check_duplicate = []
	user_followers = []
	for follower in followers:
		if follower.user.email in check_duplicate:
			continue
		else:
			check_duplicate.append(follower.user.email)
			user_followers.append(follower)

	for follower in user_followers:

		# filter out the commenting user from getting his own push that he commented
		if follower.user == comment.user:
			continue

		# IF the owner had previously commented on his own post and is the creator of the post 
		if follower.user == owner:
			continue

		# device token is just bad
		if not follower.user.device_token or not follower.user.device_token.strip():
			continue

		if follower.user.device_token:
			payload = Payload(alert="A coworker just added to your comment on a post.", 
								sound="default", 
								custom={'type': 'detail_view', 'sid': comment.secret.id})
			apns.gateway_server.send_notification(follower.user.device_token, payload)


@task()
def send_notification_on_new_vote(usersecret):
	if not settings.PRODUCTION:
		apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelKey.pem')
	else:
		apns = APNs(use_sandbox=False, cert_file='/home/ubuntu/apns/BackchannelProdCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelProdKey.pem')
	owner = usersecret.secret.user
	if not owner.device_token or owner == usersecret.user:
		return
	payload = Payload(alert="A coworker just voted on your post.", 
						sound="default", 
						custom={'type': 'detail_view', 'sid': usersecret.secret.id})
	apns.gateway_server.send_notification(owner.device_token, payload)


@task()
def send_notification_on_new_coworkers_joined(newuser):
	if not settings.PRODUCTION:
		apns = APNs(use_sandbox=True, cert_file='/home/ubuntu/apns/BackchannelCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelKey.pem')
	else:
		apns = APNs(use_sandbox=False, cert_file='/home/ubuntu/apns/BackchannelProdCert.pem', 
					key_file='/home/ubuntu/apns/BackchannelProdKey.pem')

	users = User.objects.filter(org=newuser.org).order_by('-id')
	user_push = [] 
	for user in users:
		if not user.device_token or not user.device_token.strip() or newuser == user:
			continue

		if user.email in user_push:
			continue
		else:
			user_push.append(user.email)

		payload = Payload(alert="A few more coworkers just joined your backchannel.", 
							sound="default", 
							custom={'type': 'stream_view'})
		apns.gateway_server.send_notification(user.device_token, payload)
