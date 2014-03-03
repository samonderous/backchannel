//
//  BCStreamViewController.m
//  FollowUp
//
//  Created by Saureen Shah on 10/3/13.
//  Copyright (c) 2013 Saureen Shah. All rights reserved.
//

#import "BCAppDelegate.h"
#import "BCStreamViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MCSwipeTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "BCModels.h"
#import "Utils.h"

static const float kCellHeight = 251.0f;
static const float kSecretFontSize = 16.0;
static const float kHeaderFooterTextFontSize = 12.0;
static const float kCellComposeHeight = 50.0f;
static const float kHeaderFooterHeight = 30.0;
static const float kContainerPadding = 30.0;
static const float kSentimentLength = 40.0;
static const float kRowSpacing = 0.0f;
static const float kKeyboardHeight = 216.0;
static const float kPublishBarHeight = 60.0;



@interface BCComposeBarView : UIView
@end

@interface BCCellComposeView : UIView
@end

@interface BCCellTopLayerTextView : UIView
+ (CGRect)getViewRect:(float)width withText:(NSString*)text;
@end

@interface BCCellTopLayerHeaderView : UIView
@end

@interface BCCellTopLayerFooterView : UIView
+ (float)getFooterHeight;
@end

@interface BCCellTopLayerContainerView : UIView<UIGestureRecognizerDelegate>
- (void)addSwipes;
+ (BOOL)isSwipeLocked;
@end

@interface BCCellBottomLayerContainerView : UIView
@end

@interface BCMainCollectionViewCell : UICollectionViewCell
@end



@interface BCComposeBarView ()
@end

@implementation BCComposeBarView

- (id)init:(float)width
{
    UIColor *creamColor = [UIColor colorWithRed:(189.0/255.0) green:(187.0/255.0) blue:(159.0/255.0) alpha:1.0];
    UIColor *creamBackgroundColor = [UIColor colorWithRed:(189.0/255.0) green:(187.0/255.0) blue:(159.0/255.0) alpha:0.05];
    UIColor *greenColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:1.0];
    UIColor *greenBackgroundColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96.0/255.0) alpha:0.05];
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kPublishBarHeight)];
    UIButton *nevermind = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, width / 2.0, kPublishBarHeight)];
    UIButton *publish = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nevermind.frame), 0.0, width / 2.0, kPublishBarHeight)];
    
    [self addSubview:nevermind];
    [self addSubview:publish];
    
    [nevermind setTitle:@"Nevermind" forState:UIControlStateNormal];
    [nevermind setTitleColor:creamColor forState:UIControlStateNormal];
    nevermind.backgroundColor = creamBackgroundColor;
    
    [publish setTitle:@"Publish" forState:UIControlStateNormal];
    [publish setTitleColor:greenColor forState:UIControlStateNormal];
    publish.backgroundColor = greenBackgroundColor;
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface BCCellComposeView ()
@end


@implementation BCCellComposeView

- (id)init:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kCellComposeHeight)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, kCellComposeHeight)];
    textLabel.text = @"Tap to say something...";
    textLabel.textColor = [UIColor grayColor];
    [textLabel setFont:[UIFont fontWithName:@"Arial" size:19]];
    //[textLabel placeIn:self alignedAt:CENTER_LEFT];
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

- (id)initWithText:(NSString*)text withWidth:(float)width
{
    self = [super init];
    UIFont *font = [UIFont systemFontOfSize:kSecretFontSize];
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:text
                                          attributes:@{ NSFontAttributeName:font}];
    CGRect rect = [BCCellTopLayerTextView getViewRect:width withText:text];
    TTTAttributedLabel *textLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    textLabel.attributedText = attributedText;
    textLabel.textColor = [UIColor darkGrayColor];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [textLabel setSize:rect.size];
    textLabel.numberOfLines = 0;
    [self addSubview:textLabel];
    [self setSizeWidth:width andHeight:CGRectGetHeight(rect)];
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

