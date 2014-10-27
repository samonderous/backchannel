//
//  BCStreamCollectionViewCell.m
//  BackChannel
//
//  Created by Saureen Shah on 2/25/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCStreamCollectionViewCell.h"

@implementation BCStreamCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
    
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    for (CALayer *layer in self.contentView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }

    [_cv removeFromSuperview];
    [_ccv removeFromSuperview];
    [_separator removeFromSuperview];
    
    _cv = nil;
    _ccv = nil;
    _separator = nil;
}



@end
