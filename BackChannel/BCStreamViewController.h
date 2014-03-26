//
//  FUPMainViewController.h
//  BackChannel
//
//  Created by Saureen Shah on 10/3/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModels.h"
#import "BCStreamCollectionViewCell.h"

typedef enum Direction {
    LEFT_DIRECTION = 1,
    RIGHT_DIRECTION
} Direction;


@class BCCellTopLayerContainerView;


@interface BCComposeContainerView : UIView
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *nevermind;
@property (strong, nonatomic) UIButton *publish;

@end

@interface BCCellComposeView : UIView
@end

@interface BCCellTopLayerTextView : UIView
+ (CGRect)getViewRect:(float)width withText:(NSString*)text;
@end

@interface BCCellTopLayerHeaderView : UIView
@end

@interface BCCellTopLayerFooterView : UIView
+ (float)getFooterHeight;
@end

@protocol BCCellTopLayerContainerViewDelegate <NSObject>
@optional

- (void)swipeReleaseAnimationBackComplete:(BCCellTopLayerContainerView*)containerView inDirection:(Direction)direction;

@end

@interface BCCellTopLayerContainerView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <BCCellTopLayerContainerViewDelegate>delegate;

- (void)addSwipes;
+ (BOOL)isSwipeLocked;
@end

@interface BCCellBottomLayerContainerView : UIView
@end


@interface BCStreamViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

@end

