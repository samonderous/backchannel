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
static NSString *kCreatePostPath = @"backend/createsecret/";
static NSString *kVerificationPath = @"backend/verify/";
static NSString *kLatestPostsPath = @"backend/getlatestposts/";
static NSString *kOlderPostsPath = @"backend/getolderposts/";
static NSString *kCommentsPath = @"backend/comments/";
static NSString *kCommentCreatePath = @"backend/createcomment/";
static NSString *kSetDeviceTokenPath = @"backend/setdevicetoken/";

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
    [[BCAPIClient sharedClient] POST:kAuthPath parameters:params success:success failure:failure];
}

- (void)createSecret:(NSString*)text success:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSDictionary *params = @{@"udid": [[UIDevice currentDevice].identifierForVendor UUIDString],
                             @"text": text};
    [[BCAPIClient sharedClient] POST:kCreatePostPath parameters:params success:success failure:failure];
}

- (void)fetchSecrets:(NSString*)path success:(void (^)(NSMutableArray*))success failure:(FailureCallback)failure withParams:(NSDictionary*)params
{
    [[BCAPIClient sharedClient] GET:path
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSMutableArray *secrets = [[NSMutableArray alloc] init];
                                //NSLog(@"%@", responseObject);
                                for (NSDictionary *secret in responseObject[@"secrets"]) {
                                    BCSecretModel *secretModel = [[BCSecretModel alloc] init:secret[@"secrettext"]
                                                                                     withSid:[((NSString*)secret[@"sid"]) integerValue]
                                                                                    withTime:(NSInteger)secret[@"time"]
                                                                                 withTimeStr:(NSString*)secret[@"time_ago"]
                                                                                  withAgrees:[((NSString*)secret[@"agrees"]) integerValue]
                                                                                withDisagree:[((NSString*)secret[@"disagrees"]) integerValue]
                                                                                    withVote:[((NSString*)secret[@"vote"]) integerValue]
                                                                                    withCommentCount:
                                                                            [((NSString*)secret[@"comment_count"]) integerValue]];
                                    [secrets addObject:secretModel];
                                }
                                success(secrets);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                
                                failure(operation, error);
                            }];
}

- (void)getLatestPosts:(void (^)(NSMutableArray*))success failure:(FailureCallback)failure withForTutorial:(BOOL)isForTutorial
{
    NSDictionary *params = @{@"udid": [[UIDevice currentDevice].identifierForVendor UUIDString],
                             @"ist": [NSNumber numberWithBool:isForTutorial]};
    [self fetchSecrets:kLatestPostsPath success:success failure:failure withParams:params];
}

- (void)getOlderPosts:(void (^)(NSMutableArray*))success failure:(FailureCallback)failure withLastSid:(int)lastSid
{
    NSDictionary *params = @{@"udid": [[UIDevice currentDevice].identifierForVendor UUIDString],
                             @"lsid": [NSString stringWithFormat:@"%d", lastSid]};
    [self fetchSecrets:kOlderPostsPath success:success failure:failure withParams:params];
}

- (void)setVote:(BCSecretModel*)model withVote:(NSInteger)vote success:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:(NSString*)[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"udid"];
    [params setObject:[NSNumber numberWithInteger:model.sid] forKey:@"sid"];
    [params setObject:vote == VOTE_AGREE ? @"agree" : @"disagree" forKey:@"vote"];

    [[BCAPIClient sharedClient] POST:kVotePath parameters:params success:success failure:failure];
}

- (void)sendVerificationEmail:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = (NSString*)[defaults objectForKey:kEmailKey];
    NSDictionary *params = @{@"email": email, @"udid": [[UIDevice currentDevice].identifierForVendor UUIDString]};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:params];
    [[BCAPIClient sharedClient] GET:kResendemailPath parameters:parameters success:success failure:failure];
}

- (void)sendVerification:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *params = @{@"udid": [[UIDevice currentDevice].identifierForVendor UUIDString],
                             @"email": [defaults objectForKey:kEmailKey]};
    [[BCAPIClient sharedClient] POST:kVerificationPath parameters:params success:success failure:failure];
}

- (void)createComment:(NSString*)text onSecret:(BCSecretModel*)model success:(SuccessCallback)success failure:(FailureCallback)failure
{
    NSDictionary *params = @{@"udid": [[UIDevice currentDevice].identifierForVendor UUIDString],
                             @"text": text,
                             @"sid": [NSNumber numberWithInteger:model.sid]};
    [[BCAPIClient sharedClient] POST:kCommentCreatePath parameters:params success:success failure:failure];
}

- (void)fetchCommentsFor:(BCSecretModel*)model success:(void (^)(NSMutableArray*))success failure:(FailureCallback)failure
{
    [[BCAPIClient sharedClient] GET:kCommentsPath
                         parameters:@{@"sid": [NSNumber numberWithInteger:model.sid]}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSMutableArray *comments = [[NSMutableArray alloc] init];
                                for (NSDictionary *comment in responseObject[@"comments"]) {
                                    BCCommentModel *commentModel = [[BCCommentModel alloc] init:comment[@"text"]];
                                    [comments addObject:commentModel];
                                }
                                success(comments);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                
                                failure(operation, error);
                            }];
}

- (void)setDeviceToken:(SuccessCallback)success failure:(FailureCallback)failure withToken:(NSString*)token
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:(NSString*)[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:@"udid"];
    [params setObject:token forKey:@"token"];
    
    [[BCAPIClient sharedClient] POST:kSetDeviceTokenPath parameters:params success:success failure:failure];
}


@end
