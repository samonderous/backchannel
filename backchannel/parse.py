import random
import logging
import time
import os
import string
import optparse
from optparse import OptionParser

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backchannel.settings")
from backend.models import *
from backend import send_email

groups = {}

try:
	logging.basicConfig(
	level = logging.DEBUG,
	format = '%(asctime)s %(levelname)s %(message)s',
	filename = '/tmp/debug.log',
	filemode = 'w')
except:
	pass


class Contact(object):

    def __init__(self, name):
        self.name = name
        self.last_emailed = None
        self.emailed_times = 0
 
    def get_email(self):
        if not self.name:
            return ''
        name = self.name.strip()
        parts = name.split(' ')
        email = parts[0][0] + parts[-1] + '@linkedin.com' 
        email = string.lower(email)
        return email


    def email(self):
        pass


class Simulate(object):

    def process(self):
        group = None

        inputfile = os.path.join('/home/ubuntu/Backchannel/backchannel/backend/scripts/lnkd.txt')
        fd = open(inputfile, 'rb')
        for line in fd.readlines():
            line = line.strip()
            if not line:
                continue
            line = line.split(" ")
            if line[0] == '--':
                group = " ".join(line[1:])
                groups[group] = []
            else:
            	contact = Contact(" ".join(line))
            	groups[group].append(contact)

        #print groups

    def insertDb(self):
        for k in groups:
            for c in groups[k]:
                tco = TrackClickOrg()
                tco.email = c.get_email()
                tco.clicked = 0
                tco.org = k
                tco.save()

    def simulate(self):
    	for k in groups:
            for c in groups[k]:
                c.get_email()


    def sendemail(self):
        logging.debug("Starting send...")
        #photo = 'photo3.PNG'
        photo = 'IMG_1136.PNG'
        for tco in TrackClickOrg.objects.all():
            if tco.org != 'PMM':
                continue

            email = tco.email
            logging.debug("Sending email to %s with ic=%s" % (email, tco.id))
            try:
                #send_email.send_share_email(tco.email, tco.id, photo)
                send_email.send_share_email(email, tco.id, photo)
            except Exception, e:
                logging.debug("Exception sending email: %s" % e)
                continue
            secs = random.randint(1, 4 * 60)
            logging.debug("Sleeping for %s secs" % secs)
            time.sleep(secs)
            if 1 == random.randint(1, 4):
                time.sleep(2 * 60)

        logging.debug("Ended")

    def sendoneemail(self, email, random=False):
        logging.debug("Starting send one...")
        #photo = 'photo3.PNG'
        photo = 'IMG_1140.PNG'
        if email == 'saureen@gmail.com' or random:
            send_email.send_share_email(email, 0, photo)
            return
        else:
            tco = TrackClickOrg.objects.get(email=email)

        logging.debug("Sending email to %s with ic=%s" % (email, tco.id))
        try:
            send_email.send_share_email(email, tco.id, photo)
        except Exception, e:
            logging.debug("Exception sending email: %s" % e)

        logging.debug("Ended one email test")



if __name__ == '__main__':
    sim = Simulate()

    #sim.process()
    #sim.insertDb()
    #sim.simulate()

    sim.sendemail()
