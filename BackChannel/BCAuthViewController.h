//
//  BCAuthViewController.h
//  BackChannel
//
//  Created by Saureen Shah on 3/8/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCAuthView : UIView

+ (UILabel*)getTitle;
+ (UILabel*)getTagline;
@end

@interface BCAuthViewController : UIViewController

- (void)handleHowItWorksTap;
- (void)joinTapped;

@end

@interface BCHowItWorks : UIView
@property (weak, nonatomic) IBOutlet UILabel *howItWorksText;

@end