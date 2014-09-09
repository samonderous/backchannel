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

static const float kPostAnimationFinishedHeight = 50.0;

@interface BCCommentsViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *commentText;
@property (strong, nonatomic) UIView *separator;
@end

@interface BCCommentsViewCell ()

@end

@implementation BCCommentsViewCell

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

@end

@implementation BCCommentsBar
@end


@interface BCCommentsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HPGrowingTextViewDelegate>
@property (strong, nonatomic) UIView *post;
@property (strong, nonatomic) UICollectionView *comments;
@property (strong, nonatomic) BCCommentsBar *bar;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMockComments];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _post = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_post];
    
    _bar = (BCCommentsBar*)[[NSBundle mainBundle] loadNibNamed:@"BCCommentsBar" owner:self options:nil][0];
    [self.view addSubview:_bar];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _comments = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.view addSubview:_comments];
    
    _comments.delegate = self;
    _comments.dataSource = self;
    _bar.commentsTextView.delegate = self;
    _bar.commentsTextView.layer.borderWidth = 1.0;
    _bar.commentsTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bar.commentsTextView.layer.cornerRadius = 3.0;
    [_comments registerNib:[UINib nibWithNibName:@"BCCommentsCell" bundle:nil] forCellWithReuseIdentifier:@"BCCommentsCollectionViewCell"];
    _comments.backgroundColor = [UIColor whiteColor];
    [_bar.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_bar.sendButton setTitleColor:[[BCGlobalsManager globalsManager] creamColor] forState:UIControlStateNormal];

    [self.view bringSubviewToFront:_bar];

    [self registerForKeyboardNotifications];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:backButton];
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

    [_post addSubview:_content];


    //[_post debug];
    //[_comments debug];
    //[_bar debug];
    //[_post addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    [Utils debugRect:self.view withName:@"view"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_post setSize:(CGSize){[UIScreen mainScreen].bounds.size.width, kCellHeight}];
    [_comments setY:CGRectGetMaxY(_post.frame)];
    [_comments setSize:(CGSize){[UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(self.view.bounds) - CGRectGetHeight(_bar.bounds) - CGRectGetHeight(_post.bounds)}];
    [_bar setY:CGRectGetMaxY(_comments.frame)];
    [_content placeIn:_post alignedAt:CENTER];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(_post.bounds) - 1.0, 80.0, 1.0)];
    separator.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [_post addSubview:separator];
    [separator placeIn:_post alignedAt:BOTTOM];
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
    
    [self addComment:commentString];
    [_comments performBatchUpdates:^{
        [_comments insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:_commentModels.count - 1 inSection:0]]];
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [_comments setHeight:(CGRectGetHeight(self.view.bounds) - keyboardSize.height - CGRectGetHeight(_bar.bounds) - kPostAnimationFinishedHeight)];
}

- (void)keyboardWillBeShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    //[self.view layoutIfNeeded];
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_bar setY:(CGRectGetHeight(self.view.bounds) - keyboardSize.height - CGRectGetHeight(_bar.bounds))];
                         [_post setHeight:kPostAnimationFinishedHeight];
                         [_comments setY:CGRectGetMaxY(_post.frame)];
                         //[self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         _inEditMode = YES;
                     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [value getValue:&duration];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [_bar setY:CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(_bar.bounds)];
                         [_post setHeight:kCellHeight];
                         [_comments setY:CGRectGetMaxY(_post.frame)];
                     }
                     completion:^(BOOL finished) {
                         _inEditMode = NO;
                     }];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    [_comments setHeight:(CGRectGetHeight(self.view.bounds) - kCellHeight - CGRectGetHeight(_bar.bounds))];
}

#pragma mark Collection View Delegate (_messagesTable)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _commentModels.count;
}

- (BCCommentsViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    BCCommentsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCCommentsCollectionViewCell" forIndexPath:indexPath];

    BCCommentModel *commentModel = [_commentModels objectAtIndex:indexPath.row];
    cell.commentText.text = commentModel.comment;
    
    cell.avatar.image = [UIImage imageNamed:@"avatar1.png"];
    cell.avatar.layer.cornerRadius = CGRectGetHeight(cell.avatar.bounds) / 2.0;
    cell.avatar.clipsToBounds = YES;
    
    cell.commentText.font = [UIFont fontWithName:@"Poly" size:13.0];
    
    cell.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                          CGRectGetMaxY(cell.contentView.bounds) - 1.0,
                                                          50.0,
                                                          1.0)];
    cell.separator.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [cell.contentView addSubview:cell.separator];
    [cell.separator placeIn:cell.contentView alignedAt:BOTTOM];

    return cell;
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
    [self.view layoutIfNeeded]; // THIS WAS REQUIRED OTHERWISE something screwed up with geometry
    NSLog(@"The internal text view widht = %f", growingTextView.internalTextView.bounds.size.width);
}

#pragma mark CollectionView Layout Delegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BCCommentsCell" owner:self options:nil];
    BCCommentsViewCell *cell = (BCCommentsViewCell*)[nib objectAtIndex:0];
    NSLog(@"The w = %f and h = %f", CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
    BCCommentModel *commentModel = (BCCommentModel*)[_commentModels objectAtIndex:indexPath.row];
    cell.commentText.text = commentModel.comment;

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Poly" size:13.0]};
    
    CGRect rect = [commentModel.comment boundingRectWithSize:CGSizeMake(CGRectGetWidth(cell.commentText.bounds), CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    rect.size.height += 25; // some padding
    return (CGSize){CGRectGetWidth(collectionView.bounds), rect.size.height};
}

@end