- (id)init:(int)agree withDisagree:(int)disagree withWidth:(float)width
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    UIFont *font = [UIFont fontWithName:@"Arial" size:kHeaderFooterTextFontSize];
    UILabel *voteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    voteLabel.text = [NSString stringWithFormat:@"%d agrees \u00B7 %d disagrees", agree, disagree];
    voteLabel.font = font;
    voteLabel.textColor = [UIColor darkGrayColor];
    voteLabel.numberOfLines = 1;
    
    [self addSubview:voteLabel];
    
    CGRect rect = [voteLabel.text boundingRectWithSize:(CGSize){CGFLOAT_MAX, CGFLOAT_MAX}
                                 options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName: font}
                                 context:nil];
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
    UIFont *font = [UIFont fontWithName:@"Arial" size:kHeaderFooterTextFontSize];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, kHeaderFooterHeight)];
    timeLabel.text = time;
    timeLabel.font = font;
    timeLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:timeLabel];
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

- (id)init:(float)width
{
    static const float padding = 4.0;
    self = [self initWithFrame:CGRectMake(0.0, 0.0, width, 0.0)];
    UIView *agreeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSentimentLength, kSentimentLength)];
    agreeView.layer.cornerRadius = CGRectGetWidth(agreeView.bounds) / 2.0;
    agreeView.layer.borderColor = [UIColor colorWithRed:(17.0/255.0) green:(156.0/255.0) blue:(96/255.0) alpha:1.0].CGColor;
    agreeView.layer.borderWidth = 2.0;
    
    UIView *disagreeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSentimentLength, kSentimentLength)];
    disagreeView.layer.cornerRadius = CGRectGetWidth(disagreeView.bounds) / 2.0;
    disagreeView.layer.borderColor = [UIColor colorWithRed:(204.0/255.0) green:(76.0/255.0) blue:(69/255.0) alpha:1.0].CGColor;
    disagreeView.layer.borderWidth = 2.0;

    [self addSubview:agreeView];
    [self addSubview:disagreeView];
    [self setHeight:(kSentimentLength + padding)];
    
    [agreeView placeIn:self alignedAt:CENTER_RIGTH];
    [disagreeView placeIn:self alignedAt:CENTER_LEFT];

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end


@interface BCCellTopLayerContainerView ()
@property (assign) BOOL isDragging;
@end

@implementation BCCellTopLayerContainerView

typedef enum Direction {
    LEFT_DIRECTION = 1,
    RIGHT_DIRECTION
} Direction;

static BOOL isSwipeLocked = NO;

- (id)init:(BCSecretModel*)secretModel withSize:(CGSize)size
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        static BOOL isSwipeLocked = NO;
    });

    _isDragging = NO;
    BOOL showHeader = secretModel.agrees || secretModel.disagrees;
    
    BCCellTopLayerTextView *textView = [[BCCellTopLayerTextView alloc] initWithText:secretModel.text withWidth:size.width];
    BCCellTopLayerFooterView *footerView = [[BCCellTopLayerFooterView alloc] init:secretModel.timeStr withWidth:size.width];
    BCCellTopLayerHeaderView *headerView = [[BCCellTopLayerHeaderView alloc] init:secretModel.agrees withDisagree:secretModel.disagrees withWidth:size.width];
    
    [self addSubview:textView];
    [self addSubview:footerView];
    
    [textView placeIn:self alignedAt:CENTER];
    [footerView placeIn:self alignedAt:CENTER];
    [headerView placeIn:self alignedAt:CENTER];
    
    static const float margin = 10.0;
    
    [footerView setY:(CGRectGetMaxY(textView.frame) + margin)];
    if (showHeader) {
        [self addSubview:headerView];
        [headerView setY:CGRectGetMinY(textView.frame) - CGRectGetHeight(footerView.bounds) - margin];
    }
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    
    return self;
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

