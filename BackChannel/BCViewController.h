//
//  FUPViewController.h
//  BackChannel
//
//  Created by Saureen Shah on 10/10/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCViewController : NSObject

+ (UIViewController*)setVerifiedAndTransition:(NSString*)udidIN;
+ (UIViewController*)performSegue;
+ (UIViewController*)performSegueOnPushNotification:(NSDictionary*)pushPayload;
@end
