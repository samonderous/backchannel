//
//  BCCommentsViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 9/2/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCCommentsViewController.h"
#import "BCStreamViewController.h"
#import "BCGlobalsManager.h"
#import "Utils.h"
#import "BCAPIClient.h"


static const CGFloat kCommentPadding = 30.0;

@interface BCCommentPlaceHolder : UIView

@property (strong, nonatomic) UILabel *noCommentsYet;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation BCCommentPlaceHolder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _noCommentsYet = [[UILabel alloc] init];
        [self addSubview:_noCommentsYet];
        _noCommentsYet.text = @"No comments yet. Any thoughts?";
        _noCommentsYet.textColor = [[BCGlobalsManager globalsManager] blackDividerColor];
        _noCommentsYet.font = [UIFont fontWithName:@"Poly" size:16.0];
        [_noCommentsYet sizeToFit];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_noCommentsYet placeIn:self alignedAt:CENTER];
    [_activityIndicator placeIn:self alignedAt:CENTER];
}

- (void)showWaiting
{
    _noCommentsYet.hidden = YES;
    [_activityIndicator startAnimating];
    _activityIndicator.hidden = NO;
}

- (void)showNoCommentsYet
{
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    _noCommentsYet.hidden = NO;
}

@end


@interface BCCommentsViewPostCell : UICollectionViewCell
@end

@implementation BCCommentsViewPostCell

- (void)prepareForReuse
{
    [super prepareForReuse];
 
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
}

@end


@interface BCCommentsViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *commentText;
@property (strong, nonatomic) UIView *separator;
@end

@interface BCCommentsViewCell ()

@end

@implementation BCCommentsViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)prepareForReuse
{
    [_separator removeFromSuperview];
    _separator = nil;
}

@end

@interface BCCommentsBar : UIView

@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentsTextView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation BCCommentsBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

// Need this because IBOutlets are not setup yet at initWithCoder time. This is called at the end of the unarchive of nib.
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_sendButton addSubview:_activityIndicator];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_activityIndicator placeIn:_sendButton alignedAt:CENTER];

}

- (void)showIndicator
{
    [_sendButton setTitle:@"" forState:UIControlStateNormal];
    [_sendButton setTitle:@"" forState:UIControlStateHighlighted];
    [_activityIndicator startAnimating];
}

- (void)hideIndicator
{
    [_sendButton setTitle:@"Post" forState:UIControlStateNormal];
    [_sendButton setTitle:@"Post" forState:UIControlStateHighlighted];
    [_activityIndicator stopAnimating];
}

@end


@interface BCCommentsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HPGrowingTextViewDelegate>
@property (strong, nonatomic) UICollectionView *comments;
@property (strong, nonatomic) BCCommentsBar *bar;
@property (strong, nonatomic) BCCommentPlaceHolder *placeHolder;

@property (assign) BOOL inEditMode;
@property (assign) CGFloat lastContentOffset;
@property (strong, nonatomic) NSMutableArray *commentModels;

@end

@implementation BCCommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupMockComments
{
    NSArray *commentStr = @[@"This is to test whether this thing works with some mock comments.",
                            @"This truly is a great company! I wish I continued working here.",
                            @"Now that this is over this is so amazing that this is great.",
                            @"LOL!",
                            @"For once all of this controversy has ended and I'm glad I want to see some top management getinvolved b/c right now I'm not seeing very much progress. It's great to see what's happening otherwise because you never know. Otherwise bad things will happen. And this is just a test to see if a long comment works :)",
                            @"I like how xcode wraps text and indents it from where you started writing your string in the editor. This never used to happen before. Might be a new thing. Before it'd wrap to the start of the next line which was annoying."];
    _commentModels = [[NSMutableArray alloc] init];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[0]]];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[1]]];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[2]]];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[3]]];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[4]]];
    [_commentModels addObject:[[BCCommentModel alloc] init:commentStr[5]]];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}


