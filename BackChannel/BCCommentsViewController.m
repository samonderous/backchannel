//
//  BCCommentsViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 9/2/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import "BCCommentsViewController.h"
#import "BCStreamViewController.h"
#import "BCModels.h"
#import "BCGlobalsManager.h"

static const float kPostAnimationFinishedHeight = 40.0;

@interface BCCommentsViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UITextView *commentText;

@end

@interface BCCommentsViewCell ()

@end

@implementation BCCommentsViewCell
@end


@implementation BCGrowingTextView
@end


@interface BCCommentsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HPGrowingTextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *post;
@property (strong, nonatomic) IBOutlet UICollectionView *comments;
@property (strong, nonatomic) IBOutlet UIView *bar;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *commentsTextView;

@property (strong, nonatomic) BCSecretModel *secretModel;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _comments.delegate = self;
    _comments.dataSource = self;
    _commentsTextView.delegate = self;
    [_sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
    _commentsTextView.layer.borderWidth = 1.0;
    _commentsTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _commentsTextView.layer.cornerRadius = 3.0;
    //[_comments registerClass:[BCCommentsViewCell class] forCellWithReuseIdentifier:];
    [_comments registerNib:[UINib nibWithNibName:@"BCCommentsCell" bundle:nil] forCellWithReuseIdentifier:@"BCCommentsCollectionViewCell"];
    _comments.backgroundColor = [UIColor whiteColor];
    
    [self registerForKeyboardNotifications];
    
    [self.view bringSubviewToFront:_bar];
    
    //[_post debug];
    //[_comments debug];
    //[_bar debug];
    
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

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(_post.bounds) - 1.0, 80.0, 1.0)];
    separator.backgroundColor = [[BCGlobalsManager globalsManager] blackDividerColor];
    [_post addSubview:separator];
    [separator placeIn:_post alignedAt:BOTTOM];
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
    return 15;
}

- (BCCommentsViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    BCCommentsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BCCommentsCollectionViewCell" forIndexPath:indexPath];
    

    UIImage *avatar = [UIImage imageNamed:@"avatar.png"];
    
    CGRect rect = CGRectMake(0,0,20,20);
    UIGraphicsBeginImageContext( rect.size );
    [avatar drawInRect:rect];
    UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture);
    cell.avatar.image = [UIImage imageWithData:imageData];
     
    cell.avatar.layer.cornerRadius = CGRectGetHeight(cell.avatar.bounds) / 2.0;
    cell.avatar.clipsToBounds = YES;
    
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
    } /*else if (!_inEditMode && _lastContentOffset <= scrollView.contentOffset.y)
    {
        [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_post setHeight:kPostAnimationFinishedHeight];
                             _postText.alpha = 0.3;
                             [_postText setY:(CGRectGetMaxY(_post.bounds) - CGRectGetHeight(_postText.bounds) * .65)];
                             [_comments setY:CGRectGetMaxY(_post.frame)];
                             [_comments setHeight:CGRectGetHeight(self.view.bounds) - CGRectGetHeight(_bar.bounds) - kPostAnimationFinishedHeight - 20.0];
                         }
                         completion:^(BOOL finished) {
                         }];
    }*/
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

@end
