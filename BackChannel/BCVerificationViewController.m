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

#import "TTTAttributedLabel.h"

static const float kButtonHeight = 60.0;

@interface BCVerificationView : UIView
@end

@interface BCVerificationView ()
@property (strong, nonatomic) UIImageView *verifyView;
@property (strong, nonatomic) TTTAttributedLabel *title;
@property (strong, nonatomic, getter = getOpenMailButton) UIView *openMailButton;
@property (strong, nonatomic, getter = getResendEmailButton) UIView *resendEmailButton;
@end

@implementation BCVerificationView

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:20.0];
    UIColor *fontColor = [[BCGlobalsManager globalsManager] blueColor];
    NSAttributedString *titleAttributedString = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"Backchannel"]
                                                 attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor}];
    
    CGRect titleRect = [titleAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
    _title = [[TTTAttributedLabel alloc] init];
    _title.attributedText = titleAttributedString;
    [self addSubview:_title];
    
    [_title setSize:titleRect.size];
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];
    
    
    
    _openMailButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    _resendEmailButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    
    [self addSubview:_openMailButton];
    [self addSubview:_resendEmailButton];
    

    _openMailButton.backgroundColor = [[BCGlobalsManager globalsManager] blueBackgroundColor];
    _resendEmailButton.backgroundColor = [[BCGlobalsManager globalsManager] creamBackgroundColor];
    
    UIFont *openFont = [UIFont fontWithName:@"Tisa Pro" size:16.0];
    UIColor *openFontColor = [[BCGlobalsManager globalsManager] blueColor];
    NSMutableAttributedString *openAttributedString = [[NSMutableAttributedString alloc]
                                                       initWithString:@"Open Mail"
                                                       attributes:@{ NSFontAttributeName: openFont,
                                                                     NSForegroundColorAttributeName: openFontColor}];
    CGRect openRect = [openAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil];
    TTTAttributedLabel *openLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0,
                                                                                         0.0,
                                                                                         openRect.size.width,
                                                                                         openRect.size.height)];
    openLabel.attributedText = openAttributedString;
    
    [_openMailButton addSubview:openLabel];
    
    UIFont *resendFont = [UIFont fontWithName:@"Tisa Pro" size:16.0];
    UIColor *resendFontColor = [[BCGlobalsManager globalsManager] creamColor];
    NSMutableAttributedString *resendAttributedString = [[NSMutableAttributedString alloc]
                                                         initWithString:@"Resend email"
                                                         attributes:@{ NSFontAttributeName: resendFont,
                                                                       NSForegroundColorAttributeName: resendFontColor}];
    CGRect resendRect = [resendAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil];
    TTTAttributedLabel *resendLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0,
                                                                                           0.0,
                                                                                           resendRect.size.width,
                                                                                           resendRect.size.height)];
    resendLabel.attributedText = resendAttributedString;
    
    [_resendEmailButton addSubview:resendLabel];
 
    [openLabel placeIn:_openMailButton alignedAt:CENTER];
    [resendLabel placeIn:_resendEmailButton alignedAt:CENTER];
    
    [_resendEmailButton placeIn:self alignedAt:BOTTOM];
    [_openMailButton setY:CGRectGetMinY(_resendEmailButton.frame) - kButtonHeight];
    
    // NOTE: Remove code, just placeholder for now
    UIImage *image = [UIImage imageNamed:@"verify_asset.png"];
    CGSize newSize = (CGSize){200.0, 200.0};
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _verifyView = [[UIImageView alloc] initWithImage:newImage];
    [self addSubview:_verifyView];
    [_verifyView placeIn:self alignedAt:CENTER];
    [_verifyView setY:CGRectGetMinY(_verifyView.frame) - 50.0];
    // Placeholder End //
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
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
    _vc = [[BCVerificationView alloc] init];
    [self.view addSubview:_vc];
}

- (void)openMailTap:(UITapGestureRecognizer*)gesture
{
    NSLog(@"Deep link to Mail.app");
}

- (void)resendEmailTap:(UITapGestureRecognizer*)gesture
{
    BCStreamViewController *vc = [[BCStreamViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.title = @"Backchannel";
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nc animated:YES completion:^() {
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIView *omb = _vc.getOpenMailButton;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMailTap:)];
    [omb addGestureRecognizer:tapGesture];
    
    UIView *reb = _vc.getResendEmailButton;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resendEmailTap:)];
    [reb addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
