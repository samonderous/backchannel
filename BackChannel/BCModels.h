//
//  FUPModels.h
//  FollowUp
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kFileTypes  @{@1: @"folder.png",    \
                    @2: @"word.png",        \
                    @3: @"excel.png",       \
                    @4: @"ppt.png",         \
                    @5: @"numbers.png"}

@interface FUPEmailModel : NSObject

- (NSString*)getParticipantsAsString;

@property (strong, nonatomic) NSMutableArray *participants;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *body;
@property (assign) BOOL isExpanded;

@end

@interface FUPObjectModel : NSObject
@property (strong, nonatomic) NSString *name;
@end

@interface FUPThreadModel : FUPObjectModel
- (NSString*)getParticipantsString;
- (NSString*)getEmailBody;
- (void)markRead;

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSMutableArray *emails;
@property (assign) NSInteger emailCount;
@property (assign) BOOL isRead;

@end

@interface FUPContactModel : FUPObjectModel
@property (assign) NSInteger uid;
@property (strong, nonatomic) NSString *photoName;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *username;
@end

@interface FUPFileModel : FUPObjectModel
@property (assign) int fid;
@property (strong, nonatomic) NSString *fileModifiedDate;
@end

@interface FUPCalendarModel : FUPObjectModel
@end


@interface FUPMessageModel : FUPObjectModel
@property (strong, nonatomic) FUPContactModel *contact;
@property (assign) NSString *lastChatMessage;
@end


//*** Action Heads ***//
@interface FUPActionHead : NSObject
- (id)initWithModel:(FUPObjectModel*)model withDisplayName:(NSString*)displayName withHeadImage:(UIImage*)headImage;
- (NSString*)getDisplayName;
- (FUPObjectModel*)getModel;
- (UIImage*)getHeadImage;
@end

@interface FUPFileHead : FUPActionHead
@end

@interface FUPCalendarHead : FUPActionHead
@end

@interface FUPThreadHead : FUPActionHead
@end

@interface FUPChatHead : FUPActionHead
@end
