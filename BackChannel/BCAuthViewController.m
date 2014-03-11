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


static const float kTitleTopMargin = 20.0;
static const float kJoinBarHeight = 60.0;
static const float kEmailMargin = 30.0;

@interface BCAuthView : UIView
@end

@interface BCAuthView ()
@property (strong, nonatomic) TTTAttributedLabel *title;
@property (strong, nonatomic, getter = getEmail) UITextField *email;
@property (strong, nonatomic) UIView *divider;
@property (strong, nonatomic) TTTAttributedLabel *errorText;
@property (strong, nonatomic, getter = getJoinBar) UIView *joinBar;
@property (strong, nonatomic) TTTAttributedLabel *joinLabel;
@end

@implementation BCAuthView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0,
                                           CGRectGetMinY([UIScreen mainScreen].applicationFrame),
                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                           CGRectGetHeight([UIScreen mainScreen].applicationFrame) - kKeyboardHeight)];
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:18.0];
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
    _email.attributedText = emailAttributedString;
    _email.font = emailFont;
    [_email placeIn:self alignedAt:CENTER];
    
    CGPoint point = (CGPoint){CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0};
    NSLog(@"x = %f, y = %f", _email.center.x, _email.center.y);
    NSLog(@"x = %f, y = %f", point.x, point.y);
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    NSLog(@"%@", NSStringFromCGRect(self.bounds));

    
    
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
        _errorText.alpha = 1.0;
    }
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
    int persons = 18;
    [_av updateEmail:persons withError:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_av.getEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    [_av.getEmail becomeFirstResponder];
    
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

@end
