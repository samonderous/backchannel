//
//  BCStreamViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 10/3/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MCSwipeTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "Utils.h"

#import "BCAppDelegate.h"
#import "BCStreamViewController.h"
#import "BCModels.h"
#import "BCGlobalsManager.h"
#import "BCAPIClient.h"

static const float kCellHeight = 251.0f;
static const float kSecretFontSize = 16.0;
static const float kCellComposeHeight = 64.0;
static const float kHeaderFooterHeight = 30.0;
static const float kRowSpacing = 0.0f;
static const float kPublishBarHeight = 60.0;
static const int kMaxCharCount = 140;
static const int kCellEdgeInset = 30.0;
static const float kPublishPushDuration = 0.5;
static const float kNewPostStartPositionY = 25.0;
static const float kPublishMeterHeight = 2.0;
static const float kPUblishButtonCharCountLabelSpacing = 15.0;
static const float kComposeTextViewFooterViewMargin = 0.0;
static const float kComposeTextViewHeaderViewMargin = 30.0;
static const float kVoteThresholdMargin = 20.0;
static const int kOldPostsBatchSize = 10;


@interface BCComposePublishTutorialView : UIView
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *arrow;
@end

@interface BCComposePublishTutorialView ()
@end

@implementation BCComposePublishTutorialView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), 60.0)];
    _label = [[UILabel alloc] init];
    _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    
    [self addSubview:_label];
    [self addSubview:_arrow];
    
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 0.95;

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *publishTutorialString = @"Press and hold* to publish *to prevent accidental posts";
    NSMutableAttributedString *publishTutorial  = [[NSMutableAttributedString alloc]
                                                    initWithString:publishTutorialString];
    
    [publishTutorial addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] greenColor] range: NSMakeRange(0, 26)];
    
    [publishTutorial addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Poly" size:15.0] range: NSMakeRange(0, 26)];
    
    [publishTutorial addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] publishTutorialHintColor] range: NSMakeRange(27, publishTutorialString.length - 27)];
    
    [publishTutorial addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Poly" size:12.0] range:NSMakeRange(27, publishTutorialString.length - 27)];
    
    [_label setSize:(CGSize){180.0, CGFLOAT_MAX}];
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.attributedText = publishTutorial;
    [_label sizeToFit];
    [_label placeIn:self alignedAt:CENTER];
    [_arrow placeIn:self alignedAt:CENTER_RIGTH withMargin:64.0];
}

@end


@implementation BCCellContainerView
@end


@interface BCComposeContainerView ()
@end

@implementation BCComposeContainerView

- (id)init:(BCStreamCollectionViewCell*)cell withHeight:(float)height withBar:(BCComposeBarView*)bar
{
    float width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, height)];

    _bar = bar;
    
    UIFont *textFont = [[BCGlobalsManager globalsManager] composeFont];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cell.frame),
                                                             0.0,
                                                             CGRectGetWidth(cell.contentView.bounds),
                                                             height - kPublishBarHeight)];
    [[UITextView appearance] setTintColor:[[BCGlobalsManager globalsManager] blueColor]];
    _textView.scrollEnabled = YES;
    //_textView.contentInset = UIEdgeInsetsMake(-14, -4, 0, 0); // Removes all padding top and left.
    _textView.contentInset = UIEdgeInsetsMake(11, -4, 0, 0); // To cancel out the textview top padding by default
    _textView.font = textFont;
    
    [self addSubview:_textView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}


- (void)update:(int)count
{
    UIColor *fontColor = [[BCGlobalsManager globalsManager] fontColor];
    
    if (count <= 0) {
        [_bar updateBar:count];
        return;
    }
    
    NSRange oldSelectedRange = _textView.selectedRange;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]
                                                          initWithString:_textView.text
                                                          attributes:@{ NSFontAttributeName:[[BCGlobalsManager globalsManager] composeFont]}];
    if (count > kMaxCharCount) {
        fontColor = [[BCGlobalsManager globalsManager] redColor];
        [mutableAttributedString addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] redColor] range: NSMakeRange(kMaxCharCount, count - kMaxCharCount)];
        _textView.attributedText = mutableAttributedString;
        [_textView setSelectedRange:oldSelectedRange];
    } else {
        fontColor = [UIColor blackColor];
        [mutableAttributedString addAttribute: NSForegroundColorAttributeName value: fontColor range: NSMakeRange(0, mutableAttributedString.length - 1)];
        _textView.attributedText = mutableAttributedString;

        [_textView setSelectedRange:oldSelectedRange];
    }
    
    [_bar updateBar:count];
}


@end

@interface BCComposeBarView ()
@property (strong, nonatomic) TTTAttributedLabel *charCountLabel;
@property (strong, nonatomic) UIView *publishMeter;
@property (strong, nonatomic) BCComposePublishTutorialView *publishTutorialView;
@end

@implementation BCComposeBarView

