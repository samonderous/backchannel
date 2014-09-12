//
//  BCAuthViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 3/8/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "TTTAttributedLabel.h"

#import "BCAuthViewController.h"
#import "BCGlobalsManager.h"
#import "BCVerificationViewController.h"
#import "BCAPIClient.h"
#import "BCWaitingViewController.h"

static const float kJoinBarHeight = 60.0;
static const float kEmailMargin = 30.0;

NSString *assuranceMessage = @"We will not share your id with coworkers or employers.";
NSString *errorMessage = @"Be sure to enter a valid work email address";


@interface BCHowItWorks ()
@end

@implementation BCHowItWorks
@end

@interface BCAuthView ()
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *tagLine;
@property (strong, nonatomic, getter = getEmail) UITextField *email;
@property (strong, nonatomic) UIView *divider;
@property (strong, nonatomic) UILabel *errorText;
@property (strong, nonatomic, getter = getJoinBar) UIButton *joinBar;
@property (strong, nonatomic) TTTAttributedLabel *joinLabel;
@property (assign, getter = hasErrors) BOOL hasErrors;
@property (strong, nonatomic) BCAuthViewController *viewController;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

- (void)fadeJoinButtonIn;
- (void)addActivityIndicator;
- (void)removeActivityIndicator;

@end

@implementation BCAuthView

- (id)init:(BCAuthViewController*)viewController
{
    self = [super initWithFrame:CGRectMake(0.0,
                                           CGRectGetMinY([UIScreen mainScreen].applicationFrame),
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].applicationFrame) - kKeyboardHeight)];
    _viewController = viewController;
    
    _title = [BCAuthView getTitle];
    [self addSubview:_title];
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];
    
    _tagLine = [BCAuthView getTagline];
    [self addSubview:_tagLine];
    [_tagLine placeIn:self alignedAt:CENTER];
    [_tagLine setY:CGRectGetMaxY(_title.frame) + kTitleTaglineSpacing];
    
    UIFont *emailFont = [UIFont fontWithName:@"Poly" size:18.0];
    NSMutableAttributedString *emailAttributedString = [[NSMutableAttributedString alloc]
                                                        initWithString:@""
                                                        attributes:@{ NSFontAttributeName: emailFont}];
    CGRect emailRect = [emailAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];

    float width = CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * kEmailMargin;
    _email = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                           0.0,
                                                           width,
                                                           emailRect.size.height + 10.0)];
    [self addSubview:_email];
    _email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _email.autocorrectionType = UITextAutocorrectionTypeNo;
    _email.attributedText = emailAttributedString;
    _email.placeholder = @"Enter your work email";
    if ([_email respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [[BCGlobalsManager globalsManager] emptyPostCellColor];;
        _email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your work email" attributes:@{NSForegroundColorAttributeName: color}];
    }
    _email.font = emailFont;
    [_email placeIn:self alignedAt:CENTER];
    
    _divider = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 1.0)];
    [self addSubview:_divider];
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [_divider placeIn:self alignedAt:CENTER];
    [_divider setY:CGRectGetMaxY(_email.frame) + 15.0];

    UIFont *errorFont = [UIFont fontWithName:@"Poly" size:10.0];
    _errorText = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGFLOAT_MAX, CGFLOAT_MAX)];
    [self addSubview:_errorText];
    _errorText.text = assuranceMessage;
    _errorText.font = errorFont;
    [self showAssurance];
    [_errorText sizeToFit];
    [_errorText setY:CGRectGetMaxY(_divider.frame) + 5.0];
    [_errorText setX:CGRectGetMinX(_divider.frame)];
    
    UIFont *joinFont = [UIFont fontWithName:@"Poly" size:18.0];
    UIColor *joinFontColor = [[BCGlobalsManager globalsManager] greenColor];
    _joinBar = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), kJoinBarHeight)];
    [self addSubview:_joinBar];
    [_joinBar setTitle:@"Join" forState:UIControlStateNormal];
    [_joinBar setTitleColor:joinFontColor forState:UIControlStateNormal];
    _joinBar.titleLabel.font = joinFont;
    _joinBar.backgroundColor = [[BCGlobalsManager globalsManager] greenBackgroundColor];
    [_joinBar setY:CGRectGetMaxY(self.bounds) - CGRectGetHeight(_joinBar.bounds)];
    [_joinBar addTarget:self action:@selector(joinTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_joinBar setTitleColor:[[BCGlobalsManager globalsManager] greenPublishColor] forState:UIControlStateHighlighted];

    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_joinBar addSubview:_loadingIndicator];
    [_loadingIndicator placeIn:_joinBar alignedAt:CENTER];

    self.backgroundColor = [UIColor whiteColor];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)showAssurance
{
    UIColor *errorFontColor = [[BCGlobalsManager globalsManager] blackTaglineColor];
    _errorText.text = assuranceMessage;
    _errorText.textColor = errorFontColor;
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    _hasErrors = NO;
}