- (void)setupCommentsBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Poly" size:28.0], NSFontAttributeName,
      nil] forState:UIControlStateNormal];
    self.navigationController.navigationBar.barTintColor = [[BCGlobalsManager globalsManager] blueColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName: [UIFont fontWithName:@"Poly" size:18.0]}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self setupMockComments];
    _commentModels = [[NSMutableArray alloc] init];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _bar = (BCCommentsBar*)[[NSBundle mainBundle] loadNibNamed:@"BCCommentsBar" owner:self options:nil][0];
    [self.view addSubview:_bar];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = kCommentPadding;
    _comments = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:_comments];
    _comments.alwaysBounceVertical = YES;

    _placeHolder = [[BCCommentPlaceHolder alloc] initWithFrame:CGRectZero];
    [_comments addSubview:_placeHolder];
    
    _comments.delegate = self;
    _comments.dataSource = self;
    _bar.commentsTextView.delegate = self;
    _bar.commentsTextView.font = [UIFont fontWithName:@"Poly" size:15.0];
    _bar.commentsTextView.placeholder = @"What do you think?";
    _bar.commentsTextView.placeholderColor = [[BCGlobalsManager globalsManager] emptyPostCellColor];
    CALayer *topLine = [[CALayer alloc] init];
    topLine.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(_bar.bounds), 0.5);
    topLine.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
    [_bar.layer addSublayer:topLine];
    [_comments registerNib:[UINib nibWithNibName:@"BCCommentsCell" bundle:nil] forCellWithReuseIdentifier:@"BCCommentsCollectionViewCell"];
    [_comments registerClass:[BCCommentsViewPostCell class] forCellWithReuseIdentifier:@"BCCommentsCollectionViewPostCell"];
    _comments.backgroundColor = [UIColor whiteColor];
    [_bar.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_bar.sendButton setTitleColor:[[BCGlobalsManager globalsManager] greenColor] forState:UIControlStateNormal];
    _bar.sendButton.titleLabel.font = [UIFont fontWithName:@"Poly" size:15.0];
    
    [self.view bringSubviewToFront:_bar];

    [self registerForKeyboardNotifications];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[self.view addSubview:backButton];
    [backButton setTitle:@"←" forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(13, 14, 13, 14)];
    [backButton sizeToFit];
    [backButton setX:6];
    [backButton setY:22];
    backButton.titleLabel.font = [UIFont fontWithName:@"Poly" size:28.0];
    [backButton setTitleColor:[[BCGlobalsManager globalsManager] blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBackButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    
    _inEditMode = NO;
    _lastContentOffset = _comments.contentOffset.y;

    //[_comments debug];
    //[_bar debug];
    //[_post addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    [Utils debugRect:self.view withName:@"view"];
    [self setupCommentsBar];
    
    _bar.commentsTextView.frame = CGRectMake(30.0 - 4.0, (_bar.frame.size.height - _bar.commentsTextView.frame.size.height) / 2.0, _bar.commentsTextView.frame.size.width, _bar.commentsTextView.frame.size.height);
}

- (void)getComments:(void (^)(void))callback
{
    void (^success)(NSMutableArray*) = ^(NSMutableArray *comments) {
        
        if (comments.count == 0) {
            [_placeHolder showNoCommentsYet];
        } else {
            [_placeHolder removeFromSuperview];
            _commentModels = comments;
            [_comments reloadData];
        }
        
        if (callback) {
            callback();
        }
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
    };
    
    [[BCAPIClient sharedClient] fetchCommentsFor:_secretModel success:success failure:failure];
    [_placeHolder showWaiting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_comments setY:0.0];
    [_comments setSize:(CGSize){[UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(_bar.bounds)}];
    [_bar setY:CGRectGetMaxY(_comments.frame)];
    
    [_placeHolder setY:CGRectGetHeight(_content.bounds)];
    [_placeHolder setSize:(CGSize){CGRectGetWidth(_comments.bounds),
        CGRectGetHeight(_comments.bounds) - CGRectGetHeight(_content.bounds) - CGRectGetHeight(_bar.bounds)}];
    [_placeHolder layoutIfNeeded];

    [self getComments:nil];
}

// Debug frame changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null]) {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
    }
}

- (void)handleBackButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollToBottom
{
   NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:[_comments numberOfItemsInSection:0] - 1 inSection:0];
   [_comments scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void)addComment:(NSString*)commentString
{
    BCCommentModel *commentModel = [[BCCommentModel alloc] init:commentString];
    [_commentModels addObject:commentModel];
    _bar.commentsTextView.text = @"";
}

- (void)sendTapped:(id)sender
{
    NSString *commentString = [[_bar.commentsTextView.text copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([commentString  isEqual: @""]) {
        return;
    }
    
    SuccessCallback success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [_bar hideIndicator];
        [_placeHolder removeFromSuperview];
        [self addComment:commentString];
        [_comments performBatchUpdates:^{
            [_comments insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:_commentModels.count - 1 + 1 inSection:0]]];
        } completion:^(BOOL finished) {
            [self scrollToBottom];
            [[BCGlobalsManager globalsManager] logFlurryEvent:kEventPostedComment withParams:nil];
        }];
    };
    
    FailureCallback failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error in get stream: %@", error);
        NSLog(@"error code %d", (int)operation.response.statusCode);
        [_bar hideIndicator];
    };
    
    [[BCAPIClient sharedClient] createComment:commentString onSecret:_secretModel success:success failure:failure];
    [_bar showIndicator];
}

