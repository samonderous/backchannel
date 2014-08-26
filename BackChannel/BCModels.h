//
//  BCModels.h
//  BackChannel
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Vote)
{
    VOTE_NONE = 0,
    VOTE_AGREE = 1,
    VOTE_DISAGREE = 2
};


@interface BCSecretModel : NSObject

@property (assign) NSUInteger sid;
@property (strong, nonatomic) NSString *text;
@property (assign) NSInteger time;
@property (assign) NSInteger agrees;
@property (assign) NSInteger disagrees;
@property (strong, nonatomic) NSString *timeStr;
@property (assign) Vote vote;
@property (assign) BOOL isNew;
@property (assign) BOOL isVoted;

- (id)init:(NSString*)text withSid:(NSUInteger)sid withTime:(NSInteger)time withTimeStr:(NSString*)timeStr withAgrees:(NSInteger)agrees withDisagree:(NSInteger)disagrees withVote:(Vote)vote;

@end