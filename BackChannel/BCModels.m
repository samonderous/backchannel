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

- (id)init:(NSString*)text withSid:(NSUInteger)sid withTime:(NSInteger)time withTimeStr:(NSString*)timeStr withAgrees:(NSInteger)agrees withDisagree:(NSInteger)disagrees withVote:(Vote)vote
{
    self = [super init];
    _sid = sid;
    _text = text;
    _time = time;
    _agrees = agrees;
    _disagrees = disagrees;
    _timeStr = timeStr;
    _vote = vote;
    _isNew = NO;
    
    return self;
}

@end

@interface BCOrgModel ()

@end

@implementation BCOrgModel

- (id)init:(NSString*)name withDomain:(NSString*)domain
{
    self = [super init];
    _name = name;
    _domain = domain;
    
    return self;
}

@end