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


@interface BCComposeBarView : UIView
@property (strong, nonatomic) UIButton *nevermind;
@property (strong, nonatomic) UIButton *publish;

- (void)updateBar:(int)count;

@end

@interface BCComposeContainerView : UIView
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) BCComposeBarView *bar;

- (void)update:(int)count;

@end

@interface BCCellContainerView : UIView
@end

@interface BCCellComposeView : BCCellContainerView
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

@interface BCCellTopLayerContainerView : BCCellContainerView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <BCCellTopLayerContainerViewDelegate>delegate;

- (void)addSwipes;
+ (BOOL)isSwipeLocked;
@end

@interface BCCellBottomLayerContainerView : UIView
@end


@interface BCStreamViewController : UIViewController<UICollectionViewDataSource,
                                                        UICollectionViewDelegate,
                                                        UICollectionViewDelegateFlowLayout,
                                                        UITextViewDelegate>

- (void)getLatestPosts:(void (^)(void))callback;
- (void)getLatestNoscrollPosts;

@end

