//
//  BCGlobalsManager.h
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const float kKeyboardHeight;
extern const float kTitleTopMargin;
extern const float kTitleFontSize;
extern NSString *kUdidKey;
extern NSString *kVerifiedKey;
extern NSString *kEmailKey;

@interface BCGlobalsManager : NSObject
@property (strong, nonatomic) UIColor *blueColor;
@property (strong, nonatomic) UIColor *blueBackgroundColor;
@property (strong, nonatomic) UIColor *blackPublishFontColor;
@property (strong, nonatomic) UIColor *blackPublishBackgroundColor;
@property (strong, nonatomic) UIColor *greenColor;
@property (strong, nonatomic) UIColor *creamColor;
@property (strong, nonatomic) UIColor *creamBackgroundColor;
@property (strong, nonatomic) UIColor *greenBackgroundColor;
@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *greenPublishColor;
@property (strong, nonatomic) UIColor *redColor;
@property (strong, nonatomic) UIFont *composeFont;
@property (strong, nonatomic) UIColor *emptyPostCellColor;
@property (strong, nonatomic) UIColor *blackDividerColor;
@property (strong, nonatomic) UIColor *blackTimestampColor;


+ (id)globalsManager;
- (void)loadConfig;

@end
