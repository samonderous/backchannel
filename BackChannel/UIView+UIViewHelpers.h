//
//  UIView+UIViewHelpers.h
//  FollowUp
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum Alignment {
    TOP_LEFT,
    TOP_RIGHT,
    CENTER,
    CENTER_LEFT,
    CENTER_RIGTH,
    BOTTOM_LEFT,
    BOTTOM_RIGHT
} Alignment;

@interface UIView (UIViewHelpers)

- (void)placeIn:(UIView*)view alignedAt:(Alignment)alignment;
- (void)placeIn:(UIView*)view alignedAt:(Alignment)alignment withMargin:(float)margin;
- (void)setX:(float)x;
- (void)setY:(float)y;
- (void)setOrigin:(CGPoint)origin;
- (void)setOriginX:(float)x andY:(float)y;
- (void)setWidth:(float)width;
- (void)setHeight:(float)height;
- (void)setSize:(CGSize)size;
- (void)setSizeWidth:(float)width andHeight:(float)height;
- (void)debug;
- (void)debugCenter;

@end
