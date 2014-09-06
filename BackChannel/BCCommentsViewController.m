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

static const float kPostAnimationFinishedHeight = 40.0;

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


@implementation BCGrowingTextView
@end


@interface BCCommentsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HPGrowingTextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *post;
@property (strong, nonatomic) IBOutlet UICollectionView *comments;
@property (strong, nonatomic) IBOutlet UIView *bar;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentsTextView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMockComments];
    
    _comments.delegate = self;
    _comments.dataSource = self;
    _commentsTextView.delegate = self;
    _commentsTextView.layer.borderWidth = 1.0;
    _commentsTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _commentsTextView.layer.cornerRadius = 3.0;
    //[_comments registerClass:[BCCommentsViewCell class] forCellWithReuseIdentifier:];
    [_comments registerNib:[UINib nibWithNibName:@"BCCommentsCell" bundle:nil] forCellWithReuseIdentifier:@"BCCommentsCollectionViewCell"];
    _comments.backgroundColor = [UIColor whiteColor];
    [_sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setTitleColor:[[BCGlobalsManager globalsManager] creamColor] forState:UIControlStateNormal];

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
    [_content placeIn:_post alignedAt:CENTER];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(_post.bounds) - 1.0, 80.0, 1.0)];
    separator.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [_post addSubview:separator];
    [separator placeIn:_post alignedAt:BOTTOM];
    
    //[_post debug];
    //[_comments debug];
    //[_bar debug];
}

- (void)handleBackButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendTapped:(id)sender
{
    NSLog(@"Send tapped");
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
    
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    [_comments setHeight:(CGRectGetHeight(self.view.bounds) - keyboardSize.height - CGRectGetHeight(_bar.bounds) - kPostAnimationFinishedHeight - statusBarHeight)];
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
                         [_post setHeight:kPostAnimationFinishedHeight];
                         [_comments setY:CGRectGetMaxY(_post.frame)];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         _inEditMode = YES;
                         
                         //Scroll to bottom
                         //NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:[_comments numberOfItemsInSection:0] - 1 inSection:0];
                         //[_comments scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    //CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
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
    if (scrollView.contentOffset.y <= 0 && [_commentsTextView isFirstResponder])
    {
        [_commentsTextView resignFirstResponder];
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
