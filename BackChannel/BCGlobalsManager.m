//
//  BCGlobalsManager.m
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCGlobalsManager.h"

const float kCellHeight = 251.0f;
const float kKeyboardHeight = 216.0;
const float kTitleTopMargin = 30.0;
const float kTitleFontSize = 23.0;
const float kTagLineFont = 15.0;
const float kTitleTaglineSpacing = 5.0;

NSString *kUdidKey = @"udid";
NSString *kVerifiedKey = @"verified";
NSString *kEmailKey = @"email";
NSString *kPublishTutorialKey = @"publishTutorial";
NSString *kStreamTutorialKey = @"streamTutorial";
NSString *kOrgNameKey = @"orgName";
NSString *kOrgDomainKey = @"orgDomain";

NSString *kEventGotItTapped = @"got_it_tapped";
NSString *kEventSkipTapped = @"skip_tapped";
NSString *kEventEnteredStream = @"entered_stream_view";
NSString *kEventNevermindTapped = @"tap_nevermind";
NSString *kEventPublishTapped = @"tap_publish";
NSString *kEventCreatePost = @"tap_to_create";
NSString *kEventVotePlusOne = @"vote_plus_one";
NSString *kEventVoteNegOne = @"vote_neg_one";
NSString *kEventShareCancel = @"share_cancel";
NSString *kEventShareSaved = @"share_saved";
NSString *kEventShareSent = @"share_sent";
NSString *kEventShareFailed = @"share_failed";
NSString *kEventJoinTapped = @"join_tap";
NSString *kEventJoinTappedErrorResponse = @"join_tapped_error_response";
NSString *kEventJoinTappedWhitelistResponse = @"join_tapped_whitelist_response";
NSString *kEventJoinTappedSuccessResponse = @"join_tapped_success_response";
NSString *kEventInviteCancel = @"invite_cancel";
NSString *kEventInviteSaved = @"invite_saved";
NSString *kEventInviteSent = @"invite_sent";
NSString *kEventInviteFailed = @"invite_failed";
NSString *kEventOpenMailTapped = @"openmail_tap";
NSString *kEventResendMailTapped = @"resendmail_tap";
NSString *kEventBackButtonTapFromVerification = @"back_button_tapped_from_verification";
NSString *kEventBackButtonTapFromWaitlist = @"back_button_tapped_from_waitlist";
NSString *kEventVoteNegOneTutorial = @"vote_neg_one_tutorial";
NSString *kEventVotePlusOneTutorial = @"vote_plus_one_tutorial";
NSString *kEventTappedToComments = @"tapped_to_comments";
NSString *kEventTappedCommentField = @"tapped_comment_field";
NSString *kEventPostedComment = @"posted_comment";
NSString *kEventAccessLinkClicked = @"access_link_clicked";
NSString *kEventAccessLinkClickAlreadyVerified = @"access_link_already_verified_back_to_auth";
NSString *kEventAccessLinkClickUdidNotEqual = @"access_link_udid_not_equal_back_to_auth";
NSString *kEventAccessLinkClickVerifyErrorNoUser = @"access_link_verify_server_error";
NSString *kEventAccessLinkClickVerifySuccess = @"access_link_verify_server_success_to_stream_view";





@implementation BCGlobalsManager

+ (id)globalsManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)loadConfig
{
    _blueColor = [UIColor colorWithRed:(41.0/255.0) green:(99.0/255.0) blue:(120.0/255.0) alpha:1.0];
    _blueBackgroundColor = [UIColor colorWithRed:(41.0/255.0) green:(99.0/255.0) blue:(120.0/255.0) alpha:0.10];
    _bluePublishColor = [UIColor colorWithRed:(41.0/255.0) green:(99.0/255.0) blue:(120.0/255.0) alpha:0.40];
    _emptyPostCellColor = [UIColor colorWithRed:(41.0/255.0) green:(99.0/255.0) blue:(120.0/255.0) alpha:0.5];
    _greenColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:1.0];
    _creamColor = [UIColor colorWithRed:(163.0/255.0) green:(161.0/255.0) blue:(121.0/255.0) alpha:1.0];
    _creamBackgroundColor = [UIColor colorWithRed:(163.0/255.0) green:(161.0/255.0) blue:(121.0/255.0) alpha:0.10];
    _creamPublishColor = [UIColor colorWithRed:(163.0/255.0) green:(161.0/255.0) blue:(121.0/255.0) alpha:0.40];
    _greenBackgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.10];
    _fontColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.5];
    _blackPublishFontColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.2];
    _blackPublishBackgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.03];
    _greenPublishColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.40];
    _redColor = [UIColor colorWithRed:(204.0/255.0) green:(76.0/255.0) blue:(69.0/255.0) alpha:1.0];
    _publishTutorialHintColor = [UIColor colorWithRed:(102.0/255.0) green:(102.0/255.0) blue:(102/255.0) alpha:1.0];
    _grayVoteCountColor = [UIColor colorWithRed:(163.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
    
    _composeFont = [UIFont fontWithName:@"Poly" size:18];
    _blackDividerColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    _blackTimestampColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    _blackTaglineColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
}

- (void)logFlurryEvent:(NSString*)eventName withParams:(NSDictionary*)params
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:kEmailKey];
    NSString *udid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSMutableDictionary *defaultparams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"User", email ? email : @"", @"Udid", udid, nil];
    
    if (params) {
        [defaultparams addEntriesFromDictionary:params];
    }
    [Flurry logEvent:eventName withParameters:defaultparams];
}

- (void)logFlurryEventTimed:(NSString*)eventName withParams:(NSDictionary*)params
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:kEmailKey];
    NSString *udid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSMutableDictionary *defaultparams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"User", email ? email : @"", @"Udid", udid, nil];
    if (params) {
        [defaultparams addEntriesFromDictionary:params];
    }
    
    [Flurry logEvent:eventName withParameters:defaultparams timed:YES];
}

- (void)logFlurryEventEndTimed:(NSString*)eventName withParams:(NSDictionary*)params
{
    [Flurry endTimedEvent:eventName withParameters:params];
}

- (void)logFlurryPageView
{
    [Flurry logPageView];
}

- (void)logFlurryAllPageViews:(UINavigationController*)navigationController
{
    [Flurry logAllPageViews:navigationController];
}

@end