/*
- (BOOL)prefersStatusBarHidden {
    return YES;
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
     */
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [_comments setHeight:(CGRectGetHeight(self.view.bounds) - keyboardSize.height - CGRectGetHeight(_bar.bounds))];
    [self scrollToBottom];
}

- (void)keyboardWillBeShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_bar setY:(CGRectGetHeight(self.view.bounds) - keyboardSize.height - CGRectGetHeight(_bar.bounds))];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         _inEditMode = YES;
                     }];
    [[BCGlobalsManager globalsManager] logFlurryEvent:kEventTappedCommentField withParams:nil];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    
    [_comments setHeight:(CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_bar.bounds))];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_bar setY:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_bar.bounds)];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         _inEditMode = NO;
                     }];
}

#pragma mark Collection View Delegate (_messagesTable)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _commentModels.count + 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    UICollectionViewCell *newCell;
    if (indexPath.item == 0) {
        BCCommentsViewPostCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCCommentsCollectionViewPostCell" forIndexPath:indexPath];

        newCell = cell;
        [_content placeIn:cell.contentView alignedAt:CENTER];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(cell.contentView.bounds) - 1.0, 80.0, 1.0)];
        separator.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
        [separator placeIn:cell.contentView alignedAt:BOTTOM];
        [cell.contentView addSubview:_content];
        [cell.contentView addSubview:separator];
    } else {
        BCCommentsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCCommentsCollectionViewCell" forIndexPath:indexPath];
        BCCommentModel *commentModel = [_commentModels objectAtIndex:indexPath.row - 1];
        
        if (indexPath.item % 2 == 0) {
            cell.avatar.image = [UIImage imageNamed:@"avatar_author.png"];
        } else {
            cell.avatar.image = [UIImage imageNamed:@"avatar_general.png"];
        }
        cell.avatar.clipsToBounds = YES;
        [cell.avatar debug];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 22.0;
        style.maximumLineHeight = 22.0;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Poly" size:15.0],
                                     NSParagraphStyleAttributeName:style};
        
        NSAttributedString *commentAttr = [[NSAttributedString alloc] initWithString:commentModel.comment attributes:attributes];
        cell.commentText.attributedText = commentAttr;
        
        newCell = cell;
    }
    
    return newCell;
}

#pragma mark Collection View Scroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0 && [_bar.commentsTextView isFirstResponder])
    {
        [_bar.commentsTextView resignFirstResponder];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

#pragma mark GrowingTextView Delegate

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat delta = height - CGRectGetHeight(growingTextView.bounds);
    [_comments setHeight:CGRectGetHeight(_comments.bounds) - delta];
    [_bar setY:CGRectGetMinY(_bar.frame) - delta];
    [_bar setHeight:CGRectGetHeight(_bar.frame) + delta];
    [_bar.sendButton setY:CGRectGetMinY(_bar.sendButton.frame) + delta];
    [self.view layoutIfNeeded]; // THIS WAS REQUIRED OTHERWISE something screwed up with geometry
}

#pragma mark CollectionView Layout Delegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        return (CGSize){CGRectGetWidth(collectionView.bounds), CGRectGetHeight(_content.bounds)};
    } else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCCommentsCell" owner:self options:nil];
        BCCommentsViewCell *cell = (BCCommentsViewCell*)[nib objectAtIndex:0];
        //NSLog(@"The w = %f and h = %f", CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
        BCCommentModel *commentModel = (BCCommentModel*)[_commentModels objectAtIndex:indexPath.row - 1];
        
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 22.0;
        style.maximumLineHeight = 22.0;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Poly" size:15.0],
                                     NSParagraphStyleAttributeName:style};
        
        NSAttributedString *commentAttr = [[NSAttributedString alloc] initWithString:commentModel.comment attributes:attributes];
        cell.commentText.attributedText = commentAttr;
        CGRect rect = [commentAttr boundingRectWithSize:CGSizeMake(CGRectGetWidth(cell.commentText.bounds), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        //rect.size.height += 25; // some padding
        if (indexPath.item == _commentModels.count) {
            CGFloat lastHeight = fmax(rect.size.height, 25.0);
            rect.size.height = lastHeight + kCommentPadding;
        }
        
        return (CGSize){CGRectGetWidth(collectionView.bounds), fmax(rect.size.height, 25.0)};
    }
}

@end