- (void)handleSwipe:(UIPanGestureRecognizer*)gesture
{
    if (isSwipeLocked) {
        return;
    }

    BOOL overshot = NO;
    float threshhold = CGRectGetWidth(gesture.view.bounds) / 2.0;
    static const float cutOff = 40.0;
    
    UIGestureRecognizerState state = gesture.state;
    CGFloat width = CGRectGetWidth(gesture.view.bounds);
    CGPoint delta = [gesture translationInView:gesture.view.superview];
    CGPoint velocity = [gesture velocityInView:gesture.view.superview];
    Direction direction;
    
    if (velocity.x <= 0) {
        direction = LEFT_DIRECTION;
    } else {
        direction = RIGHT_DIRECTION;
    }
    
    CGFloat finalX = 0.0;
    if (velocity.x < -width) {
        finalX = -width + cutOff;
    } else if (velocity.x > width) {
        finalX = width - 20.0;
    } else {
        finalX = velocity.x;
    }
    
    float duration = 1.0;
    if (fabs(velocity.x) > width) {
        overshot = YES;
        duration = width / fabs(velocity.x) * 1.0;
    } else {
        duration = 1.0 * fabs(velocity.x) / width;
    }

    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        gesture.view.center = CGPointMake(gesture.view.center.x + delta.x, gesture.view.center.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        isSwipeLocked = YES;
        if (RIGHT_DIRECTION && gesture.view.frame.origin.x > threshhold) {
            finalX = width - 20.0;
            overshot = YES;
        } else if (LEFT_DIRECTION && gesture.view.frame.origin.x + width <= threshhold) {
            finalX = -width + cutOff;
            overshot = YES;
        }
        [UIView animateWithDuration:duration delay:0.0 options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             [gesture.view setX:finalX];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration: overshot ? 1.0 : duration delay:0.0 options: UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  [gesture.view setX:0.0];
                                              }
                                              completion:^(BOOL finished) {
                                                  isSwipeLocked = NO;
                                              }];
                         }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return !_isDragging;
}

@end


@interface BCMainCollectionViewCell ()
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation BCMainCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UIGestureRecognizer *recognizer in self.contentView.gestureRecognizers) {
        [self.contentView removeGestureRecognizer:recognizer];
    }
    
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    for (CALayer *layer in self.contentView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

@end


@interface BCStreamViewController ()

@property (assign) int contentWidth;
@property (strong, nonatomic) UICollectionView *messageTable;
@property (strong, nonatomic) NSMutableArray *messages;
@property (assign) BOOL isSwipeLock;
@property (assign) BOOL isComposeMode;

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
    layout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    _messageTable = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    [self.view addSubview:_messageTable];
}

- (void)setupMessages
{
    BCSecretModel *s1 = [[BCSecretModel alloc] init:@"Vijay is a problem child and I'm really really pissed off at him because he does really terible work and this is a test to see how terrible he really is." withTime:0.0 withAgrees:0 withDisagree:0];
    BCSecretModel *s2 = [[BCSecretModel alloc] init:@"VP of Product needs to go" withTime:0.0 withAgrees:1 withDisagree:0];
    BCSecretModel *s3 = [[BCSecretModel alloc] init:@"Andrew Langer is a complete goofball" withTime:0.0 withAgrees:0 withDisagree:2];
    BCSecretModel *s4 = [[BCSecretModel alloc] init:@"My manager should get fired" withTime:0.0 withAgrees:0 withDisagree:0];
    BCSecretModel *s5 = [[BCSecretModel alloc] init:@"This dude who sits next to me keeps farting. He needs to stop that." withTime:0.0 withAgrees:12 withDisagree:2];

    [_messages addObject:s1];
    [_messages addObject:s2];
    [_messages addObject:s3];
    [_messages addObject:s4];
    [_messages addObject:s5];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isSwipeLock = NO;

	// Do any additional setup after loading the view.
    _messages = [[NSMutableArray alloc] init];
    [self setupMessages];
    
    _messageTable.dataSource = self;
    _messageTable.delegate = self;
    [_messageTable registerClass:[BCMainCollectionViewCell class] forCellWithReuseIdentifier:@"BCMainCollectionViewCell"];
    [_messageTable setShowsHorizontalScrollIndicator:NO];
    [_messageTable setShowsVerticalScrollIndicator:NO];
    _messageTable.backgroundColor = [UIColor whiteColor];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(41.0/255.0)
                                                                           green:(99.0/255.0)
                                                                            blue:(120/255.0)
                                                                           alpha:1.0];
    // NOTE: UIBarStyleDefault for black status bar content
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BCCellTopLayerContainerView setSwipeLocked:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (indexPath.row == 0) {
        separatorLine.frame = CGRectMake(0.0,
                                         CGRectGetMaxY(contentView.bounds) - 1.0,
                                         CGRectGetWidth(contentView.bounds),
                                         1.0);
    } else {
        static const float separatorLineWidth = 80.0;
        separatorLine.frame = CGRectMake(CGRectGetMidX(contentView.bounds) - (separatorLineWidth / 2.0),
                                         CGRectGetMaxY(contentView.bounds) - 1.0,
                                         separatorLineWidth,
                                         1.0);
    }
    [contentView.layer addSublayer:separatorLine];
    separatorLine.backgroundColor = [UIColor grayColor].CGColor;
}



