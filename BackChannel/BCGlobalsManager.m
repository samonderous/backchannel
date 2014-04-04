//
//  BCGlobalsManager.m
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCGlobalsManager.h"

const float kKeyboardHeight = 216.0;
const float kTitleTopMargin = 30.0;
const float kTitleFontSize = 23.0;
const float kTagLineFont = 15.0;
const float kTitleTaglineSpacing = 5.0;

NSString *kUdidKey = @"udid";
NSString *kVerifiedKey = @"verified";
NSString *kEmailKey = @"email";

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
    _emptyPostCellColor = [UIColor colorWithRed:(41.0/255.0) green:(99.0/255.0) blue:(120.0/255.0) alpha:0.4];
    _greenColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:1.0];
    _creamColor = [UIColor colorWithRed:(163.0/255.0) green:(161.0/255.0) blue:(121.0/255.0) alpha:1.0];
    _creamBackgroundColor = [UIColor colorWithRed:(163.0/255.0) green:(161.0/255.0) blue:(121.0/255.0) alpha:0.10];
    _greenBackgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.10];
    _fontColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.5];
    _blackPublishFontColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.2];
    _blackPublishBackgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.03];
    _greenPublishColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.40];
    _redColor = [UIColor colorWithRed:(204.0/255.0) green:(76.0/255.0) blue:(69.9/255.0) alpha:1.0];
    
    _composeFont = [UIFont fontWithName:@"Tisa Pro" size:18];
    _blackDividerColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    _blackTimestampColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    _blackTaglineColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
}

- (void)logFlurryEvent:(NSString*)eventName withParams:(NSDictionary*)params
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:kEmailKey];
    NSDictionary *defaultparams = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"User", email ? email : @"", nil];
    
    [Flurry logEvent:eventName withParameters:defaultparams];
}

- (void)logFlurryEventTimed:(NSString*)eventName withParams:(NSDictionary*)params
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:kEmailKey];
    NSDictionary *defaultparams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"User", email ? email : @"", nil];
    
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
