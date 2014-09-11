//
//  FUPViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 10/10/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import "BCViewController.h"
#import "BCAppDelegate.h"
#import "BCStreamViewController.h"
#import "BCAuthViewController.h"
#import "BCVerificationViewController.h"
#import "BCGlobalsManager.h"
#import "BCAPIClient.h"

typedef enum TransitionType {
    TRANSITION_AUTH = 1,
    TRANSITION_VERIFY = 2,
    TRANSITION_STREAM = 3
} TransitionType;


@interface BCViewController ()
@end

@implementation BCViewController

+ (UIViewController*)setVerifiedAndTransition:(NSString*)udidIN
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *verified = [defaults objectForKey:kVerifiedKey];
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventAccessLinkClicked withParams:nil];

    if ([verified isEqualToString:@"NO"]) {
        if (![udidIN isEqualToString:[defaults objectForKey:kUdidKey]]) {
            BCAuthViewController *vc = [[BCAuthViewController alloc] init];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:kEmailKey];
            [defaults removeObjectForKey:kUdidKey];
            [defaults removeObjectForKey:kVerifiedKey];
            [defaults synchronize];
            [[BCGlobalsManager globalsManager] logFlurryEvent:kEventAccessLinkClickUdidNotEqual withParams:nil];
            return vc;
        }
        
        [defaults setObject:@"YES" forKey:kVerifiedKey];
        __block BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
        
        SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Verified user success");
            int status = (int)[responseObject[@"status"] integerValue];
            if (status == 1) {
                NSLog(@"Error in creating user on server");
                // TODO: If no user notify user who's waiting on verification page
                BCAuthViewController *avc = [[BCAuthViewController alloc] init];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:kEmailKey];
                [defaults removeObjectForKey:kUdidKey];
                [defaults removeObjectForKey:kVerifiedKey];
                [defaults synchronize];
                [[BCGlobalsManager globalsManager] logFlurryEvent:kEventAccessLinkClickVerifyErrorNoUser withParams:nil];
                [vc presentViewController:avc animated:YES completion:^() {}];
            } else {
                NSString *orgName = (NSString*)responseObject[@"name"];
                NSString *orgDomain = (NSString*)responseObject[@"domain"];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:orgName forKey:kOrgNameKey];
                [defaults setObject:orgDomain forKey:kOrgDomainKey];
                
                BCStreamViewController *sc = [[BCStreamViewController alloc] init];
                sc.title = @"Backchannel";
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:sc];
                sc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [vc presentViewController:nc animated:YES completion:^() {}];
                [[BCGlobalsManager globalsManager] logFlurryEvent:kEventAccessLinkClickVerifySuccess withParams:nil];
            }
        };
        
        FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error in verified user: %@", error);
            NSLog(@"error code %d", (int)operation.response.statusCode);
            
            // TODO: Show generic IE failure screen
        };

        [[BCAPIClient sharedClient] sendVerification:success failure:failure];
        
        // Keep on verified page until we get a success. We want to make sure we have a user.
        return vc;
    } else {
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventAccessLinkClickAlreadyVerified withParams:nil];
        BCAuthViewController *vc = [[BCAuthViewController alloc] init];
        return vc;
    }
}

+ (TransitionType)checkAuth
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *udid = [defaults objectForKey:kUdidKey];
    NSString *verified = [defaults objectForKey:kVerifiedKey];
    
    if (!udid || ![udid isEqualToString:[[UIDevice currentDevice].identifierForVendor UUIDString]] || verified == nil) {
        return TRANSITION_AUTH;
    } else if ([verified isEqualToString:@"NO"]) {
        return TRANSITION_VERIFY;
    } else {
        return TRANSITION_STREAM;
    }
}

+ (UIViewController*)performSegue
{
    TransitionType transition = [BCViewController checkAuth];
    if (transition == TRANSITION_AUTH) {
        BCAuthViewController *vc = [[BCAuthViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        return vc;
    } else if (transition == TRANSITION_VERIFY){
        BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        return vc;
    } else {
        BCStreamViewController *vc = [[BCStreamViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [[BCGlobalsManager globalsManager] logFlurryAllPageViews:nc];
        vc.title = @"Backchannel";
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        return nc;
    }
}

@end
