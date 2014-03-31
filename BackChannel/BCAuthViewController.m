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

static const float kJoinBarHeight = 60.0;
static const float kEmailMargin = 30.0;

@interface BCAuthView ()
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic, getter = getEmail) UITextField *email;
@property (strong, nonatomic) UIView *divider;
@property (strong, nonatomic) TTTAttributedLabel *errorText;
@property (strong, nonatomic, getter = getJoinBar) UIView *joinBar;
@property (strong, nonatomic) TTTAttributedLabel *joinLabel;
@property (assign, getter = hasErrors) BOOL hasErrors;
@property (strong, nonatomic) UILabel *tagLine;
@end

@implementation BCAuthView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0,
                                           CGRectGetMinY([UIScreen mainScreen].applicationFrame),
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].applicationFrame) - kKeyboardHeight)];
    
    _title = [BCAuthView getTitle];
    [self addSubview:_title];
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];

    
    _tagLine = [BCAuthView getTagline];
    [self addSubview:_tagLine];
    [_tagLine placeIn:self alignedAt:CENTER];
    [_tagLine setY:CGRectGetMaxY(_title.frame) + kTitleTaglineSpacing];
    
    UIFont *emailFont = [UIFont fontWithName:@"Tisa Pro" size:18.0];
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
    _email.placeholder = @"Enter corporate email";
    if ([_email respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [[BCGlobalsManager globalsManager] emptyPostCellColor];;
        _email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter corporate email" attributes:@{NSForegroundColorAttributeName: color}];
    }
    _email.font = emailFont;
    [_email placeIn:self alignedAt:CENTER];
    
    _divider = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 1.0)];
    [self addSubview:_divider];
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [_divider placeIn:self alignedAt:CENTER];
    [_divider setY:CGRectGetMaxY(_email.frame) + 15.0];

    UIFont *errorFont = [UIFont fontWithName:@"Tisa Pro" size:10.0];
    UIColor *errorFontColor = [[BCGlobalsManager globalsManager] redColor];
    NSMutableAttributedString *errorAttributedString = [[NSMutableAttributedString alloc]
                                                        initWithString:@"Be sure to enter a valid corporate email address"
                                                        attributes:@{ NSFontAttributeName: errorFont,
                                                                      NSForegroundColorAttributeName: errorFontColor}];
    CGRect errorRect = [errorAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
    _errorText = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, errorRect.size.width, errorRect.size.height)];
    [self addSubview:_errorText];
    _errorText.attributedText = errorAttributedString;
    [_errorText setY:CGRectGetMaxY(_divider.frame) + 5.0];
    [_errorText setX:CGRectGetMinX(_divider.frame)];
    _errorText.alpha = 0;
    
    _joinBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), kJoinBarHeight)];
    [self addSubview:_joinBar];
    _joinBar.backgroundColor = [[BCGlobalsManager globalsManager] greenBackgroundColor];
    [_joinBar setY:CGRectGetMaxY(self.bounds) - CGRectGetHeight(_joinBar.bounds)];
    
    
    UIFont *joinFont = [UIFont fontWithName:@"Tisa Pro" size:16.0];
    UIColor *joinFontColor = [[BCGlobalsManager globalsManager] greenPublishColor];
    NSMutableAttributedString *joinAttributedString = [[NSMutableAttributedString alloc]
                                                       initWithString:@"Join"
                                                       attributes:@{ NSFontAttributeName: joinFont,
                                                                     NSForegroundColorAttributeName: joinFontColor}];
    CGRect joinRect = [joinAttributedString boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
    _joinLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, joinRect.size.width, joinRect.size.height)];
    _joinLabel.attributedText = joinAttributedString;
    [_joinBar addSubview:_joinLabel];
    [_joinLabel placeIn:_joinBar alignedAt:CENTER];
    
    self.backgroundColor = [UIColor whiteColor];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)removeError
{
    _errorText.alpha = 0.0;
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    _hasErrors = NO;
}

- (void)showError
{
    _errorText.alpha = 1.0;
    _divider.backgroundColor = [[BCGlobalsManager globalsManager] redColor];
    _hasErrors = YES;
}

- (void)updateEmail:(int)persons withError:(BOOL)isError
{
    UIFont *joinFont = [UIFont fontWithName:@"Tisa Pro" size:16.0];
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
    
    if (isError) {
        [self showError];
    }
}

+ (UILabel*)getTitle
{
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:kTitleFontSize];
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
    UIFont *tagLineFont = [UIFont fontWithName:@"Tisa Pro" size:kTagLineFont];
    UIColor *tagLineColor = [[BCGlobalsManager globalsManager] blackTaglineColor];
    UILabel *tagLine = [[UILabel alloc] init];
    tagLine.font = tagLineFont;
    tagLine.textColor = tagLineColor;
    tagLine.text = @"Speak with ease at work";
    [tagLine sizeToFit];

    return tagLine;
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
    _av = [[BCAuthView alloc] init];
    [self.view addSubview:_av];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)joinTapped:(UITapGestureRecognizer*)gesture
{
    
    // NOTE: Write to server
    //
    int persons = 18;
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        int status = (int)[responseObject[@"status"] integerValue];
        if (status == 1) {
            [_av updateEmail:persons withError:YES];
        } else {
            NSString *udid = [[UIDevice currentDevice].identifierForVendor UUIDString];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            NSString *email = (NSString*)responseObject[@"email"];
            [defaults setObject:email forKey:kEmailKey];
            [defaults setObject:udid forKey:kUdidKey];
            [defaults setObject:@"NO" forKey:kVerifiedKey];
            [defaults synchronize];
            BCVerificationViewController *vc = [[BCVerificationViewController alloc] init];
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [_av updateEmail:persons withError:NO];
            [self presentViewController:vc animated:YES completion:^() {}];
        }
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] sendAuth:_av.email.text success:success failure:failure];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_av.getEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [_av.getEmail becomeFirstResponder];
    _av.getEmail.delegate = self;
    
	// Do any additional setup after loading the view.
    UIView *joinBar = _av.getJoinBar;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(joinTapped:)];
    [joinBar addGestureRecognizer:tapGesture];
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
        [_av removeError];
    }
    
    return YES;
}

@end
