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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(performSegue) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (UIViewController*)setVerifiedAndTransition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *verified = [defaults objectForKey:kVerifiedKey];
    
    if ([verified isEqualToString:@"NO"]) {
        [defaults setObject:@"YES" forKey:kVerifiedKey];
        
        __block BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
        
        SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Verified user success");
            int status = (int)[responseObject[@"status"] integerValue];
            if (status == 1) {
                NSLog(@"Error in creating user on server");
                // TODO: If no user notify user who's waiting on verification page
                
            } else {
                BCStreamViewController *sc = [[BCStreamViewController alloc] init];
                sc.title = @"Backchannel";
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:sc];
                sc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [vc presentViewController:nc animated:YES completion:^() {}];
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
    } else if (NO) {
        // TODO: Case when someone auth'd but need to check if my UDID == UDID from email link
        // This protects from case where I auth, but forward my email to someone else who has auth'd
        // but is going to verify using my link.
        //
        // Keep on verify page
        BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
        return vc;
    } else {
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

- (void)performSegue
{
    TransitionType transition = [BCViewController checkAuth];
    if (transition == TRANSITION_AUTH) {
        BCAuthViewController *vc = [[BCAuthViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:vc animated:YES completion:^() {}];
    } else if (transition == TRANSITION_VERIFY){
        BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:vc animated:YES completion:^() {}];
        
    } else if (transition == TRANSITION_STREAM) {
        BCStreamViewController *vc = [[BCStreamViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.title = @"Backchannel";
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:nc animated:YES completion:^() {}];
    }
}

@end
