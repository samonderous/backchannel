//
//  BCStreamViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 10/3/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
static const float kPublishPushDuration = 1.0;
static const float kComposeTextViewFooterViewMargin = 10.0;
static const int kMaxStreamSize = 50;
static const int kTopDividerLineWidth = 50;
static const float kNewPostStartPositionY = 25.0;

@interface BCComposeContainerView ()
@property (strong, nonatomic) TTTAttributedLabel *charCountLabel;
@property (strong, nonatomic) UIView *publishMeter;
@end

@implementation BCComposeContainerView

- (id)init:(BCStreamCollectionViewCell*)cell withHeight:(float)height
{
    //NSLog(@"%@",[NSThread callStackSymbols]);
    UIColor *fontColor = [[BCGlobalsManager globalsManager] fontColor];
    
    float width = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kPublishBarHeight)];
    _nevermind = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, width / 2.0, kPublishBarHeight)];
    _publish = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nevermind.frame), 0.0, width / 2.0, kPublishBarHeight)];
    
    [_nevermind setTitle:@"Nevermind" forState:UIControlStateNormal];
    [_nevermind setTitleColor:[[BCGlobalsManager globalsManager] creamColor] forState:UIControlStateNormal];
    _nevermind.backgroundColor = [[BCGlobalsManager globalsManager] creamBackgroundColor];
    _nevermind.titleLabel.font = [UIFont fontWithName:@"Tisa Pro" size:18.0];
    
    [_publish setTitle:@"Publish" forState:UIControlStateNormal];
    [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenColor] forState:UIControlStateNormal];
    _publish.backgroundColor = [[BCGlobalsManager globalsManager] greenBackgroundColor];
    _publish.titleLabel.font = [UIFont fontWithName:@"Tisa Pro" size:18.0];
    _publish.userInteractionEnabled = NO;
    
    _charCountLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [_publish addSubview:_charCountLabel];

    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:15.0];
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
    [_charCountLabel placeIn:_publish alignedAt:CENTER_RIGTH withMargin:0];
    
    UIFont *textFont = [[BCGlobalsManager globalsManager] composeFont];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cell.frame),
                                                             0.0,
                                                             CGRectGetWidth(cell.contentView.bounds),
                                                             height - kPublishBarHeight)];
    [[UITextView appearance] setTintColor:[[BCGlobalsManager globalsManager] blueColor]];
    _textView.scrollEnabled = NO;
    //_textView.contentInset = UIEdgeInsetsMake(-14, -4, 0, 0); // Removes all padding top and left.
    _textView.contentInset = UIEdgeInsetsMake(11, -4, 0, 0); // To cancel out the textview top padding by default
    _textView.font = textFont;
    //[_textView debug];
    _publishMeter = [[UIView alloc] initWithFrame:CGRectMake(-width, 0.0, width, 1.0)];
    _publishMeter.backgroundColor = [[BCGlobalsManager globalsManager] greenColor];
    
    [self addSubview:_textView];
    [bar addSubview:_nevermind];
    [bar addSubview:_publish];
    [self addSubview:_publishMeter];
    [self addSubview:bar];
    [bar setY:CGRectGetMaxY(_textView.frame)];

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
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:15.0];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]
                                initWithString:_textView.text
                                attributes:@{ NSFontAttributeName:[[BCGlobalsManager globalsManager] composeFont]}];
    if (count > kMaxCharCount) {
        fontColor = [[BCGlobalsManager globalsManager] redColor];
        _publish.backgroundColor = [[BCGlobalsManager globalsManager] blackPublishBackgroundColor];
        [_publish setTitleColor:[[BCGlobalsManager globalsManager] blackPublishFontColor] forState:UIControlStateNormal];
        _publish.userInteractionEnabled = NO;
        [mutableAttributedString addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] redColor] range: NSMakeRange(kMaxCharCount, count - kMaxCharCount)];
        _textView.attributedText = mutableAttributedString;
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


- (void)setPublishPush
{
    [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenPublishColor] forState:UIControlStateNormal];
}

