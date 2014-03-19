//
//  BCModels.m
//  BackChannel
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCModels.h"

@interface BCSecretModel ()
@end

@implementation BCSecretModel

- (id)init:(NSString*)text withTime:(float)time withAgrees:(int)agrees withDisagree:(int)disagrees
{
    self = [super init];
    _text = text;
    _time = time;
    _agrees = agrees;
    _disagrees = disagrees;
    _timeStr = [self convertTimeToString];
    _vote = VOTE_NONE;
    return self;
}

- (NSString*)convertTimeToString
{
    return @"12 hrs ago";
}

@end
