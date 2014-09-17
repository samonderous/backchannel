//
//  BCPushNotificationFlow.h
//  BackChannel
//
//  Created by Saureen Shah on 9/16/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kdeviceTokenAcceptedKey;

@interface BCPushNotificationFlow : NSObject<UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *alertView;

- (void)showOnCommentFlow;
- (void)showOnCreatePostFlow;
@end
