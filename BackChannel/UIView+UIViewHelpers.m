//
//  UIView+UIViewHelpers.m
//  FollowUp
//
//  Created by Saureen Shah on 1/15/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "Utils.h"
#import "UIView+UIViewHelpers.h"

@implementation UIView (UIViewHelpers)


- (void)placeIn:(UIView*)view alignedAt:(Alignment)alignment
{
    [self placeIn:view alignedAt:alignment withMargin:0.0];
}

- (void)placeIn:(UIView*)view alignedAt:(Alignment)alignment withMargin:(float)margin
{
    switch (alignment) {
        case CENTER:
        {
            self.center = CGPointMake(view.bounds.size.width / 2.0, view.bounds.size.height / 2.0);
            break;
        }
        case CENTER_LEFT:
        {
            self.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
            [self setX:margin];
            break;
        }
        case CENTER_RIGTH:
        {
            self.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
            [self setX:CGRectGetMaxX(view.bounds) - CGRectGetWidth(self.bounds) - margin];
            break;
        }
        case TOP_LEFT:
        {
            CGRect selfFrame = self.frame;
            selfFrame.origin = CGPointMake(margin, margin);
            self.frame = selfFrame;
            break;
        }
        case TOP_RIGHT:
        {
            CGRect selfFrame = self.frame;
            selfFrame.origin = CGPointMake(CGRectGetMaxX(view.bounds) - CGRectGetWidth(self.bounds) - margin, margin);
            self.frame = selfFrame;
            break;
        }
        case BOTTOM_LEFT:
        {
            CGRect selfFrame = self.frame;
            selfFrame.origin = CGPointMake(margin, CGRectGetMaxY(view.bounds) - CGRectGetHeight(self.bounds) - margin);
            self.frame = selfFrame;
            break;
        }
        case BOTTOM_RIGHT:
        {
            CGRect selfFrame = self.frame;
            selfFrame.origin = CGPointMake(CGRectGetMaxY(view.bounds) - CGRectGetHeight(self.bounds) - margin,
                                           CGRectGetMaxY(view.bounds) - CGRectGetHeight(self.bounds) - margin);
            self.frame = selfFrame;
            break;
        }
        case BOTTOM:
        {
            CGRect selfFrame = self.frame;
            selfFrame.origin = CGPointMake((CGRectGetWidth(view.bounds) - CGRectGetWidth(self.bounds)) / 2.0, CGRectGetHeight(view.bounds) - CGRectGetHeight(self.bounds));
            self.frame = selfFrame;
            break;
        }
        default:
            break;
    }
}

- (void)setX:(float)x
{
    CGRect selfFrame = self.frame;
    selfFrame.origin.x = x;
    self.frame = selfFrame;
}

- (void)setY:(float)y
{
    CGRect selfFrame = self.frame;
    selfFrame.origin.y = y;
    self.frame = selfFrame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect selfFrame = self.frame;
    selfFrame.origin = origin;
    self.frame = selfFrame;
}

- (void)setOriginX:(float)x andY:(float)y
{
    [self setX:x];
    [self setY:y];
}

- (void)setWidth:(float)width
{
    CGRect selfFrame = self.frame;
    selfFrame.size.width = width;
    self.frame = selfFrame;
}

- (void)setHeight:(float)height
{
    CGRect selfFrame = self.frame;
    selfFrame.size.height = height;
    self.frame = selfFrame;
}

- (void)setSize:(CGSize)size
{
    CGRect selfFrame = self.frame;
    selfFrame.size = size;
    self.frame = selfFrame;
}

- (void)setSizeWidth:(float)width andHeight:(float)height;
{
    [self setWidth:width];
    [self setHeight:height];
}

- (void)debug
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)debugCenter
{
    CALayer *circle = [[CALayer alloc] init];
    circle.frame = CGRectMake(0.0, 0.0, 5.0, 5.0);
    CGRect frame = circle.frame;
    frame.origin = (CGPoint){(CGRectGetWidth(self.bounds) - CGRectGetWidth(circle.bounds)) / 2.0, (CGRectGetHeight(self.bounds) - CGRectGetHeight(circle.bounds)) / 2.0};
    circle.frame = frame;
    circle.cornerRadius = CGRectGetWidth(circle.frame) / 2.0;
    circle.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:circle];
    
}

@end