- (void)unsetPublishPush
{
    [_publish setTitleColor:[[BCGlobalsManager globalsManager] greenColor] forState:UIControlStateNormal];
}

@end


@interface BCCellComposeView ()
@end


@implementation BCCellComposeView

- (id)init:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kCellComposeHeight)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, kCellComposeHeight)];
    textLabel.text = @"Tap to say something new...";
    textLabel.textColor = [[BCGlobalsManager globalsManager] emptyPostCellColor];
    textLabel.font = [UIFont fontWithName:@"Tisa Pro" size:18.0];
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
    textLabel.font = [UIFont fontWithName:@"Tisa Pro" size:18.0];;
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
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:12.0];
    NSString *voteText = [NSString stringWithFormat:@"%d agrees \u00B7 %d disagrees", (int)model.agrees, (int)model.disagrees];
    NSRange range = [voteText rangeOfString:@"\u00B7"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                                 initWithString:voteText
                                                 attributes:@{ NSFontAttributeName:font,
                                                               NSForegroundColorAttributeName: [[BCGlobalsManager globalsManager] creamColor]}];
    
    if (model.vote == VOTE_AGREE) {
        [attributedText addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] greenColor]
                               range: NSMakeRange(0, range.location - 1)];
    } else if (model.vote == VOTE_DISAGREE) {
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
    UIFont *font = [UIFont fontWithName:@"Tisa Pro" size:12.0];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    timeLabel.text = time;
    timeLabel.font = font;
    timeLabel.textColor = [[BCGlobalsManager globalsManager] blackTimestampColor];
    [self addSubview:timeLabel];
    CGRect rect = [timeLabel.text boundingRectWithSize:(CGSize){CGFLOAT_MAX, kHeaderFooterHeight}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: font}
                                               context:nil];
    [timeLabel setWidth:rect.size.width];
    [timeLabel placeIn:self alignedAt:CENTER];
    
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
    _isDragging = NO;

    _textView = [[BCCellTopLayerTextView alloc] initWithText:secretModel withWidth:size.width];
    _footerView = [[BCCellTopLayerFooterView alloc] init:secretModel.timeStr withWidth:size.width];

    [self addSubview:_textView];
    [self addSubview:_footerView];
    [self addVoteViews];
    
    [_footerView placeIn:self alignedAt:CENTER];
    [_textView placeIn:self alignedAt:CENTER];
    
    if (secretModel.isNew) {
        [_textView setY:kNewPostStartPositionY];
        secretModel.isNew = NO;
        NSLog(@"After isnew in textvie create");
    }

    [_footerView setY:(CGRectGetMaxY(_textView.frame) + kComposeTextViewFooterViewMargin)];
    
    if (_secretModel.vote != VOTE_NONE) {
        [self updateVoteView];
    }
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}


- (void)addVoteViews
{
    self.clipsToBounds = NO;
    
    _agreeContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _disagreeContainer = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    UILabel *agreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    agreeLabel.font = [UIFont fontWithName:@"Tisa Pro" size:36.0];
    agreeLabel.text = @"1";
    agreeLabel.textColor = [[BCGlobalsManager globalsManager] greenColor];
    [agreeLabel sizeToFit];
    agreeLabel.clipsToBounds = NO;
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    plusLabel.font = [UIFont fontWithName:@"Tisa Pro" size:24.0];
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
    disagreeLabel.font = [UIFont fontWithName:@"Tisa Pro" size:36.0];
    disagreeLabel.text = @"1";
    disagreeLabel.textColor = [[BCGlobalsManager globalsManager] redColor];
    [disagreeLabel sizeToFit];
    disagreeLabel.clipsToBounds = NO;
    UILabel *minusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _size.width, _size.height)];
    minusLabel.font = [UIFont fontWithName:@"Tisa Pro" size:24.0];
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
    
    //[_agreeContainer debug];
    //[_disagreeContainer debug];
    _agreeContainer.clipsToBounds = NO;
    _disagreeContainer.clipsToBounds = NO;
    
    //NSLog(NSStringFromCGRect(_agreeContainer.frame));
    //NSLog(NSStringFromCGRect(_disagreeContainer.frame));
}

