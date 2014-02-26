//
//  FUPViewController.m
//  FollowUp
//
//  Created by Saureen Shah on 10/10/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import "FUPViewController.h"
#import "FUPAppDelegate.h"


@interface FUPViewController ()

@end

@implementation FUPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(performSegue) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performSegue
{
    UIViewController *vc = [FUPAppDelegate sharedAppDelegate].drawerController;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:^() {
        _pickerController = [[FUPPickerViewController alloc] init];
        [[FUPAppDelegate sharedAppDelegate].window addSubview:_pickerController.view];
    }];
}

@end
