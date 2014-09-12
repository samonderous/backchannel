//
//  BCGlobalsManager.h
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Flurry.h"
#import "BCModels.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

extern const float kKeyboardHeight;
extern const float kTitleTopMargin;
extern const float kTitleFontSize;
extern const float kTagLineFont;
extern const float kTitleTaglineSpacing;

extern NSString *kUdidKey;
extern NSString *kVerifiedKey;
extern NSString *kEmailKey;
extern NSString *kPublishTutorialKey;
extern NSString *kStreamTutorialKey;
extern NSString *kOrgNameKey;
extern NSString *kOrgDomainKey;

extern NSString *kEventJoinTapped;
extern NSString *kEventGotItTapped;
extern NSString *kEventEnteredStream;
extern NSString *kEventNevermindTapped;
extern NSString *kEventPublishTapped;
extern NSString *kEventCreatePost;
extern NSString *kEventVotePlusOne;
extern NSString *kEventVoteNegOne;
extern NSString *kEventShareCancel;
extern NSString *kEventShareSaved;
extern NSString *kEventShareSent;
extern NSString *kEventShareFailed;
extern NSString *kEventInviteCancel;
extern NSString *kEventInviteSaved;
extern NSString *kEventInviteSent;
extern NSString *kEventInviteFailed;
extern NSString *kEventOpenMailTapped;
extern NSString *kEventResendMailTapped;
extern NSString *kEventBackButtonTapFromVerification;
extern NSString *kEventBackButtonTapFromWaitlist;

@interface BCGlobalsManager : NSObject

@property (strong, nonatomic) UIColor *blueColor;
@property (strong, nonatomic) UIColor *blueBackgroundColor;
@property (strong, nonatomic) UIColor *bluePublishColor;

@property (strong, nonatomic) UIColor *blackPublishFontColor;
@property (strong, nonatomic) UIColor *blackPublishBackgroundColor;
@property (strong, nonatomic) UIColor *blackDividerColor;
@property (strong, nonatomic) UIColor *blackTimestampColor;
@property (strong, nonatomic) UIColor *blackTaglineColor;

@property (strong, nonatomic) UIColor *greenColor;
@property (strong, nonatomic) UIColor *greenBackgroundColor;
@property (strong, nonatomic) UIColor *greenPublishColor;

@property (strong, nonatomic) UIColor *creamColor;
@property (strong, nonatomic) UIColor *creamBackgroundColor;
@property (strong, nonatomic) UIColor *creamPublishColor;

@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *redColor;
@property (strong, nonatomic) UIFont *composeFont;
@property (strong, nonatomic) UIColor *emptyPostCellColor;

@property (strong, nonatomic) UIColor *publishTutorialHintColor;

+ (id)globalsManager;
- (void)loadConfig;
- (void)logFlurryEvent:(NSString*)eventName withParams:(NSDictionary*)params;
- (void)logFlurryEventTimed:(NSString*)eventName withParams:(NSDictionary*)params;
- (void)logFlurryEventEndTimed:(NSString*)eventName withParams:(NSDictionary*)params;
- (void)logFlurryPageView;
- (void)logFlurryAllPageViews:(UINavigationController*)navigationController;

@end