- (id)init:(BCStreamCollectionViewCell*)cell withHeight:(float)height
{
    //NSLog(@"%@",[NSThread callStackSymbols]);
    UIColor *fontColor = [[BCGlobalsManager globalsManager] fontColor];
    
    float width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    
    _nevermind = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, width / 2.0, CGRectGetHeight(self.bounds))];
    _publish = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nevermind.frame), 0.0, width / 2.0, CGRectGetHeight(self.bounds))];
    
    [_nevermind setTitle:@"Nevermind" forState:UIControlStateNormal];
    [_nevermind setTitleColor:[[BCGlobalsManager globalsManager] creamColor] forState:UIControlStateNormal];
    [_nevermind setTitleColor:[[BCGlobalsManager globalsManager] creamPublishColor] forState:UIControlStateHighlighted];

    _nevermind.backgroundColor = [[BCGlobalsManager globalsManager] creamBackgroundColor];
    _nevermind.titleLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    
    [_publish setTitle:@"Publish" forState:UIControlStateNormal];
    [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenColor] forState:UIControlStateNormal];
    [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenPublishColor] forState:UIControlStateHighlighted];
    _publish.backgroundColor = [[BCGlobalsManager globalsManager] greenBackgroundColor];
    _publish.titleLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    _publish.userInteractionEnabled = NO;
    _publish.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _publish.titleEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0);
    
    _charCountLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [_publish addSubview:_charCountLabel];
    _charCountLabel.userInteractionEnabled = NO; // so touch event passes up hierarchy

    UIFont *font = [UIFont fontWithName:@"Poly" size:15.0];
    NSAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%d", kMaxCharCount]
                                          attributes:@{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor}];
    _charCountLabel.textColor = fontColor;
    _charCountLabel.font = font;
    _charCountLabel.attributedText = attributedText;
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    rect.size.width += 20.0;
    [_charCountLabel setSize:rect.size];
    // 32 from left edge of button + width of button + 15 extra margin
    [_charCountLabel placeIn:_publish alignedAt:CENTER_LEFT withMargin:32.0 + 60.0 + kPUblishButtonCharCountLabelSpacing];
    
    _publishMeter = [[UIView alloc] initWithFrame:CGRectMake(-width, -kPublishMeterHeight, width, kPublishMeterHeight)];
    _publishMeter.backgroundColor = [[BCGlobalsManager globalsManager] greenColor];

    _publishTutorialView = [[BCComposePublishTutorialView alloc] init];
    [self addSubview :_publishTutorialView];
    UIView *cover = [[UIView alloc] initWithFrame:self.bounds];
    cover.backgroundColor = [UIColor whiteColor];
    [self addSubview:cover];
    
    [self addSubview:_nevermind];
    [self addSubview:_publish];
    [self addSubview:_publishMeter];
    
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = NO;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)triggerPublishTutorial
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPublishTutorialShown = [[defaults objectForKey:kPublishTutorialKey] boolValue];
    if (!isPublishTutorialShown) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_publishTutorialView setY:-CGRectGetHeight(_publishTutorialView.bounds)];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)setPublishTutorialShown
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:kPublishTutorialKey];
}

- (void)updateBar:(int)count
{
    UIColor *fontColor = [[BCGlobalsManager globalsManager] fontColor];
    UIFont *font = [UIFont fontWithName:@"Poly" size:15.0];
    
    if (count > kMaxCharCount) {
        fontColor = [[BCGlobalsManager globalsManager] redColor];
        _publish.backgroundColor = [[BCGlobalsManager globalsManager] blackPublishBackgroundColor];
        [_publish setTitleColor:[[BCGlobalsManager globalsManager] blackPublishFontColor] forState:UIControlStateNormal];
        _publish.userInteractionEnabled = NO;
    } else {
        _publish.userInteractionEnabled = YES;
        [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenColor] forState:UIControlStateNormal];
        _publish.backgroundColor = [[BCGlobalsManager globalsManager] greenBackgroundColor];
    }
    NSAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%d", abs(kMaxCharCount - count)]
                                          attributes:@{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor}];
    
    _charCountLabel.font = font;
    _charCountLabel.attributedText = attributedText;
    
    if (count <= 0) {
        _publish.userInteractionEnabled = NO;
    }
}

@end


@interface BCCellComposeView ()
@end


@implementation BCCellComposeView

- (id)init:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kCellComposeHeight)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, kCellComposeHeight)];
    textLabel.text = @"Tap to add your thoughts...";
    textLabel.textColor = [[BCGlobalsManager globalsManager] emptyPostCellColor];
    textLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    [self addSubview:textLabel];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface BCCellTopLayerTextView ()
@end

@implementation BCCellTopLayerTextView

- (id)initWithText:(BCSecretModel*)model withWidth:(float)width
{
    self = [super init];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [textLabel setWidth:width];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"Poly" size:18.0];;
    textLabel.text = model.text;
    [textLabel sizeToFit];
    [self addSubview:textLabel];
    [self setSizeWidth:width andHeight:CGRectGetHeight(textLabel.bounds)];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

+ (CGRect)getViewRect:(float)width withText:(NSString*)text
{
    UIFont *font = [UIFont systemFontOfSize:kSecretFontSize];
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:text
                                          attributes:@{ NSFontAttributeName:font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect;
}

@end


@interface BCCellTopLayerHeaderView ()
@end

@implementation BCCellTopLayerHeaderView

- (id)init:(BCSecretModel*)model withWidth:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    UIFont *font = [UIFont fontWithName:@"Poly" size:15.0];
    NSString *voteText = [NSString stringWithFormat:@"+%d / -%d", (int)model.agrees, (int)model.disagrees];
    NSRange range = [voteText rangeOfString:@"/"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                                 initWithString:voteText
                                                 attributes:@{ NSFontAttributeName:font,
                                                               NSForegroundColorAttributeName: [[BCGlobalsManager globalsManager] creamColor]}];
    
    [attributedText addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] blackTaglineColor]
                           range: NSMakeRange(range.location, range.location)];
    
    if (model.agrees > model.disagrees) {
        [attributedText addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] greenColor]
                               range: NSMakeRange(0, range.location - 1)];
    } else if (model.agrees < model.disagrees) {
        [attributedText addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] redColor]
                               range: NSMakeRange(range.location + 1, voteText.length - 1 - range.location)];
    }
    
    TTTAttributedLabel *voteLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    voteLabel.attributedText = attributedText;
    voteLabel.numberOfLines = 1;

    [self addSubview:voteLabel];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    [voteLabel setSize:rect.size];
    [voteLabel placeIn:self alignedAt:CENTER];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface BCCellTopLayerFooterView ()
@end

@implementation BCCellTopLayerFooterView

- (id)init:(NSString*)time withWidth:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    UIFont *font = [UIFont fontWithName:@"Poly" size:15.0];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    timeLabel.font = font;
    timeLabel.textColor = [[BCGlobalsManager globalsManager] blackTaglineColor];
    timeLabel.text = time;
    [self addSubview:timeLabel];
    [timeLabel sizeToFit];
    [timeLabel placeIn:self alignedAt:CENTER_LEFT];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