- (void)showError
{
    UIColor *errorFontColor = [[BCGlobalsManager globalsManager] redColor];

    _errorText.text = errorMessage;
    _errorText.textColor = errorFontColor;
    
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] redColor];
    _hasErrors = YES;
}

- (void)updateEmail:(int)persons withError:(BOOL)isError
{
    /*
    UIFont *joinFont = [UIFont fontWithName:@"Poly" size:16.0];
    UIColor *joinFontColor = [[BCGlobalsManager globalsManager] greenColor];
    NSString *joinStr = [NSString stringWithFormat:@"Join %d coworkers", persons];
    
    [_joinLabel removeFromSuperview];

    NSMutableAttributedString *joinAttributedString = [[NSMutableAttributedString alloc]
                                                       initWithString:joinStr
                                                       attributes:@{ NSFontAttributeName: joinFont,
                                                                     NSForegroundColorAttributeName: joinFontColor}];
    CGRect joinRect = [joinAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil];
    _joinLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, joinRect.size.width, joinRect.size.height)];
    _joinLabel.attributedText = joinAttributedString;
    [_joinBar addSubview:_joinLabel];
    [_joinLabel placeIn:_joinBar alignedAt:CENTER];
    */
    if (isError) {
        [self showError];
    }
}

+ (UILabel*)getTitle
{
    UIFont *font = [UIFont fontWithName:@"Poly" size:kTitleFontSize];
    UIColor *fontColor = [[BCGlobalsManager globalsManager] blueColor];
    UILabel *title = [[UILabel alloc] init];
    title.font = font;
    title.textColor = fontColor;
    title.text = @"Backchannel";
    [title sizeToFit];
    
    return title;
}

+ (UILabel*)getTagline
{
    UIFont *tagLineFont = [UIFont fontWithName:@"Poly" size:kTagLineFont];
    UIColor *tagLineColor = [[BCGlobalsManager globalsManager] blackTaglineColor];
    UILabel *tagLine = [[UILabel alloc] init];
    tagLine.font = tagLineFont;
    tagLine.textColor = tagLineColor;
    tagLine.text = @"Anonymous workplace sharing";
    [tagLine sizeToFit];

    return tagLine;
}

- (void)joinTapped:(id)sender
{
    [_viewController joinTapped];
}

- (void)fadeJoinButtonIn
{
    [UIView transitionWithView:_joinBar
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ _joinBar.highlighted = YES; }
                    completion:nil];
}

- (void)addActivityIndicator
{
    [_joinBar setTitle:@"" forState:UIControlStateNormal];
    [_joinBar setTitle:@"" forState:UIControlStateHighlighted];

    [_loadingIndicator startAnimating];
}

- (void)removeActivityIndicator
{
    [_joinBar setTitle:@"Join" forState:UIControlStateNormal];
    [_joinBar setTitle:@"Join" forState:UIControlStateHighlighted];
    [_loadingIndicator stopAnimating];
}

@end



@interface BCAuthViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) BCAuthView *av;
@end

@implementation BCAuthViewController

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
    _av = [[BCAuthView alloc] init:self];
    [self.view addSubview:_av];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)joinTapped
{
    int persons = 18;
    NSString *udid = [[UIDevice currentDevice].identifierForVendor UUIDString];

    [_av addActivityIndicator];
    
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = (int)[responseObject[@"status"] integerValue];

        [_av removeActivityIndicator];

        // ERROR CASE
        if (status == 1) {
            // FIXME: turn this on when we decide on the teaser
            [_av updateEmail:persons withError:YES];
        }
        
        // WHITELIST CASE
        else if (status == 2) {
            // Not whitelisted
            BCWaitingViewController *vc = [[BCWaitingViewController alloc] init];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:vc animated:YES completion:^() {}];
        }
        
        // EMAIL SUCCESS CASE, OFF TO VERIFICATION
        else {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *email = (NSString*)responseObject[@"email"];
            [defaults setObject:email forKey:kEmailKey];
            [defaults setObject:udid forKey:kUdidKey];
            [defaults setObject:@"NO" forKey:kVerifiedKey];
            [defaults synchronize];
            BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            //[_av updateEmail:persons withError:NO];
            [self presentViewController:vc animated:YES completion:^() {}];
        }
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_av removeActivityIndicator];
    };
    
    [[BCAPIClient sharedClient] sendAuth:_av.email.text success:success failure:failure];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"email_entered", _av.email.text, nil];
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventJoinTapped withParams:params];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_av.getEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [_av.getEmail becomeFirstResponder];
    _av.getEmail.delegate = self;
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

#pragma UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_av.hasErrors) {
        [_av showAssurance];
    }
    
    return YES;
}

@end