- (void)updateVoteView
{
    static const float margin = 10.0;
    [_headerView removeFromSuperview];
    _headerView = [[BCCellTopLayerHeaderView alloc] init:_secretModel withWidth:_size.width];
    [_headerView placeIn:self alignedAt:CENTER];
    [self addSubview:_headerView];
    [_headerView setY:CGRectGetMinY(_textView.frame) - CGRectGetHeight(_footerView.bounds) - margin];
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
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
    
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
            [_agreeContainer placeIn:bcv alignedAt:CENTER_LEFT];
            [self animateVoteInteraction:_agreeContainer inDirection:RIGHT_DIRECTION];
        }
        if (direction == LEFT_DIRECTION && _disagreeContainer.superview != bcv) {
            [_disagreeContainer removeFromSuperview];
            [bcv addSubview:_disagreeContainer];
            [_disagreeContainer placeIn:bcv alignedAt:CENTER_RIGTH];
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
    if (isSwipeLocked || _secretModel.vote != VOTE_NONE) {
        return;
    }

    float width = CGRectGetWidth(gesture.view.bounds);
    static const float cutOffPercentage = 0.7;
    static const float resistPan = 10.0;
    const float fullDuration = 0.7;
    float threshhold = CGRectGetWidth(_agreeContainer.bounds) + kCellEdgeInset;
    float totalSwipeDistance = width * cutOffPercentage;
    
    UIGestureRecognizerState state = gesture.state;
    CGPoint delta = [gesture translationInView:gesture.view.superview];
    CGPoint velocity = [gesture velocityInView:gesture.view.superview];
    Direction direction;
  
    direction = [self getSwipeDirection:velocity];

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        
        if (fabsf(gesture.view.frame.origin.x) >= threshhold) {
            [self swipeVoteInteractionHandle:YES inDirection:direction];
        } else {
            [self swipeVoteInteractionHandle:NO inDirection:direction];
        }
        
        if (fabsf(gesture.view.frame.origin.x) >= totalSwipeDistance) {
            gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y);
            [gesture setTranslation:CGPointZero inView:self.superview];
        } else {
            gesture.view.center = CGPointMake(gesture.view.center.x + delta.x, gesture.view.center.y);
            [gesture setTranslation:CGPointZero inView:self.superview];
        }
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        
        float finalX = 0.0;
        float duration = 0.0;
        if (fabsf(gesture.view.frame.origin.x) < resistPan) {
            finalX = 0.0;
        } else if (fabsf(gesture.view.frame.origin.x) > threshhold || fabsf(velocity.x) > 1000.0) {
            finalX = (width * cutOffPercentage) * (gesture.view.frame.origin.x < 0.0 ? -1.0 : 1.0);
            duration = fullDuration * ((fabsf(finalX - gesture.view.frame.origin.x) / totalSwipeDistance));
        } else {
            duration = fullDuration * ((fabsf(finalX - gesture.view.frame.origin.x) / totalSwipeDistance));
        }

        [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [gesture.view setX:finalX];
                         }
                         completion:^(BOOL finished) {
                            // Slide back to origin
                             isSwipeLocked = NO;
                             [UIView animateWithDuration:(fullDuration * (fabsf(gesture.view.frame.origin.x) / totalSwipeDistance))
                                                  delay:0.0
                                                options: UIViewAnimationOptionCurveLinear
                                             animations:^{
                                                 [gesture.view setX:0.0];
                                             }
                                             completion:^(BOOL finished) {
                                                 if (finalX) {
                                                     [self.delegate swipeReleaseAnimationBackComplete:self inDirection: direction];
                                                     _agreeContainer.alpha = 1;
                                                     _disagreeContainer.alpha = 1;
                                                 }
                                             }];
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !_isDragging;
}

@end



@interface BCStreamViewController ()<BCCellTopLayerContainerViewDelegate>

