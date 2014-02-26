//
//  FUPModels.h
//  FollowUp
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCSecretModel : NSObject

@property (strong, nonatomic) NSString *text;
@property (assign) NSInteger time;
@property (assign) int agrees;
@property (assign) int disagrees;
@property (strong, nonatomic) NSString *timeStr;

- (id)init:(NSString*)text withTime:(float)time withAgrees:(int)agrees withDisagree:(int)disagrees;
@end