+ (float)getFooterHeight
{
    return kHeaderFooterHeight;
}

@end


@interface BCCellBottomLayerContainerView ()
@end

@implementation BCCellBottomLayerContainerView

- (id)init:(CGSize)size
{
    self = [self initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface BCCellTopLayerContainerView ()
@property (strong, nonatomic) BCCellBottomLayerContainerView *bottomLayerContainerView;
@property (strong, nonatomic) BCCellTopLayerTextView *textView;
@property (strong, nonatomic) BCCellTopLayerFooterView *footerView;
@property (strong, nonatomic) BCCellTopLayerHeaderView *headerView;
@property (strong, nonatomic) BCSecretModel *secretModel;
@property (assign) CGSize size;
@property (assign) BOOL isDragging;
@property (strong, nonatomic) UIView *agreeContainer;
@property (strong, nonatomic) UIView *disagreeContainer;
@property (assign) BOOL thresholdCrossed;

@property UIDynamicAnimator *animator;
@property UIGravityBehavior *gravityBehavior;
@property UICollisionBehavior *collisionBehavior;
@property UIPushBehavior *pushBehavior;
@property CGFloat swipeCellStartX;

@end

@implementation BCCellTopLayerContainerView

static BOOL isSwipeLocked = NO;

- (id)init:(BCSecretModel*)secretModel withSize:(CGSize)size withBottomContainer:(BCCellBottomLayerContainerView*)bottomLayerContainerView
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        static BOOL isSwipeLocked = NO;
    });
    
    _size = size;
    _secretModel = secretModel;
    _bottomLayerContainerView = bottomLayerContainerView;
    _isDragging = YES;

    _textView = [[BCCellTopLayerTextView alloc] initWithText:secretModel withWidth:size.width];
    _footerView = [[BCCellTopLayerFooterView alloc] init:secretModel.timeStr withWidth:size.width];

    [self addSubview:_textView];
    [self addSubview:_footerView];
    [self addVoteViews];
    
    [_footerView placeIn:self alignedAt:CENTER];
    [_textView placeIn:self alignedAt:CENTER];
    
    if (secretModel.isNew) {
        _textView.hidden = YES;
        [_textView setY:kNewPostStartPositionY];
        secretModel.isNew = NO;
    }

    [_footerView setY:(CGRectGetMaxY(_textView.frame) + kComposeTextViewFooterViewMargin)];
    
    if (_secretModel.vote != VOTE_NONE) {
        [self updateVoteView];
        _isDragging = NO;
        _secretModel.isVoted = YES;
    }
    self.backgroundColor = [UIColor whiteColor];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    _swipeCellStartX = 0;
    _thresholdCrossed = NO;
    
    return self;
}


- (void)addVoteViews
{
    self.clipsToBounds = NO;
    
    _agreeContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _disagreeContainer = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    agreeLabel.font = [UIFont fontWithName:@"Poly" size:36.0];
    agreeLabel.text = @"1";
    agreeLabel.textColor = [[BCGlobalsManager globalsManager] greenColor];
    [agreeLabel sizeToFit];
    agreeLabel.clipsToBounds = NO;
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    plusLabel.font = [UIFont fontWithName:@"Poly" size:24.0];
    plusLabel.text = @"+";
    plusLabel.textColor = [[BCGlobalsManager globalsManager] greenColor];
    [plusLabel sizeToFit];
    
    [_agreeContainer addSubview:agreeLabel];
    [_agreeContainer addSubview:plusLabel];
    [_agreeContainer setSize:(CGSize){CGRectGetWidth(agreeLabel.bounds) + CGRectGetWidth(plusLabel.bounds),
                                    CGRectGetHeight(agreeLabel.bounds)}];
    
    [plusLabel placeIn:_agreeContainer alignedAt:CENTER_LEFT];
    [agreeLabel placeIn:_agreeContainer alignedAt:CENTER_RIGTH];
    
    UILabel *disagreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    disagreeLabel.font = [UIFont fontWithName:@"Poly" size:36.0];
    disagreeLabel.text = @"1";
    disagreeLabel.textColor = [[BCGlobalsManager globalsManager] redColor];
    [disagreeLabel sizeToFit];
    disagreeLabel.clipsToBounds = NO;
    UILabel *minusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    minusLabel.font = [UIFont fontWithName:@"Poly" size:24.0];
    minusLabel.text = @"-";
    minusLabel.textColor = [[BCGlobalsManager globalsManager] redColor];
    [minusLabel sizeToFit];
    
    [_disagreeContainer addSubview:disagreeLabel];
    [_disagreeContainer addSubview:minusLabel];
    [_disagreeContainer setSize:(CGSize){CGRectGetWidth(disagreeLabel.bounds) + CGRectGetWidth(minusLabel.bounds),
                                        CGRectGetHeight(disagreeLabel.bounds)}];
    [minusLabel placeIn:_disagreeContainer alignedAt:CENTER_LEFT];
    [disagreeLabel placeIn:_disagreeContainer alignedAt:CENTER_RIGTH];
    
    [self addSubview:_agreeContainer];
    [self addSubview:_disagreeContainer];
    
    // Place outside cell
    [_agreeContainer placeIn:self alignedAt:CENTER_LEFT withMargin:-kCellEdgeInset - CGRectGetWidth(_agreeContainer.bounds)];
    [_disagreeContainer placeIn:self alignedAt:CENTER_RIGTH withMargin:-kCellEdgeInset - CGRectGetWidth(_disagreeContainer.bounds)];

    _agreeContainer.clipsToBounds = NO;
    _disagreeContainer.clipsToBounds = NO;
}

- (void)updateVoteView
{
    [_headerView removeFromSuperview];
    _headerView = [[BCCellTopLayerHeaderView alloc] init:_secretModel withWidth:_size.width];
    [_headerView placeIn:self alignedAt:CENTER];
    [self addSubview:_headerView];
    [_headerView setY:kComposeTextViewHeaderViewMargin];
}

