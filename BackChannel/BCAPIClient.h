//
//  BCAPIClient.h
//  BackChannel
//
//  Created by Saureen Shah on 3/12/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

#import "BCModels.h"

static NSString *kAPIBaseURL = @"http://ec2-50-19-254-169.compute-1.amazonaws.com:8001/";

typedef  void (^SuccessCallback)(AFHTTPRequestOperation *operation, id responseObject);
typedef  void (^FailureCallback)(AFHTTPRequestOperation *operation, NSError *error);

@interface BCAPIClient : AFHTTPRequestOperationManager

+ (id)sharedClient;

- (void)sendAuth:(NSString*)email success:(SuccessCallback)success failure:(FailureCallback)failure;
- (void)getStream:(SuccessCallback)success failure:(FailureCallback)failure;
- (void)setVote:(BCSecretModel*)model success:(SuccessCallback)success failure:(FailureCallback)failure;
- (void)sendVerificationEmail:(SuccessCallback)success failure:(FailureCallback)failure;

@end
