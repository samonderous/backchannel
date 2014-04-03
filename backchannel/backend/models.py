from django.db import models
from django.contrib import admin

class User(models.Model):
    udid = models.CharField(max_length=200)
    email = models.CharField(max_length=500)
    org = models.ForeignKey('Org')

    class Meta:
        db_table = 'user'

class Org(models.Model):
    name = models.CharField(max_length=200)
    domain = models.CharField(max_length=200)

    class Meta:
        db_table = 'org'

class Secret(models.Model):
    secrettext = models.CharField(max_length=200)
    time_created = models.IntegerField()
    user = models.ForeignKey('User')
    org = models.ForeignKey('Org')
    agrees = models.IntegerField()
    disagrees = models.IntegerField()

    class Meta:
        db_table = 'secret'

class UserSecret(models.Model):
    VOTE_NONE     = 0
    VOTE_AGREE    = 1
    VOTE_DISAGREE = 2

    user = models.ForeignKey('User')
    secret = models.ForeignKey('Secret')
    vote = models.IntegerField()

    class Meta:
        db_table = 'user_secret'


# Admin
class UserAdmin(admin.ModelAdmin):
    pass

class OrgAdmin(admin.ModelAdmin):
    pass

class SecretAdmin(admin.ModelAdmin):
    pass

class UserSecretAdmin(admin.ModelAdmin):
    pass

admin.site.register(User, UserAdmin)
admin.site.register(Org, OrgAdmin)
admin.site.register(Secret, SecretAdmin)
admin.site.register(UserSecret, UserSecretAdmin)

