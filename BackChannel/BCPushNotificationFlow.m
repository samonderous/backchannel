//
//  BCPushNotificationFlow.m
//  BackChannel
//
//  Created by Saureen Shah on 9/16/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCPushNotificationFlow.h"

static NSString *kFallbackMessage = @"Go to Settings > Notifications and enable Backchannel to notify you when your coworkers join Backchannel and interact with your posts.";
static NSString *kFallbackButtonText = @"Got it";

NSString *kdeviceTokenAcceptedKey = @"deviceTokenAccepted";
static NSString *kModalSeenKey = @"modalSeenKey";
static NSString *kCreatePostKey = @"createPostKey";
static NSString *kCommentPushKey = @"commentKey";


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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self showPushNotificationDialog];
}

- (void)showOnCreatePostFlow
{
    NSString *title = @"Know when coworkers comment or vote on your post";
    NSString *message = @"Tap OK when prompted about Push Notifications to know when coworkers interact with posts that you create or comment on.";
    NSString *buttonText = @"Next";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *createKey = [defaults objectForKey:kCreatePostKey];
    
    
    // If user has already given us permission for something either by tapping OK in dialog
    // or from settings. Regardless if we're good to go then no need to show our modal.
    if (types != UIRemoteNotificationTypeNone || createKey) {
        [self showPushNotificationDialog];
        return;
    }
    
    if ([self hasUserDeniedPermission]) {
        message = kFallbackMessage;
        buttonText = kFallbackButtonText;
    }
    
    [defaults setObject:@"YES" forKey:kModalSeenKey];
    [defaults setObject:@"YES" forKey:kCreatePostKey];
    _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    [_alertView show];
}

- (void)showOnCommentFlow
{
    NSString *title = @"Know when a coworker replies to you";
    NSString *message = @"Tap OK when prompted about Push Notifications to know when coworkers interact with posts that you comment on or create.";
    NSString *buttonText = @"Next";

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *commentKey = [defaults objectForKey:kCommentPushKey];

    if (types != UIRemoteNotificationTypeNone || commentKey) {
        [self showPushNotificationDialog];
        return;
    }
    
    if ([self hasUserDeniedPermission]) {
        message = kFallbackMessage;
        buttonText = kFallbackButtonText;
    }
    
    [defaults setObject:@"YES" forKey:kCommentPushKey];
    [defaults setObject:@"YES" forKey:kModalSeenKey];
    _alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil, nil];
    [_alertView show];
}


@end
