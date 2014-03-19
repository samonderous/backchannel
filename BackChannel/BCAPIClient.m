//
//  BCAPIClient.m
//  BackChannel
//
//  Created by Saureen Shah on 3/12/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCAPIClient.h"

static NSString *kAuthUrl = @"backend/auth";

@implementation BCAPIClient

+ (id)sharedClient
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
    });
    return _sharedObject;
}

- (void)sendAuth:(NSString*)email success:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"email": email}];
    [[BCAPIClient sharedClient] POST:kAuthUrl parameters:parameters success:success failure:failure];
}

- (void)getStream:(SuccessCallback)success failure:(FailureCallback)failure;
{

}

- (void)setVote:(BCSecretModel*)model success:(SuccessCallback)success failure:(FailureCallback)failure
{

}

- (void)sendVerificationEmail:(SuccessCallback)success failure:(FailureCallback)failure
{

}

@end
