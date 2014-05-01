import datetime
import time
import logging
import os.path
import re

from django.conf import settings
from django.core import mail
from django.core.mail import EmailMultiAlternatives, SafeMIMEMultipart
from django.template import loader, Context
from django.core.urlresolvers import reverse

from email.MIMEBase import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from pytz import timezone

try:
        logging.basicConfig(
        level = logging.DEBUG,
        format = '%(asctime)s %(levelname)s %(message)s',
        filename = '/tmp/debug.log',
        filemode = 'w')
except:
        pass


class EmailMultiRelated(EmailMultiAlternatives):
    """
    A version of EmailMessage that makes it easy to send multipart/related
    messages. For example, including text and HTML versions with inline images.
    
    @see https://djangosnippets.org/snippets/2215/
    """
    related_subtype = 'related'
    
    def __init__(self, *args, **kwargs):
        # self.related_ids = []
        self.related_attachments = []
        return super(EmailMultiRelated, self).__init__(*args, **kwargs)
    
    def attach_related(self, filename=None, content=None, mimetype=None):
        """
        Attaches a file with the given filename and content. The filename can
        be omitted and the mimetype is guessed, if not provided.

        If the first parameter is a MIMEBase subclass it is inserted directly
        into the resulting message attachments.
        """
        if isinstance(filename, MIMEBase):
            assert content == mimetype == None
            self.related_attachments.append(filename)
        else:
            assert content is not None
            self.related_attachments.append((filename, content, mimetype))
    
    def attach_related_file(self, path, mimetype=None):
        """Attaches a file from the filesystem."""
        filename = os.path.basename(path)
        content = open(path, 'rb').read()
        self.attach_related(filename, content, mimetype)
    
    def _create_message(self, msg):
        return self._create_attachments(self._create_related_attachments(self._create_alternatives(msg)))
    
    def _create_alternatives(self, msg):       
        for i, (content, mimetype) in enumerate(self.alternatives):
            if mimetype == 'text/html':
                for related_attachment in self.related_attachments:
                    if isinstance(related_attachment, MIMEBase):
                        content_id = related_attachment.get('Content-ID')
                        content = re.sub(r'(?<!cid:)%s' % re.escape(content_id), 'cid:%s' % content_id, content)
                    else:
                        filename, _, _ = related_attachment
                        content = re.sub(r'(?<!cid:)%s' % re.escape(filename), 'cid:%s' % filename, content)
                self.alternatives[i] = (content, mimetype)
        
        return super(EmailMultiRelated, self)._create_alternatives(msg)
    
    def _create_related_attachments(self, msg):
        encoding = self.encoding or settings.DEFAULT_CHARSET
        if self.related_attachments:
            body_msg = msg
            msg = SafeMIMEMultipart(_subtype=self.related_subtype, encoding=encoding)
            if self.body:
                msg.attach(body_msg)
            for related_attachment in self.related_attachments:
                if isinstance(related_attachment, MIMEBase):
                    msg.attach(related_attachment)
                else:
                    msg.attach(self._create_related_attachment(*related_attachment))
        return msg
    
    def _create_related_attachment(self, filename, content, mimetype=None):
        """
        Convert the filename, content, mimetype triple into a MIME attachment
        object. Adjust headers to use Content-ID where applicable.
        Taken from http://code.djangoproject.com/ticket/4771
        """
        attachment = super(EmailMultiRelated, self)._create_attachment(filename, content, mimetype)
        if filename:
            mimetype = attachment['Content-Type']
            del(attachment['Content-Type'])
            del(attachment['Content-Disposition'])
            attachment.add_header('Content-Disposition', 'inline', filename=filename)
            attachment.add_header('Content-Type', mimetype, name=filename)
            attachment.add_header('Content-ID', '<%s>' % filename)
        return attachment






def send_verify_email(org, email, udid):

	to_email = email or 'saureen@gmail.com'
	subject = "Verify your email to join %s's Backchannel" % org.name

	link1 = "<a href='backchannel://backchannel.it/?u=%s'>Please click here</a>" % udid
	link2 = "<a href='http://bckchannelapp.com/backend/verify/?u=%s'>here</a>" % udid
	item_html = "%s or %s on your iPhone to verify your account" % (link1, link2)

	footer = "<br /><br />Welcome,<br />The Backchannel Team"
	msg = EmailMultiAlternatives(subject, "", from_email = "Backchannel <backchannel@bckchannelapp.com>", to=[to_email])
	msg.attach_alternative(item_html + footer, "text/html")

	try:
		msg.send()
	except Exception, e:
		print "send_email exception = %s" % e


def send_share_email(email, code):

	to_email = email
	subject = "Someone at LinkedIn would like to backchannel something to you"

	# HTML + image container 
	related = MIMEMultipart("related")

        link = '<a href="http://bckchannelapp.com/backend/signup/?c=%s">Get invited to join LinkedIn\'s Backchannel</a>' % code

	# Add the HTML
	html = MIMEText("Can't be a PM posting this but agree with general sentiment :)<br /><br />" + link + "<br /><br /><a href='http://bckchannelapp.com/backend/signup/?c=%s'><img src='cid:photo1.PNG' width='50%' height='50%'/></a>", "html")
	related.attach(html)

	# Add an image
	with open("./backchannel/templates/photo1.PNG", "rb") as handle:
		image = MIMEImage(handle.read())
	image.add_header("Content-ID", "<photo1.PNG>")
	image.add_header("Content-Disposition", "inline")
	related.attach(image)

	msg = EmailMultiRelated(subject, "", from_email = "Backchannel <backchannel@bckchannelapp.com>", to=[to_email])

	# add the HTML version
	msg.attach(related)

	# Indicate that only one of the two types (text vs html) should be rendered
	msg.mixed_subtype = "alternative"
	msg.send()


def send_test():

	to_email = 'ajoshi@zynga.com'
	subject = "Verify your email to join Backchannel -- test"

	item_html = "Hello"

	footer = "Welcome, The Backchannel Team"
	msg = EmailMultiAlternatives(subject, "", from_email = "Backchannel <backchannel@backchannel.it>", to=[to_email])
	msg.attach_alternative(item_html + footer, "text/html")

	try:
		msg.send()
	except Exception, e:
		print "send_test exception = %s" % e



