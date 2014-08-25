//
//  BCVerificationViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 3/8/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCVerificationViewController.h"
#import "BCGlobalsManager.h"
#import "BCStreamViewController.h"
#import "BCAPIClient.h"
#import "BCAuthViewController.h"

#import "TTTAttributedLabel.h"

static const float kButtonHeight = 60.0;
static const float kAssetTopMargin = 80.0 + 44.0;
static const float kGreatLabelMargin = 40.0;

@interface BCVerificationView : UIView
@end

@interface BCVerificationView ()
@property (strong, nonatomic) BCVerificationViewController *viewController;
@property (strong, nonatomic) UIImageView *verifyView;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *tagLine;
@property (strong, nonatomic, getter = getResendEmailButton) UIButton *resendEmailButton;
@end

@implementation BCVerificationView

- (id)init:(BCVerificationViewController*)viewController
{
    self = [super initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    _viewController = viewController;
    _title = [BCAuthView getTitle];
    [self addSubview:_title];
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];

    _tagLine = [BCAuthView getTagline];
    [self addSubview:_tagLine];
    [_tagLine placeIn:self alignedAt:CENTER];
    [_tagLine setY:CGRectGetMaxY(_title.frame) + kTitleTaglineSpacing];
    
    UIFont *resendFont = [UIFont fontWithName:@"Poly" size:18.0];
    _resendEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    [self addSubview:_resendEmailButton];
    [_resendEmailButton setTitle:@"Resend email" forState:UIControlStateNormal];
    [_resendEmailButton setTitleColor:[[BCGlobalsManager globalsManager] blueColor] forState:UIControlStateNormal];
    _resendEmailButton.titleLabel.font = resendFont;
    [_resendEmailButton addTarget:self action:@selector(resendTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_resendEmailButton setTitleColor:[[BCGlobalsManager globalsManager] bluePublishColor] forState:UIControlStateHighlighted];
    _resendEmailButton.backgroundColor = [[BCGlobalsManager globalsManager] blueBackgroundColor];
    [_resendEmailButton placeIn:self alignedAt:BOTTOM];
    
    UIImage *image = [UIImage imageNamed:@"envelope.png"];
    _verifyView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_verifyView];
    [_verifyView placeIn:self alignedAt:CENTER];
    [_verifyView setY:kAssetTopMargin];

    NSString *greatLabelString = @"Great! Check your email. We sent an email to";
    TTTAttributedLabel *greatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, CGFLOAT_MAX)];
    [self addSubview:greatLabel];

    greatLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    greatLabel.numberOfLines = 0;
    greatLabel.textAlignment = NSTextAlignmentCenter;
    greatLabel.text = greatLabelString;
    [greatLabel sizeToFit];
    [greatLabel placeIn:self alignedAt:CENTER];
    [greatLabel setY:CGRectGetMaxY(_verifyView.frame) + kGreatLabelMargin];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = (NSString*)[defaults objectForKey:kEmailKey];
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 23.0)];
    [self addSubview:emailLabel];
    emailLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    emailLabel.numberOfLines = 1;
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.text = email;
    emailLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByClipping;
    emailLabel.adjustsFontSizeToFitWidth = YES;
    //[emailLabel sizeToFit];
    [emailLabel placeIn:self alignedAt:CENTER];
    [emailLabel setY:CGRectGetMaxY(greatLabel.frame)];
    emailLabel.textColor = [[BCGlobalsManager globalsManager] greenColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self addSubview:backButton];
    [backButton setTitle:@"←" forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(13, 14, 13, 14)];
    [backButton sizeToFit];
    [backButton setX:6];
    [backButton setY:22];
    backButton.titleLabel.font = [UIFont fontWithName:@"Poly" size:28.0];
    [backButton setTitleColor:[[BCGlobalsManager globalsManager] blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBackButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)handleBackButtonTap:(id)sender
{
    [_viewController handleBackButtonTap];
}

- (void)resendTapped:(id)sender
{
    [_viewController resendTapped];
    [UIView transitionWithView:_resendEmailButton
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ _resendEmailButton.highlighted = YES; }
                    completion:nil];
}

@end



@interface BCVerificationViewController ()
@property (strong, nonatomic) BCVerificationView *vc;

@end

@implementation BCVerificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _vc = [[BCVerificationView alloc] init:self];
    [self.view addSubview:_vc];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)openMailTap:(UITapGestureRecognizer*)gesture
{
    NSLog(@"Deep link to Mail.app");
    
    #if TARGET_IPHONE_SIMULATOR
    
    BCStreamViewController *vc = [[BCStreamViewController alloc] init];
    vc.title = @"Backchannel";
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [[BCGlobalsManager globalsManager] logFlurryAllPageViews:nc];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:^() {}];
    
    #else
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"message:DUMMY"]];
    
    #endif
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:@"openmail_tap" withParams:nil];
}

- (void)resendTapped
{
    #if TARGET_IPHONE_SIMULATOR
    
    BCStreamViewController *vc = [[BCStreamViewController alloc] init];
    vc.title = @"Backchannel";
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [[BCGlobalsManager globalsManager] logFlurryAllPageViews:nc];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:^() {}];
    
    #else

    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Resending email verification success");
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] sendVerificationEmail:success failure:failure];
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:@"resendmail_tap" withParams:nil];
    
    #endif
}

- (void)viewDidLoad
{
  

    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BCGlobalsManager globalsManager] logFlurryPageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)handleBackButtonTap {
    NSLog(@"Got a tap");
    BCAuthViewController *vc = [[BCAuthViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:^() {}];
}


@end