+ (void)setSwipeLocked:(BOOL)isLock
{
    isSwipeLocked = isLock;
}

+ (BOOL)isSwipeLocked
{
    return isSwipeLocked;
}

- (void)addSwipes
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.delegate = self;
	[self addGestureRecognizer:panRecognizer];
}

- (void)animateVoteInteraction:(UIView*)view inDirection:(Direction)direction
{
    CGAffineTransform scaleTransform = CGAffineTransformScale(view.transform, 1.5, 1.5);
    [UIView animateWithDuration:0.5 delay:0 options:0
                     animations:^{
                         view.transform = scaleTransform;
                         view.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             view.transform = CGAffineTransformIdentity;
                         }
                     }];
}

- (void)swipeVoteInteractionHandle:(BOOL)islockPlace inDirection:(Direction)direction
{
    BCCellBottomLayerContainerView *bcv = self.bottomLayerContainerView;

    if (islockPlace) {
        if (direction == RIGHT_DIRECTION && _agreeContainer.superview != bcv) {
            [_agreeContainer removeFromSuperview];
            [bcv addSubview:_agreeContainer];
            [_agreeContainer placeIn:bcv alignedAt:CENTER_LEFT withMargin:kVoteThresholdMargin];
            [self animateVoteInteraction:_agreeContainer inDirection:RIGHT_DIRECTION];
        }
        if (direction == LEFT_DIRECTION && _disagreeContainer.superview != bcv) {
            [_disagreeContainer removeFromSuperview];
            [bcv addSubview:_disagreeContainer];
            [_disagreeContainer placeIn:bcv alignedAt:CENTER_RIGTH withMargin:kVoteThresholdMargin];
            [self animateVoteInteraction:_disagreeContainer inDirection:LEFT_DIRECTION];
        }
    } else { // Not necessary but in case we want to push the containers back
        if (_agreeContainer.superview != self) {
            [_agreeContainer removeFromSuperview];
            [self addSubview:_agreeContainer];
            [_agreeContainer placeIn:self alignedAt:CENTER_LEFT withMargin:-CGRectGetWidth(_agreeContainer.bounds) - kCellEdgeInset];
        }
        
        if (_disagreeContainer.superview != self) {
            [_disagreeContainer removeFromSuperview];
            [self addSubview:_disagreeContainer];
            [_disagreeContainer placeIn:self alignedAt:CENTER_RIGTH withMargin:-CGRectGetWidth(_agreeContainer.bounds) - kCellEdgeInset];
        }
    }
}

- (Direction)getSwipeDirection:(CGPoint)velocity
{
    return velocity.x <= 0 ? LEFT_DIRECTION : RIGHT_DIRECTION;
}

- (void)handleSwipe:(UIPanGestureRecognizer*)gesture
{
    // Condition: (_isDragging == NO && _thresholdCrossed) to handle case where
    // handleSwipe gets called after threshold gets reached and swipeRelease*
    // delegate gets called to log vote. We want to block swipe only if they crossed
    // threshold but still want to enter into END state so check on isDragging as well.
    //if ((_isDragging == NO && _thresholdCrossed) || isSwipeLocked) return;
    if (_secretModel.isVoted || isSwipeLocked) return;

    CGFloat dragThreshold = 1.0f;
    CGFloat voteThreshhold = CGRectGetWidth(_agreeContainer.bounds) + kCellEdgeInset + kVoteThresholdMargin;

    CGPoint delta = [gesture translationInView:gesture.view.superview];
    CGPoint velocity = [gesture velocityInView:gesture.view.superview];
    CGPoint location = [gesture locationInView:gesture.view.superview];
    location.y = CGRectGetMidY(gesture.view.superview.bounds);
    
    Direction direction = [self getSwipeDirection:velocity];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _isDragging = YES;
        _thresholdCrossed = NO;
        _swipeCellStartX = gesture.view.frame.origin.x;
        [_animator removeAllBehaviors];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        _isDragging = YES;
        // create "resistance" to cell panning immediately
        //if (fabsf(delta.x) < dragThreshold) return;
        
        // move cell to track swipe
        CGFloat xDirection = (velocity.x > 0) ? 1.0f : -1.0f;
        CGFloat newX = _swipeCellStartX + delta.x - xDirection * dragThreshold;
        [gesture.view setX:newX];
        
        // trigger vote if threshold crossed
        _thresholdCrossed = (fabsf(gesture.view.frame.origin.x) >= voteThreshhold);
        [self swipeVoteInteractionHandle:_thresholdCrossed inDirection:direction];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        _isDragging = NO;
        _swipeCellStartX = 0;
        
        _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[gesture.view]];
        CGFloat side = delta.x  > 0 ? 1.0f : -1.0f;
        if (side > 0)
        {
            [_collisionBehavior addBoundaryWithIdentifier:@"leftScreenEdge" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, 1136)];
        }
        else
        {
            [_collisionBehavior addBoundaryWithIdentifier:@"rightScreenEdge" fromPoint:CGPointMake(260, 0) toPoint:CGPointMake(260, 1136)];
        }
        [_animator addBehavior:_collisionBehavior];

        _gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        _gravityBehavior.gravityDirection = CGVectorMake(-3.0f * side, 0.0f);
        [_animator addBehavior:_gravityBehavior];

        _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[gesture.view] mode:UIPushBehaviorModeInstantaneous];
        _pushBehavior.magnitude = 0.0f;
        _pushBehavior.angle = 0.0f;
        _pushBehavior.pushDirection = CGVectorMake(velocity.x / 100.0f, 0.0f);
        _pushBehavior.active = YES;
        [_animator addBehavior:_pushBehavior];
        
        if (_thresholdCrossed)
        {
            [self.delegate swipeReleaseAnimationBackComplete:self inDirection:side > 0 ? RIGHT_DIRECTION : LEFT_DIRECTION];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !_isDragging;
}

@end



