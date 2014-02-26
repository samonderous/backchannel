//
//  FUPUtil.h
//  FollowUp
//
//  Created by Saureen Shah on 10/22/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FUPUtil : NSObject

+ (NSMutableAttributedString*)getAttributedString:(NSString*)inputText withFontSize:(float)fontSize withBoldFont:(BOOL)isBold;
+ (CGSize)calculateTextBoundsSize:(NSString*)inputText withFontSize:(float)fontSize withTargetWidth:(float)targetWidth withBoldFont:(BOOL)isBold;
+ (void)debugRect:(UIView*)view withName:(NSString*)name;
+ (void)debugRectWithRect:(CGRect)rect withName:(NSString*)name;

@end
