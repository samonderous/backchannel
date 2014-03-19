//
//  BCAPIClient.m
//  BackChannel
//
//  Created by Saureen Shah on 3/12/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCAPIClient.h"
#import "BCGlobalsManager.h"


static NSString *kAuthPath = @"backend/auth/";
static NSString *kVotePath = @"backend/vote/";
static NSString *kStreamPath = @"backend/stream/";
static NSString *kResendemailPath = @"backend/resendemail/";


@implementation BCAPIClient

+ (id)sharedClient
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURL]];
        
        // NOTE: Adding this to handle JSON fragments, otherwise server has to respond with
        // well-formed {} or [] json strings.
        AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
        serializer.readingOptions = NSJSONReadingAllowFragments;
        [_sharedObject setResponseSerializer:serializer];
    });
    return _sharedObject;
}

- (void)sendAuth:(NSString*)email success:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSDictionary *params = @{@"email": email,
                             @"udid": [[UIDevice currentDevice].identifierForVendor UUIDString]};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [[BCAPIClient sharedClient] POST:kAuthPath parameters:parameters success:success failure:failure];
}

- (void)getStream:(SuccessCallback)success failure:(FailureCallback)failure;
{
    
}

- (void)setVote:(BCSecretModel*)model success:(SuccessCallback)success failure:(FailureCallback)failure
{

}

- (void)sendVerificationEmail:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = (NSString*)[defaults objectForKey:kEmailKey];
    NSDictionary *params = @{@"email": email};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [[BCAPIClient sharedClient] GET:kResendemailPath parameters:parameters success:success failure:failure];
}

@end