@interface BCStreamViewController ()<BCCellTopLayerContainerViewDelegate, MFMailComposeViewControllerDelegate>

@property (assign) int contentWidth;
@property (strong, nonatomic) UICollectionView *messageTable;
@property (strong, nonatomic) NSMutableArray *messages;
@property (assign) BOOL isSwipeLock;
@property (assign) BOOL isComposeMode;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIBarButtonItem *shareItem;

// Nasty Tutorial stuff
@property (assign) BOOL inTutorialMode;
@property (strong, nonatomic) UIImageView *top;
@property (strong, nonatomic) UIImageView *text;
@property (strong, nonatomic) UIImageView *bluebar;
@property (strong, nonatomic) UIImageView *gotit;

@end

@implementation BCStreamViewController

- (id)init
{
    self = [super init];
    return self;
}

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
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0.0, kCellEdgeInset, 0.0, kCellEdgeInset);
    _messageTable = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:_messageTable];
}

- (BCSecretModel*)addSecret:(NSString*)text
{
    __block BCSecretModel *secret = [[BCSecretModel alloc] init:text
                                                    withSid:(NSUInteger)0
                                                   withTime:0.0
                                                withTimeStr:@"now"
                                                 withAgrees:0
                                               withDisagree:0
                                                   withVote:VOTE_NONE];
    secret.isNew = YES;
    
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Create success");
        secret.sid = (NSUInteger)responseObject[@"sid"];
    };

    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in create: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] createSecret:secret.text success:success failure:failure];
    
    // Hope to get a new idea assigned on success callback. Maybe handle error cases better.
    [_messages insertObject:secret atIndex:0];
    return secret;
}

- (void)setupStreamBar
{
    self.navigationController.navigationBar.barTintColor = [[BCGlobalsManager globalsManager] blueColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Poly" size:18.0]}];
}

- (void)setupComposeBar
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [[BCGlobalsManager globalsManager] blueColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Poly" size:18.0]}];
}

- (void)getLatestPosts:(void (^)(void))callback
{
    void (^success)(NSMutableArray*) = ^(NSMutableArray *newSecrets) {
        NSLog(@"Get new posts");

        NSMutableArray *secretIndexPaths = [NSMutableArray array];
        for (int i=0; i < newSecrets.count; i++) {
            [secretIndexPaths addObject:[NSIndexPath indexPathForItem:i+1 inSection:0]];
        }

        NSMutableArray *newMessages = [NSMutableArray arrayWithArray:[newSecrets copy]];
        [newMessages addObjectsFromArray:[_messages copy]];
        _messages = newMessages;
        
        [_messageTable performBatchUpdates:^{
            [_messageTable insertItemsAtIndexPaths:secretIndexPaths];
        } completion:^(BOOL finished) {
        }];

        [_refreshControl endRefreshing];
        
        if (callback) {
            callback();
        }
        
        if (_messages.count >= kOldPostsBatchSize) {
            _messageTable.infiniteScrollingView.enabled = YES;
        }
    };

    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_refreshControl endRefreshing];
    };

    int topSid = 0;
    if (_messages.count) {
        topSid = (int)((BCSecretModel*)[_messages objectAtIndex:0]).sid;
    }
    [[BCAPIClient sharedClient] getLatestPosts:success failure:failure withTopSid:topSid];
}

- (void)getLatestNoscrollPosts
{
    void (^success)(NSMutableArray*) = ^(NSMutableArray *newSecrets) {
        NSLog(@"Get new posts and keep offset");
        
        NSMutableArray *secretIndexPaths = [NSMutableArray array];
        for (int i=0; i < newSecrets.count; i++) {
            [secretIndexPaths addObject:[NSIndexPath indexPathForItem:i+1 inSection:0]];
        }
        NSMutableArray *newMessages = [NSMutableArray arrayWithArray:[newSecrets copy]];
        [newMessages addObjectsFromArray:[_messages copy]];
        _messages = newMessages;
        
        CGFloat oldOffset = _messageTable.contentOffset.y;
        //NSLog(@"The old offset = %f", oldOffset);
        
        // Set content offset first before insert. This avoids the ui layout update back to the offset.
        [_messageTable setContentOffset:(CGPoint){_messageTable.contentOffset.x, oldOffset + kCellHeight * newSecrets.count} animated:NO];
        [_messageTable insertItemsAtIndexPaths:secretIndexPaths];

        [_refreshControl endRefreshing];
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_messageTable.pullToRefreshView stopAnimating];
    };
    
    int topSid = 0;
    if (_messages.count) {
        topSid = (int)((BCSecretModel*)[_messages objectAtIndex:0]).sid;
    }
    [[BCAPIClient sharedClient] getLatestPosts:success failure:failure withTopSid:topSid];
}

- (void)getOlderPosts
{
    NSLog(@"Entered getOlderPosts");
    
    if (_messages.count <= 0) {
        [_messageTable.infiniteScrollingView stopAnimating];
        return;
    }
    
    void (^success)(NSMutableArray*) = ^(NSMutableArray *newSecrets) {
        NSLog(@"Get older secrets");
        
        NSMutableArray *postIndexPaths = [NSMutableArray array];
        for (int i=0; i < newSecrets.count; i++) {
            [postIndexPaths addObject:[NSIndexPath indexPathForItem:(int)_messages.count + i inSection:0]];
        }
        
        [_messages addObjectsFromArray:[newSecrets copy]];
        
        [_messageTable performBatchUpdates:^{
            [_messageTable insertItemsAtIndexPaths:postIndexPaths];
        } completion:^(BOOL finished) {
        }];
        
        [_messageTable.infiniteScrollingView stopAnimating];
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_messageTable.infiniteScrollingView stopAnimating];
    };

    int lastSid = (int)((BCSecretModel*)[_messages objectAtIndex:_messages.count - 1]).sid;
    NSLog(@"the last sid = %d", lastSid);
    [[BCAPIClient sharedClient] getOlderPosts:success failure:failure withLastSid:lastSid];
}

