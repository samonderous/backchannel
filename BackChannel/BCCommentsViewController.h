//
//  BCCommentsViewController.h
//  BackChannel
//
//  Created by Saureen Shah on 9/2/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCModels.h"
#import "BCStreamCollectionViewCell.h"
#import "HPGrowingTextView.h"


@interface BCCommentsViewController : UIViewController

@property (strong, nonatomic) BCSecretModel *secretModel;
@property (strong, nonatomic) UIView *content;

@end