@property (assign) int contentWidth;
@property (strong, nonatomic) UICollectionView *messageTable;
@property (strong, nonatomic) NSMutableArray *messages;
@property (assign) BOOL isSwipeLock;
@property (assign) BOOL isComposeMode;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation BCStreamViewController

- (id)init
{
    self = [super init];
    //self.edgesForExtendedLayout = UIRectEdgeAll;
    //self.automaticallyAdjustsScrollViewInsets = YES;
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
    _messageTable = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    [self.view addSubview:_messageTable];
    self.view.backgroundColor = [UIColor whiteColor];
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
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Tisa Pro" size:18.0]}];
}

- (void)setupComposeBar
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [[BCGlobalsManager globalsManager] blueColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Tisa Pro" size:18.0]}];
}

- (void)getLatestSecrets
{
    void (^success)(NSMutableArray*) = ^(NSMutableArray *newSecrets) {
        NSLog(@"Get new secrets");

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
    };

    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_refreshControl endRefreshing];
    };
    
    int topSid = 0;
    if (_messages.count) {
        topSid = ((BCSecretModel*)[_messages objectAtIndex:0]).sid;
    }
    [[BCAPIClient sharedClient] getLatestSecrets:success failure:failure withTopSid:topSid];
}

- (void)getSecrets
{
    void (^success)(NSMutableArray*) = ^(NSMutableArray *secrets) {
        NSLog(@"Get stream success");
        _messages = secrets;
        [_messageTable reloadData];
        [_refreshControl endRefreshing];
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_refreshControl endRefreshing];
    };
    
    [[BCAPIClient sharedClient] getStream:success failure:failure];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isSwipeLock = NO;

	// Do any additional setup after loading the view.
    _messages = [[NSMutableArray alloc] init];
    _messageTable.dataSource = self;
    _messageTable.delegate = self;
    [_messageTable registerClass:[BCStreamCollectionViewCell class] forCellWithReuseIdentifier:@"BCStreamCollectionViewCell"];
    [_messageTable setShowsHorizontalScrollIndicator:NO];
    [_messageTable setShowsVerticalScrollIndicator:NO];
    _messageTable.backgroundColor = [UIColor whiteColor];

    [BCCellTopLayerContainerView setSwipeLocked:NO];

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(getLatestSecrets)
             forControlEvents:UIControlEventValueChanged];

    [_messageTable addSubview:_refreshControl];
    _messageTable.alwaysBounceVertical = YES;
    
    [self setupStreamBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getSecrets];
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


- (void)setSeparator:(UIView*)contentView indexPath:(NSIndexPath*)indexPath
{
    CALayer *separatorLine = [[CALayer alloc] init];
    if (indexPath.item == 0) {
        separatorLine.frame = CGRectMake((CGRectGetWidth(contentView.bounds) - kTopDividerLineWidth) / 2.0,
                                         CGRectGetMaxY(contentView.bounds) - 1.0,
                                         kTopDividerLineWidth,
                                         1.0);
        
    } else {
        static const float separatorLineWidth = 80.0;
        separatorLine.frame = CGRectMake(CGRectGetMidX(contentView.bounds) - (separatorLineWidth / 2.0),
                                         CGRectGetMaxY(contentView.bounds) - 1.0,
                                         separatorLineWidth,
                                         1.0);
    }
    [contentView.layer addSublayer:separatorLine];
    separatorLine.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor].CGColor;
}