- (void)getLatestPostsOnInit
{
    [self getLatestPosts:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    _isSwipeLock = NO;

	// Do any additional setup after loading the view.
    _messages = [[NSMutableArray alloc] init];
    _messageTable.dataSource = self;
    _messageTable.delegate = self;
    [_messageTable registerClass:[BCStreamCollectionViewCell class] forCellWithReuseIdentifier:@"BCStreamCollectionViewCell"];
    [_messageTable setShowsHorizontalScrollIndicator:NO];
    [_messageTable setShowsVerticalScrollIndicator:NO];
    _messageTable.backgroundColor = [UIColor whiteColor];
    _messageTable.alwaysBounceVertical = YES;

    [BCCellTopLayerContainerView setSwipeLocked:NO];

    // Handle pull to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(getLatestPostsOnInit)
              forControlEvents:UIControlEventValueChanged];
    [_messageTable addSubview:_refreshControl];
    
    // Handle infinite scroll
    __weak typeof(self) self_ = self;
    [_messageTable addInfiniteScrollingWithActionHandler:^{
        [self_ getOlderPosts];
    }];
    _messageTable.infiniteScrollingView.enabled = NO;
    
    // Handle share logic
    _shareItem = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(shareButtonTap)];
    [_shareItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Poly" size:16.0],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]}
                             forState:UIControlStateNormal];
    
    NSArray *actionButtonItems = @[_shareItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;

    [self setupStreamBar];
}

- (void)shareButtonTap
{
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *subject = [NSString stringWithFormat:@"Sharing this on the %@ Backchannel", [defaults objectForKey:kOrgNameKey]];
    [picker setSubject:subject];
    
    // Attach an image to the email
    UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, 1.5);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    [picker addAttachmentData:data mimeType:@"image/jpeg" fileName:@"backchannel"];
    
    // Fill out the email body text
    NSString *emailBody = @"There's an app called Backchannel where you can read and share thoughts anonymously with (and only with) other fellow employees.<br/><br/><a href='https://bckchannelapp.com/backend/share/'>Check out our %@ Backchannel</a>.";
    emailBody = [NSString stringWithFormat:emailBody, [defaults objectForKey:kOrgNameKey]];
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)showStreamTutorial
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isShowStreamTutorial = [[defaults objectForKey:kStreamTutorialKey] boolValue];
    if (isShowStreamTutorial) {
        return;
    }

    [UIView animateWithDuration:0.7 animations:^{
        _top.alpha = 1.0;
        _bluebar.alpha = 1.0;
        _text.alpha = 1.0;
        _gotit.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)setupStreamTutorial
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isShowStreamTutorial = [[defaults objectForKey:kStreamTutorialKey] boolValue];
    if (!isShowStreamTutorial) {
        
        if (IS_IPHONE_5) {
            _top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-568h-top.png"]];
            _text = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-568h-text.png"]];
            _bluebar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-568h-bluebar.png"]];
            _gotit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-568h-gotit.png"]];

        } else {
            _top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-top.png"]];
            _text = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-text.png"]];
            _bluebar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-bluebar.png"]];
            _gotit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeoverlay-gotit.png"]];
        }

        [self.view.window addSubview:_top];
        
        // UIImageView's by default set this to NO which allow touch to go through. By setting to YES
        // the UIImageView will consume the touch and not let it pass through.
        _top.userInteractionEnabled = YES;
        
        [_gotit setY:CGRectGetMaxY(self.view.window.bounds) - CGRectGetHeight(_gotit.bounds)];
        [self.view.window addSubview:_gotit];
        
        _gotit.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotGotItTap)];
        [_gotit addGestureRecognizer:tap];
        
        [_bluebar setY:CGRectGetMinY(_gotit.frame) - CGRectGetHeight(_bluebar.bounds)];
        [self.view.window addSubview:_bluebar];
        
        [_text setY:CGRectGetMinY(_bluebar.frame) - CGRectGetHeight(_text.bounds)];
        [self.view.window addSubview:_text];
        
        _inTutorialMode = YES;
        _messageTable.scrollEnabled = NO;
        _top.alpha = 0.0;
        _bluebar.alpha = 0.0;
        _text.alpha = 0.0;
        _gotit.alpha = 0.0;
        
    }
}

- (void)gotGotItTap
{
    [self unsetupStreamTutorial];
    [[BCGlobalsManager globalsManager] logFlurryEvent:@"got_it_tapped" withParams:nil];
    _inTutorialMode = NO;
    _messageTable.scrollEnabled = YES;
}

- (void)unsetupStreamTutorial
{
    [UIView animateWithDuration:0.5 animations:^{
        _top.alpha = 0.0;
        _bluebar.alpha = 0.0;
        _text.alpha = 0.0;
        _gotit.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_top removeFromSuperview];
        [_bluebar removeFromSuperview];
        [_text removeFromSuperview];
        [_gotit removeFromSuperview];
        _top = _bluebar = _text = _gotit = nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kStreamTutorialKey];
        [[BCGlobalsManager globalsManager] logFlurryEventTimed:@"entered_stream_view" withParams:nil];
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _messageTable.frame = self.view.bounds;
    [self setupStreamTutorial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getLatestPosts:^{
        [self showStreamTutorial];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[BCGlobalsManager globalsManager] logFlurryEventEndTimed:@"entered_stream_view" withParams:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Collection View Delegate (_messagesTable)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _messages.count + 1;
}


- (void)setSeparator:(BCStreamCollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    static const float separatorLineWidth = 80.0;
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.frame = CGRectMake(CGRectGetMidX(cell.contentView.bounds) - (separatorLineWidth / 2.0),
                                     CGRectGetMaxY(cell.contentView.bounds) - 1.0,
                                     separatorLineWidth,
                                     1.0);
    [cell.contentView addSubview:separatorLine];
    separatorLine.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    
    cell.separator = separatorLine;
}


- (void)prepareCell:(BCStreamCollectionViewCell*)cell collectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.item == 0) {
        BCCellComposeView *cv = [[BCCellComposeView alloc] init:CGRectGetWidth(cell.bounds)];
        [cell.contentView addSubview:cv];
        [self setSeparator:cell indexPath:indexPath];
        [cv placeIn:cell.contentView alignedAt:CENTER_LEFT];
        cell.cv = cv;
    } else {
        BCSecretModel *secretModel = [_messages objectAtIndex:indexPath.item - 1];
        float width = CGRectGetWidth(cell.bounds);
        CGSize size = (CGSize){width, CGRectGetHeight(cell.contentView.bounds)};
        BCCellBottomLayerContainerView *bcv = [[BCCellBottomLayerContainerView alloc] init:size];
        BCCellTopLayerContainerView *tcv = [[BCCellTopLayerContainerView alloc] init:secretModel withSize:size withBottomContainer:bcv];

        tcv.delegate = self;
        [tcv addSwipes];
        [cell.contentView addSubview:bcv];
        [cell.contentView addSubview:tcv];
        cell.cv = tcv;
        
        [bcv placeIn:cell.contentView alignedAt:CENTER];
        
        [self setSeparator:cell indexPath:indexPath];
    }
}

