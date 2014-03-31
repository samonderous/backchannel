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
@property (strong, nonatomic) UIImageView *verifyView;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *tagLine;
@property (strong, nonatomic, getter = getOpenMailButton) UIView *openMailButton;
@property (strong, nonatomic, getter = getResendEmailButton) UIView *resendEmailButton;
@end

@implementation BCVerificationView

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    _title = [BCAuthView getTitle];
    [self addSubview:_title];
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];

    _tagLine = [BCAuthView getTagline];
    [self addSubview:_tagLine];
    [_tagLine placeIn:self alignedAt:CENTER];
    [_tagLine setY:CGRectGetMaxY(_title.frame) + kTitleTaglineSpacing];
    
    _openMailButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    _resendEmailButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    
    [self addSubview:_openMailButton];
    [self addSubview:_resendEmailButton];
    

    _openMailButton.backgroundColor = [[BCGlobalsManager globalsManager] blueBackgroundColor];
    _resendEmailButton.backgroundColor = [[BCGlobalsManager globalsManager] creamBackgroundColor];
    
    UIFont *openFont = [UIFont fontWithName:@"Tisa Pro" size:18.0];
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
    
    UIFont *resendFont = [UIFont fontWithName:@"Tisa Pro" size:18.0];
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
    
    UIImage *image = [UIImage imageNamed:@"envelope.png"];
    _verifyView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_verifyView];
    [_verifyView placeIn:self alignedAt:CENTER];
    [_verifyView setY:kAssetTopMargin];

    NSString *greatLabelString = @"Great! Check your email for an access link.";
    TTTAttributedLabel *greatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, CGFLOAT_MAX)];
    [self addSubview:greatLabel];

    greatLabel.font = [UIFont fontWithName:@"Tisa Pro" size:18.0];
    greatLabel.numberOfLines = 0;
    greatLabel.textAlignment = NSTextAlignmentCenter;
    greatLabel.text = greatLabelString;
    [greatLabel sizeToFit];
    [greatLabel placeIn:self alignedAt:CENTER];
    [greatLabel setY:CGRectGetMaxY(_verifyView.frame) + kGreatLabelMargin];
    
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
    
    #if TARGET_IPHONE_SIMULATOR
    BCStreamViewController *vc = [[BCStreamViewController alloc] init];
    vc.title = @"Backchannel";
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:^() {}];
    #else
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"message:DUMMY"]];
    #endif
}

- (void)resendEmailTap:(UITapGestureRecognizer*)gesture
{
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Resending email verification success");
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] sendVerificationEmail:success failure:failure];
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
