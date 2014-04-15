import time
import random

from django.db import models
from django.contrib import admin

class User(models.Model):
    udid = models.CharField(max_length=200)
    email = models.CharField(max_length=500)
    org = models.ForeignKey('Org')

    class Meta:
        db_table = 'user'

    def __unicode__(self):
        return self.email


class Org(models.Model):
    name = models.CharField(max_length=200)
    domain = models.CharField(max_length=200)

    class Meta:
        db_table = 'org'

    def __unicode__(self):
        return self.name


class Secret(models.Model):
    secrettext = models.CharField(max_length=200)
    time_created = models.IntegerField()
    user = models.ForeignKey('User')
    org = models.ForeignKey('Org')
    agrees = models.IntegerField()
    disagrees = models.IntegerField()

    class Meta:
        db_table = 'secret'

    def __unicode__(self):
        return self.secrettext


class UserSecret(models.Model):
    VOTE_NONE     = 0
    VOTE_AGREE    = 1
    VOTE_DISAGREE = 2

    user = models.ForeignKey('User')
    secret = models.ForeignKey('Secret')
    vote = models.IntegerField()

    class Meta:
        db_table = 'user_secret'

    def __unicode__(self):
        return "user=%s, secret=%s" % (self.user, self.secret)


SEED_SECRETS = [
    "Today is going to be a good day :)",
    "Wish we had better food around here.",
    "David is a genius! Enuf said...",
    "Gah, I wish my manager listened to me more",
    "Please don't stop the music, music, music",
    "Its now or never",
    "I did something awesome at work today that I really want to tell everyone about",
    "We need no meeting days. Meeting tend to get way too long. Can't stand them.",
    "Guy next to me must not be getting any sleep",
    "Anybody else find it uncomfortable going to the bathroom at work?",
    "I'm going commando to work today",
    "Uhhh, so Backchannel is a Yammer meets Secret. Hrm.",
]


def seedcontent(org):

    dummy_user = User.objects.get(id=1)

    for secrettext in SEED_SECRETS:
        s = Secret()
        s.secrettext = secrettext
        s.time_created = int(time.time())
        s.user = dummy_user
        s.org = org
        s.agrees = random.randrange(7) 
        s.disagrees = 0
        s.save()


# Admin
class UserAdmin(admin.ModelAdmin):
    list_display = ('email',)

class OrgAdmin(admin.ModelAdmin):
    list_display = ('name',)

class SecretAdmin(admin.ModelAdmin):
    list_display = ('secrettext',)

class UserSecretAdmin(admin.ModelAdmin):
    pass

admin.site.register(User, UserAdmin)
admin.site.register(Org, OrgAdmin)
admin.site.register(Secret, SecretAdmin)
admin.site.register(UserSecret, UserSecretAdmin)