- (BCStreamCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    BCStreamCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCStreamCollectionViewCell" forIndexPath:indexPath];
    [self prepareCell:cell collectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath];
    return cell;
}

#pragma mark Collection View Scroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [BCCellTopLayerContainerView setSwipeLocked:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [BCCellTopLayerContainerView setSwipeLocked:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // This delegate gets called on init for some weird reason
    if (_messageTable.contentOffset.y > 0.0) {
        [BCCellTopLayerContainerView setSwipeLocked:YES];
    }
    
    

    //NSLog(@"The size of the content = %f", _messageTable.contentSize.height);
    //NSLog(@"The content offset = %f", _messageTable.contentOffset.y);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [BCCellTopLayerContainerView setSwipeLocked:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [BCCellTopLayerContainerView setSwipeLocked:NO];
}

#pragma mark Collection View Flow Layout Delegates

- (float)getComposeWindowHeight
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) -
            kKeyboardHeight -
            CGRectGetHeight(self.navigationController.navigationBar.bounds) -
            [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    float width = CGRectGetWidth([UIScreen mainScreen].bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    if (indexPath.item == 0) {
        CGSize headerCellSize = (CGSize){0.0, 0.0};
        if (_isComposeMode) {
            float composeCellHeight = [self getComposeWindowHeight];
            
            headerCellSize = (CGSize){width, composeCellHeight};
        } else {
            headerCellSize = (CGSize){width, kCellComposeHeight};
        }
        return headerCellSize;
    }
    
   return (CGSize){width, kCellHeight};
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kRowSpacing;
}

 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
 {
     return 0.0f;
 }

// Trial to fix compose -> stream transition

- (void)addSecretTextAndAnimate:(BCSecretModel*)model
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCCellTopLayerContainerView *tcv = (BCCellTopLayerContainerView*)cell.cv;
    tcv.textView.hidden = NO;
    
    float duration = (kCellHeight - kPublishBarHeight) / 864.0;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [tcv.textView placeIn:tcv alignedAt:CENTER];
                         [tcv.footerView setY:(CGRectGetMaxY(tcv.textView.frame) + kComposeTextViewFooterViewMargin)];
                     } completion:^(BOOL finished) {
                         NSLog(@"FINSIHED animation");
                     }];
}


- (void)addNewSecretToStream
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    
    // So new heights get calculated correctly in delegates
    _isComposeMode = NO;

    // Add to data source before indexpath insert
    BCSecretModel *secret = [self addSecret:ccv.textView.text];
    
    [_messageTable performBatchUpdates:^{
        [_messageTable insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:1 inSection:0]]];
    } completion:^(BOOL finished) {
        
        // Fuck around with cell frames to get what Vijay wants. Not even sure if animating these in layoutattributes
        // would have helped here.
        
        // 1. Hide the compose cell behind the nav by its height
        NSIndexPath *indexPath0 = [NSIndexPath indexPathForItem:0 inSection:0];
        BCStreamCollectionViewCell *topcell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath0];
        [topcell setY:-kCellComposeHeight];
        
        // 2. Now move the newly inserted cell to the top
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:1 inSection:0];
        BCStreamCollectionViewCell *newcell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath1];
        [newcell setY:0];
        [newcell setHeight:CGRectGetHeight(cell.frame) + kCellComposeHeight];
        
        // 3. Now animate them both down together to where they should be
        float duration = (kCellHeight - kPublishBarHeight) / 864.0;
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [topcell setY:0];
                             [newcell setY:kCellComposeHeight];
                         }
                         completion:^(BOOL finished){
                             [newcell setHeight:kCellHeight];
                         }];
        // 4. At the same time remove the compose window and animate the text parallax style to the center
        [self removeCompose];
        [self addSecretTextAndAnimate:secret];
    }];
}

- (void)nevermindTap:(id)sender
{
    _isComposeMode = NO;

    // NOTE: I need a performBatchUpdates here because the _isComposeMode = NO makes the delegates
    // return a new height for the compose cell, so performBatchUpdates will do the necessary
    // animations to bring the first cell back to its original spot.
    [_messageTable performBatchUpdates:^{
        [self removeCompose];
    } completion:^(BOOL finished) {
    }];
    
    [UIView transitionWithView:(UIButton*)sender
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ ((UIButton*)sender).highlighted = YES; }
                    completion:nil];
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:@"tap_nevermind" withParams:nil];
}

