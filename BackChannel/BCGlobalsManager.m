//
//  BCGlobalsManager.m
//  BackChannel
//
//  Created by Saureen Shah on 3/3/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCGlobalsManager.h"

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
    _greenColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:1.0];
    _creamColor = [UIColor colorWithRed:(189.0/255.0) green:(187.0/255.0) blue:(159.0/255.0) alpha:1.0];
    _creamBackgroundColor = [UIColor colorWithRed:(189.0/255.0) green:(187.0/255.0) blue:(159.0/255.0) alpha:0.05];
    _greenBackgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.05];
    _fontColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.2];
}

@end
