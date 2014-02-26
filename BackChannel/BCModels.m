//
//  FUPModels.m
//  FollowUp
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "FUPModels.h"

@implementation FUPObjectModel
@end

@implementation FUPEmailModel

- (NSString*)getParticipantsAsString
{
    NSMutableString *participantsJoined = [[NSMutableString alloc] init];
    for(int i=0; i < _participants.count; i++) {
        if (i==0) {
            [participantsJoined appendString:((FUPContactModel*)[_participants objectAtIndex:i]).name];
        } else {
            NSMutableString *prefixAdded = [[NSMutableString alloc] init];
            [prefixAdded appendString:@" & "];
            [prefixAdded appendString:((FUPContactModel*)[_participants objectAtIndex:i]).name];
            [participantsJoined appendString:prefixAdded];
        }
    }
    return participantsJoined;
}

- (FUPEmailModel*)init
{
    self = [super init];
    _isExpanded = NO;
    _participants = [[NSMutableArray alloc] init];
    return self;
}

@end

@implementation FUPThreadModel

- (FUPThreadModel*)init
{
    self = [super init];
    _isRead = NO;
    _emails = [[NSMutableArray alloc] init];
    return self;
}

- (void)markRead
{
    _isRead = YES;
}

- (NSString*)getParticipantsString
{
    FUPEmailModel *lastEmail = [_emails lastObject];
    if(!lastEmail) {
        return @"<no participants>";
    }
    return [lastEmail getParticipantsAsString];
}

- (NSString*)getEmailBody
{
    FUPEmailModel *lastEmail = [_emails lastObject];
    if(!lastEmail) {
        return @"";
    }
    return lastEmail.body;
}
@end

@implementation FUPCalendarModel
@end

@implementation FUPContactModel
@end

@implementation FUPFileModel
@end

@implementation FUPMessageModel
@end


// Action Heads
@interface FUPActionHead ()
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) FUPObjectModel *model;
@property (strong, nonatomic) UIImage *headImage;
@end

@implementation FUPActionHead

- (id)initWithModel:(FUPObjectModel*)model withDisplayName:(NSString*)displayName withHeadImage:(UIImage*)headImage
{
    self = [super init];
    _displayName = displayName;
    _model = model;
    _headImage = headImage;
    
    return self;
}

- (NSString*)getDisplayName
{
    return _displayName;
}

- (FUPObjectModel*)getModel
{
    return _model;
}

- (UIImage*)getHeadImage
{
    return _headImage;
}

@end


@interface FUPFileHead ()
@end

@implementation FUPFileHead

- (id)initWithModel:(FUPObjectModel*)model withDisplayName:(NSString*)displayName withHeadImage:(UIImage*)headImage
{
    self = [super initWithModel:model withDisplayName:displayName withHeadImage:headImage];
    self.headImage = [UIImage imageNamed:[kFileTypes objectForKey:[NSNumber numberWithInt:((FUPFileModel*)model).fid]]];
    return self;
}
@end

@interface FUPCalendarHead ()
@end

@implementation FUPCalendarHead
- (id)initWithModel:(FUPObjectModel*)model withDisplayName:(NSString*)displayName withHeadImage:(UIImage*)headImage
{
    self = [super initWithModel:model withDisplayName:displayName withHeadImage:headImage];
    if (!headImage) {
        self.headImage = [UIImage imageNamed:@"calendar.png"];
    }
    return self;
}
@end

@interface FUPThreadHead ()
@end

@implementation FUPThreadHead
@end

@interface FUPChatHead ()
@end

@implementation FUPChatHead
@end