- (void)publishHoldDown:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    [ccv.bar.publishMeter.layer removeAllAnimations];
    //[ccv.bar setPublishPush];

    [[BCGlobalsManager globalsManager] logFlurryEventTimed:@"tap_publish" withParams:nil];

    [UIView animateWithDuration:kPublishPushDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [ccv.bar.publishMeter setX:0.0];
    } completion:^(BOOL finished) {
        if (finished) {
            ccv.bar.publishMeter.hidden = YES;
            [ccv.bar setPublishTutorialShown];
            [self addNewSecretToStream];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"state", @"finished", nil];
            [[BCGlobalsManager globalsManager] logFlurryEventEndTimed:@"tap_publish" withParams:params];
        } else {
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"state", @"unfinished", nil];
            [[BCGlobalsManager globalsManager] logFlurryEventEndTimed:@"tap_publish" withParams:params];
            [ccv.bar triggerPublishTutorial];
        }
    }];
}

- (void)publishHoldRelease:(id)sender
{

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;

    CALayer *layer = ccv.bar.publishMeter.layer.presentationLayer; // not entirely sure why I need to pick x out of this layer
    float maxX = CGRectGetMaxX(layer.frame);
    CGRect layerFrame = ccv.bar.publishMeter.layer.frame;
    layerFrame.origin.x = CGRectGetMinX(layer.frame);
    ccv.bar.publishMeter.layer.frame = layerFrame;

    [ccv.bar.publishMeter.layer removeAllAnimations];
    
    float duration = kPublishPushDuration * (maxX / CGRectGetWidth([UIScreen mainScreen].bounds));
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [ccv.bar.publishMeter setX:-CGRectGetWidth([UIScreen mainScreen].bounds)];
    } completion:^(BOOL finished) {
    }];

    [UIView transitionWithView:(UIButton*)sender
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ ((UIButton*)sender).highlighted = YES; }
                    completion:nil];
}

- (void)removeCompose
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    
    if (!_inTutorialMode) {
        _messageTable.scrollEnabled = YES;
    }
    
    [ccv removeFromSuperview];
    cell.ccv = nil;
    [ccv.textView resignFirstResponder];
    [self animateComposeCellTransitionToStream];
}

- (BCComposeContainerView*)setupCompose:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    _isComposeMode = YES;
    collectionView.scrollEnabled = NO;
    
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    BCComposeBarView *cbv = [[BCComposeBarView alloc] init:cell withHeight:kPublishBarHeight];
    BCComposeContainerView *ccv = [[BCComposeContainerView alloc] init:cell withHeight:[self getComposeWindowHeight] withBar:(BCComposeBarView*)cbv];

    ccv.hidden = YES;
    [cell addSubview:ccv];
    cell.ccv = ccv;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionView.collectionViewLayout;
    [ccv setX:-flowLayout.sectionInset.left];
    
    [cbv.nevermind addTarget:self action:@selector(nevermindTap:) forControlEvents:UIControlEventTouchUpInside];
    [cbv.publish addTarget:self action:@selector(publishHoldDown:) forControlEvents:UIControlEventTouchDown];
    [cbv.publish addTarget:self action:@selector(publishHoldRelease:) forControlEvents:UIControlEventTouchUpInside];
    
    ccv.textView.delegate = self;
    
    [self setupComposeBarAndKeyboard:ccv];
    return ccv;
}

- (void)setupComposeBarAndKeyboard:(BCComposeContainerView*)ccv
{
    ccv.textView.inputAccessoryView = ccv.bar;
    [ccv.textView becomeFirstResponder];
}

- (void)animateComposeCellTransitionToCompose
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    
    self.navigationItem.rightBarButtonItems = @[];
    float duration = (kCellHeight - kPublishBarHeight) / 864.0; // nasty calc off keboard rate 216pt / 0.25s
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cell.alpha = 0;
                         //[cell.separator setY:kCellHeight - 1];
                         //[cv setY:-kCellComposeHeight];
                     } completion:^(BOOL finished) {
                         cell.ccv.hidden = NO;
                     }];
    
}

- (void)animateComposeCellTransitionToStream
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCCellComposeView *cv = (BCCellComposeView*)cell.cv;
    
    self.navigationItem.rightBarButtonItems = @[_shareItem];
    
    float duration = (kCellHeight - kPublishBarHeight) / 864.0;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [cell.separator setY:kCellComposeHeight - 1];
                         [cv setY:0];
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item != 0 || _isComposeMode) {
        return;
    }
    
    [collectionView.collectionViewLayout invalidateLayout];
    [collectionView performBatchUpdates:^{
        [self animateComposeCellTransitionToCompose];
        [self setupCompose:collectionView indexPath:indexPath];
    } completion:^(BOOL finished) {
    }];
    
    [[BCGlobalsManager globalsManager] logFlurryEvent:@"tap_to_create" withParams:nil];
}

# pragma Text View Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    
   [ccv update:(int)textView.text.length];
}

# pragma Cell Top Container View Delegate
- (void)swipeReleaseAnimationBackComplete:(BCCellTopLayerContainerView*)containerView inDirection:(Direction)direction
{

    BCSecretModel *secretModel = containerView.secretModel;
    if (secretModel.vote != VOTE_NONE) {
        return;
    }
    
    if (direction == LEFT_DIRECTION) {
        secretModel.disagrees++;
        secretModel.vote = VOTE_DISAGREE;
        [[BCGlobalsManager globalsManager] logFlurryEvent:@"vote_plus_one" withParams:nil];
    } else if (direction == RIGHT_DIRECTION) {
        secretModel.agrees++;
        secretModel.vote = VOTE_AGREE;
        [[BCGlobalsManager globalsManager] logFlurryEvent:@"vote_neg_one" withParams:nil];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Vote success");
            secretModel.isVoted = YES;
        };
        
        FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error in vote: %@", error);
            NSLog(@"error code %d", (int)operation.response.statusCode);
            secretModel.isVoted = YES;
        };
        
        [[BCAPIClient sharedClient] setVote:secretModel withVote:secretModel.vote success:success failure:failure];
    });
    
    [containerView updateVoteView];
}

# pragma MFMail Compose Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail sending canceled");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"share_cancel" withParams:nil];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail sending saved");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"share_saved" withParams:nil];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sending sent");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"share_sent" withParams:nil];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sending failed");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"share_failed" withParams:nil];
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
