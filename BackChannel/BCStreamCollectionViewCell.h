//
//  BCStreamCollectionViewCell.h
//  BackChannel
//
//  Created by Saureen Shah on 2/25/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCStreamViewController.h"

@class BCCellTopLayerContainerView;
@class BCComposeContainerView;

@interface BCStreamCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) BCComposeContainerView *ccv;
@property (strong, nonatomic) BCCellTopLayerContainerView *tcv;

@end
