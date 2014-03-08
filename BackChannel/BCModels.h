//
//  FUPModels.h
//  BackChannel
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum Vote {
    VOTE_NONE = 0,
    VOTE_AGREE,
    VOTE_DISAGREE
} Vote;
@interface BCSecretModel : NSObject

@property (strong, nonatomic) NSString *text;
@property (assign) NSInteger time;
@property (assign) int agrees;
@property (assign) int disagrees;
@property (strong, nonatomic) NSString *timeStr;
@property (assign) Vote vote;

- (id)init:(NSString*)text withTime:(float)time withAgrees:(int)agrees withDisagree:(int)disagrees;
@end