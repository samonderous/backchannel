//
//  BCAppDelegate.m
//  BackChannel
//
//  Created by Saureen Shah on 2/18/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

#import "BCAppDelegate.h"
#import "BCGlobalsManager.h"
#import "BCViewController.h"
#import "BCStreamViewController.h"
#import "BCWaitingViewController.h"
#import "BCAPIClient.h"
#import "BCPushNotificationFlow.h"

#import "Utils.h"
#import "AFNetworkActivityLogger.h"

@implementation BCAppDelegate

+ (BCAppDelegate*)sharedAppDelegate
{
    return (BCAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSDictionary *parsedQueryDict = [self parseQueryString:[url query]];
    UIViewController *vc = [BCViewController setVerifiedAndTransition:parsedQueryDict[@"u"]];
    self.window.rootViewController = vc;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //[[Crashlytics sharedInstance] setDebugMode:YES];
    [Crashlytics startWithAPIKey:@"f59d6a71a710bdff855cd287d71b64b426d0e957"];
    
    //[Flurry setCrashReportingEnabled:YES];
    #if !TARGET_IPHONE_SIMULATOR
    //[Flurry startSession:@"MWV2G8ZG3JTK75ZPRNMC"];
    #endif
    
    [[BCGlobalsManager globalsManager] loadConfig];
    //[[AFNetworkActivityLogger sharedLogger] startLogging];

    // Override point for customization after application launch.
    
    self.window.rootViewController = [BCViewController performSegue];
    [self.window makeKeyAndVisible];
    
    _pushFlow = [[BCPushNotificationFlow alloc] init];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notificationPayload) {
        NSLog(@"got a notification payload");
        UIViewController *vc = [BCViewController performSegueOnPushNotification:notificationPayload];
        self.window.rootViewController = vc;
    }
    
    // Scenario where user went to settings, allowed push. Launch dialog flow so delegate gets called
    // to write device token to server.
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types != UIRemoteNotificationTypeNone) {
        [_pushFlow showPushNotificationDialog];
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationDeviceTokenFromDelegates withParams:nil];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(application.applicationState == UIApplicationStateInactive)
    {
        NSDictionary *params = [[NSDictionary alloc] init];
        NSString *pushType = [userInfo valueForKey:@"push_type"];
        if (pushType) {
            [params setValue:pushType forKey:@"push_type"];
            [params setValue:@"active" forKey:@"app_state"];
        }
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationPayload withParams:params];
        UIViewController *vc = [BCViewController performSegueOnPushNotification:userInfo];
        self.window.rootViewController = vc;
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Succeeded in registering with APN");
    
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"device token success");
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in vote: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES" forKey:kdeviceTokenAcceptedKey];
    [[BCAPIClient sharedClient] setDeviceToken:success failure:failure withToken:[Utils deviceTokenToString:deviceToken]];
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationDeviceToken withParams:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to reigster with APN %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"Came into will enter fg");
    // Scenario where user went to settings, allowed push. App is in bg and WILL NOT call viewWillAppear
    // or call didFinishLaunching... delegate. So write out device token to server.
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (types != UIRemoteNotificationTypeNone) {
        [_pushFlow showPushNotificationDialog];
        [[BCGlobalsManager globalsManager] logFlurryEvent:kEventNotificationDeviceTokenFromDelegates withParams:nil];
    }
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventBackgroundToForeground withParams:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
