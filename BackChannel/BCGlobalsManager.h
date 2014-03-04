//
//  BCGlobalsManager.h
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCGlobalsManager : NSObject
@property (strong, nonatomic) UIColor *blueColor;
@property (strong, nonatomic) UIColor *greenColor;
@property (strong, nonatomic) UIColor *creamColor;
@property (strong, nonatomic) UIColor *creamBackgroundColor;
@property (strong, nonatomic) UIColor *greenBackgroundColor;
@property (strong, nonatomic) UIColor *fontColor;

+ (id)globalsManager;
- (void)loadConfig;

@end