- (void)prepareCell:(UICollectionViewCell*)cell collectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        BCCellComposeView *cv = [[BCCellComposeView alloc] init:CGRectGetWidth(cell.bounds)];
        [cell.contentView addSubview:cv];
        [self setSeparator:cell.contentView indexPath:indexPath];
        [cv placeIn:cell.contentView alignedAt:CENTER_LEFT];
    } else {
        BCSecretModel *secretModel = [_messages objectAtIndex:indexPath.row - 1];
        float width = CGRectGetWidth(cell.bounds);
        
        BCCellBottomLayerContainerView *bcv = [[BCCellBottomLayerContainerView alloc] init:width];
        BCCellTopLayerContainerView *cv = [[BCCellTopLayerContainerView alloc] init:secretModel
                                                                           withSize:(CGSize){width,
                                                                               CGRectGetHeight(cell.contentView.bounds)}];
        [cv addSwipes];
        [cell.contentView addSubview:bcv];
        [cell.contentView addSubview:cv];
        
        [bcv placeIn:cell.contentView alignedAt:CENTER];
        
        [self setSeparator:cell.contentView indexPath:indexPath];
    }
    
}

- (BCMainCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    BCMainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCMainCollectionViewCell" forIndexPath:indexPath];
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
    return CGRectGetHeight([UIScreen mainScreen].bounds) - kKeyboardHeight - kPublishBarHeight -
            CGRectGetHeight(self.navigationController.navigationBar.bounds) -
            [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    float width = CGRectGetWidth([UIScreen mainScreen].bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
    if (indexPath.row == 0) {
        CGSize headerCellSize = (CGSize){0.0, 0.0};
        if (_isComposeMode) {
            float composeCellHeight = [self getComposeWindowHeight] + kPublishBarHeight;
            
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

- (void)setupComposeBar
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :
                                                                          [UIColor colorWithRed:(41.0/255.0)
                                                                                          green:(99.0/255.0)
                                                                                           blue:(120/255.0)
                                                                                          alpha:1.0]}];
}

- (void)setupCompose:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    [self setupComposeBar];
    BCMainCollectionViewCell *cell = (BCMainCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(cell.contentView.bounds),
                                                                  [self getComposeWindowHeight])];
    [cell prepareForReuse];
    [cell.contentView addSubview:tv];
    [tv becomeFirstResponder];
    
    BCComposeBarView *cbv = [[BCComposeBarView alloc] init:CGRectGetWidth([UIScreen mainScreen].bounds)];
    [cbv setY:CGRectGetMaxY(tv.frame)];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionView.collectionViewLayout;
    [cbv setX:-flowLayout.sectionInset.left];
    [cell addSubview:cbv];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        return;
    }
  
    [collectionView performBatchUpdates:^{
        // append your data model to return a larger size for
        // cell at this index path
        _isComposeMode = YES;
        [collectionView.collectionViewLayout invalidateLayout];
        [self setupCompose:collectionView indexPath:indexPath];
    } completion:^(BOOL finished) {
        
    }];
}

@end
