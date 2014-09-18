//
//  BCAppDelegate.h
//  BackChannel
//
//  Created by Saureen Shah on 2/18/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPushNotificationFlow.h"

@interface BCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BCPushNotificationFlow *pushFlow;

+ (BCAppDelegate*)sharedAppDelegate;

@end
