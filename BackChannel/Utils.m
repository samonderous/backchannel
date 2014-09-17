//
//  FUPUtil.m
//  FollowUp
//
//  Created by Saureen Shah on 10/22/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <CoreText/CTFrameSetter.h>
#import <QuartzCore/QuartzCore.h>

#import "Utils.h"
#import "TTTAttributedLabel.h"

@implementation Utils

+ (NSMutableAttributedString*)getAttributedString:(NSString*)inputText withFontSize:(float)fontSize withBoldFont:(BOOL)isBold
{
    if(!inputText) {
        return nil;
    }
    
    NSMutableAttributedString *attrInputText = [[NSMutableAttributedString alloc] initWithString:inputText];
    if(isBold) {
        [attrInputText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:NSMakeRange(0, inputText.length)];
    } else {
        [attrInputText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, inputText.length)];
    }
    return attrInputText;
}

+ (CGSize)calculateTextBoundsSize:(NSString*)inputText withFontSize:(float)fontSize withTargetWidth:(float)targetWidth withBoldFont:(BOOL)isBold
{
    NSMutableAttributedString *attrInputText = [Utils getAttributedString:inputText withFontSize:fontSize withBoldFont:isBold];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrInputText);
    CGSize targetSize = CGSizeMake(targetWidth, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attrInputText length]), NULL, targetSize, NULL);
    CFRelease(framesetter);
    return fitSize;
}

+ (void)debugRect:(UIView*)view withName:(NSString*)name
{
    NSLog(@"%@ Frame: x=%f, y=%f, h=%f, w=%f", name ? name : @"", view.frame.origin.x, view.frame.origin.y, view.frame.size.height, view.frame.size.width);
    NSLog(@"%@ Bounds: x=%f, y=%f, h=%f, w=%f", name ? name : @"", view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.height, view.bounds.size.width);
}

+ (void)debugRectWithRect:(CGRect)rect withName:(NSString*)name
{
    NSLog(@"%@ Rect: x=%f, y=%f, h=%f, w=%f", name ? name : @"", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

+ (NSString*)deviceTokenToString:(NSData*)deviceToken {
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hexToken;
}


@end
