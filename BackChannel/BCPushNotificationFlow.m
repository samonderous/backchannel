//
//  BCPushNotificationFlow.m
//  BackChannel
//
//  Created by Saureen Shah on 9/16/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCPushNotificationFlow.h"
#import "BCGlobalsManager.h"


static NSString *kFallbackMessage = @"Go to Settings > Notifications and enable Backchannel to notify you when your coworkers join Backchannel and interact with your posts.";
static NSString *kFallbackButtonText = @"Got it";

NSString *kdeviceTokenAcceptedKey = @"deviceTokenAccepted";
static NSString *kModalSeenKey = @"modalSeenKey";
static NSString *kCreatePostKey = @"createPostKey";
static NSString *kCommentPushKey = @"commentKey";
static NSString *kVoteKey = @"voteKey";


@implementation BCPushNotificationFlow

- (BOOL)hasUserAcceptedPermission
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceTokenAccepted = (NSString*)[defaults objectForKey:kdeviceTokenAcceptedKey];
    return !!deviceTokenAccepted;
}

- (BOOL)hasUserDeniedPermission
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *modalSeen = (NSString*)[defaults objectForKey:kModalSeenKey];
    return !!modalSeen && ![self hasUserAcceptedPermission];
}

- (void)showPushNotificationDialog
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self showPushNotificationDialog];
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationSystemDialog withParams:nil];
}

- (void)showOnVoteFlow
{
    NSString *title = @"Know when coworkers join your backchannel";
    NSString *message = @"Tap OK when prompted about Push Notifications to know when new coworkers join your backchannel and vote on popular posts.";
    NSString *buttonText = @"Next";
    NSInteger voteCount;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *vote = [defaults objectForKey:kVoteKey];
    if (!vote) {
        voteCount = 0;
    } else {
        voteCount = [vote integerValue];
    }

    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        BOOL isReceivedRemote = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        if (isReceivedRemote || voteCount > 1) {
            [self showPushNotificationDialog];
            return;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types != UIRemoteNotificationTypeNone || voteCount > 1) {
            [self showPushNotificationDialog];
            return;
        }
    }
    
    [defaults setObject:[NSNumber numberWithLong:voteCount + 1] forKey:kVoteKey];
    if (voteCount < 1) {
        return;
    }
    
    if ([self hasUserDeniedPermission]) {
        message = kFallbackMessage;
        buttonText = kFallbackButtonText;
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationVoteFallbackFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    } else {
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationVoteFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    }
    
    [defaults setObject:@"YES" forKey:kModalSeenKey];

    [_alertView show];
}

- (void)showOnCreatePostFlow
{
    NSString *title = @"Know when coworkers comment or vote on your post";
    NSString *message = @"Tap OK when prompted about Push Notifications to know when coworkers interact with posts that you create or comment on.";
    NSString *buttonText = @"Next";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *createKey = [defaults objectForKey:kCreatePostKey];
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        BOOL isReceivedRemote = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        // If user has already given us permission for something either by tapping OK in dialog
        // or from settings. Regardless if we're good to go then no need to show our modal.
        if (isReceivedRemote || createKey) {
            [self showPushNotificationDialog];
            return;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types != UIRemoteNotificationTypeNone || createKey) {
            [self showPushNotificationDialog];
            return;
        }
    }
    
    if ([self hasUserDeniedPermission]) {
        message = kFallbackMessage;
        buttonText = kFallbackButtonText;
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationPostFallbackFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    } else {
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationPostFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    }
    
    [defaults setObject:@"YES" forKey:kModalSeenKey];
    [defaults setObject:@"YES" forKey:kCreatePostKey];
    [_alertView show];
}

- (void)showOnCommentFlow
{
    NSString *title = @"Know when a coworker adds to your comment";
    NSString *message = @"Tap OK when prompted about Push Notifications to know when coworkers interact with posts that you comment on or create.";
    NSString *buttonText = @"Next";

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *commentKey = [defaults objectForKey:kCommentPushKey];

    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        BOOL isReceivedRemote = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        // If user has already given us permission for something either by tapping OK in dialog
        // or from settings. Regardless if we're good to go then no need to show our modal.
        if (isReceivedRemote || commentKey) {
            [self showPushNotificationDialog];
            return;
        }
    } else {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types != UIRemoteNotificationTypeNone || commentKey) {
            [self showPushNotificationDialog];
            return;
        }
    }
    
    if ([self hasUserDeniedPermission]) {
        message = kFallbackMessage;
        buttonText = kFallbackButtonText;
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationCommentFallbackFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    } else {
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationCommentFlow withParams:nil];
        _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    }
    
    [defaults setObject:@"YES" forKey:kCommentPushKey];
    [defaults setObject:@"YES" forKey:kModalSeenKey];
    [_alertView show];
}


@end