- (void)prepareCell:(BCStreamCollectionViewCell*)cell collectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.item == 0) {
        BCCellComposeView *cv = [[BCCellComposeView alloc] init:CGRectGetWidth(cell.bounds)];
        [cell.contentView addSubview:cv];
        [self setSeparator:cell.contentView indexPath:indexPath];
        [cv placeIn:cell.contentView alignedAt:CENTER_LEFT];
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
        cell.tcv = tcv;
        
        [bcv placeIn:cell.contentView alignedAt:CENTER];
        
        [self setSeparator:cell.contentView indexPath:indexPath];
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
    return CGRectGetHeight([UIScreen mainScreen].bounds) - kKeyboardHeight - CGRectGetHeight(self.navigationController.navigationBar.bounds) - [UIApplication sharedApplication].statusBarFrame.size.height;
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
    BCCellTopLayerContainerView *tcv = cell.tcv;

    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_messageTable setY:0.0];
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
    BCSecretModel *secret = [self addSecret:ccv.textView.text];
    [_messageTable performBatchUpdates:^{
        //[_messageTable.collectionViewLayout invalidateLayout];
        //[_messageTable reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [_messageTable insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:1 inSection:0]]];
        [self removeCompose];
        [_messageTable setY:CGRectGetMinY(_messageTable.frame) - kCellComposeHeight];
    } completion:^(BOOL finished) {
        [self addSecretTextAndAnimate:secret];
    }];
}

- (void)nevermindTap
{
    [_messageTable performBatchUpdates:^{
        [self removeCompose];
    } completion:^(BOOL finished) {
    }];
}

- (void)publishHoldDown
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    [ccv.publishMeter.layer removeAllAnimations];
    [ccv setPublishPush];
    [UIView animateWithDuration:kPublishPushDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [ccv.publishMeter setX:0.0];
    } completion:^(BOOL finished) {
        if (finished) {
            [self addNewSecretToStream];
        } else {
            //[ccv.publishMeter setX:-CGRectGetWidth([UIScreen mainScreen].bounds)];
        }
    }];
}

- (void)publishHoldRelease
{

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    
    CALayer *layer = ccv.publishMeter.layer.presentationLayer; // not entirely sure why I need to pick x out of this layer
    float maxX = CGRectGetMaxX(layer.frame);
    CGRect layerFrame = ccv.publishMeter.layer.frame;
    layerFrame.origin.x = CGRectGetMinX(layer.frame);
    ccv.publishMeter.layer.frame = layerFrame;

    [ccv.publishMeter.layer removeAllAnimations];
    
    float duration = kPublishPushDuration * (maxX / CGRectGetWidth([UIScreen mainScreen].bounds));
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [ccv.publishMeter setX:-CGRectGetWidth([UIScreen mainScreen].bounds)];
    } completion:^(BOOL finished) {
    }];
    [ccv unsetPublishPush];
}

- (void)removeCompose
{
    //[self setupStreamBar];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[_messageTable cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = cell.ccv;
    
    _isComposeMode = NO;
    _messageTable.scrollEnabled = YES;
    [ccv removeFromSuperview];
    [ccv.textView resignFirstResponder];
}

- (void)setupCompose:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    _isComposeMode = YES;
    [collectionView.collectionViewLayout invalidateLayout];
    collectionView.scrollEnabled = NO;
    
    BCStreamCollectionViewCell *cell = (BCStreamCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    BCComposeContainerView *ccv = [[BCComposeContainerView alloc] init:cell withHeight:[self getComposeWindowHeight]];
    [cell addSubview:ccv];
    cell.ccv = ccv;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionView.collectionViewLayout;
    [ccv setX:-flowLayout.sectionInset.left];
    
    [ccv.nevermind addTarget:self action:@selector(nevermindTap) forControlEvents:UIControlEventTouchUpInside];
    [ccv.publish addTarget:self action:@selector(publishHoldDown) forControlEvents:UIControlEventTouchDown];
    [ccv.publish addTarget:self action:@selector(publishHoldRelease) forControlEvents:UIControlEventTouchUpInside];
    
    [ccv.textView becomeFirstResponder];
    ccv.textView.delegate = self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item != 0 || _isComposeMode) {
        return;
    }

    [collectionView performBatchUpdates:^{
        [self setupCompose:collectionView indexPath:indexPath];
    } completion:^(BOOL finished) {
        
    }];
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
    } else if (direction == RIGHT_DIRECTION) {
        secretModel.agrees++;
        secretModel.vote = VOTE_AGREE;
    }

    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Vote success");
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in vote: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] setVote:secretModel withVote:secretModel.vote success:success failure:failure];

    [containerView updateVoteView];
}



@end
