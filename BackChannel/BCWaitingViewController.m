//
//  BCWaitingViewController.m
//  BackChannel
//
//  Created by Saureen Shah on 4/29/14.
//  Copyright (c) 2014 Saureen Shah. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "BCWaitingViewController.h"
#import "BCGlobalsManager.h"
#import "BCAuthViewController.h"

static const float kTaglineAssetSpacing = 58.0;
static const float kTaglineAssetSpacingOld = 14.0;
static const float kButtonHeight = 60.0;
static const float kAssetTextSpacing = 30.0;

@interface BCWaitingView : UIView
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *tagLine;
@property (strong, nonatomic) UIImageView *asset;
@property (strong, nonatomic) UILabel *text;
@property (strong, nonatomic, getter = getInviteButton) UIView *inviteButton;
@end

@implementation BCWaitingView

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].applicationFrame];
    _title = [BCAuthView getTitle];
    [self addSubview:_title];
    
    _tagLine = [BCAuthView getTagline];
    [self addSubview:_tagLine];

    _asset = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waitlistedorg.png"]];
    [self addSubview:_asset];
    
    _text = [[UILabel alloc] init];
    [self addSubview:_text];
    
    NSString *textString = @"We're still waiting for a few\nmore of your coworkers to join\nbefore we can let you in.*\n*to ensure your anonymity";
    NSMutableAttributedString *textAttrString  = [[NSMutableAttributedString alloc] initWithString:textString];

    [textAttrString addAttribute: NSForegroundColorAttributeName value: [[BCGlobalsManager globalsManager] publishTutorialHintColor]
                           range: NSMakeRange(88, textString.length - 88)];
    
    [textAttrString addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Poly" size:12.0] range:NSMakeRange(88, textString.length - 88)];
    
    _text.numberOfLines = 0;
    _text.textAlignment = NSTextAlignmentCenter;
    _text.attributedText = textAttrString;
    [_text sizeToFit];
    
    _inviteButton = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), kButtonHeight)];
    [self addSubview:_inviteButton];
    _inviteButton.backgroundColor = [[BCGlobalsManager globalsManager] blueBackgroundColor];

    UILabel *inviteLabel = [[UILabel alloc] init];
    inviteLabel.textColor = [[BCGlobalsManager globalsManager] blueColor];
    inviteLabel.font = [UIFont fontWithName:@"Poly" size:18.0];
    inviteLabel.text = @"Invite coworkers";
    [inviteLabel sizeToFit];
    [inviteLabel placeIn:_inviteButton alignedAt:CENTER];
    [_inviteButton addSubview:inviteLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_title placeIn:self alignedAt:CENTER];
    [_title setY:kTitleTopMargin];
    
    [_tagLine placeIn:self alignedAt:CENTER];
    [_tagLine setY:CGRectGetMaxY(_title.frame) + kTitleTaglineSpacing];
    
    [_asset placeIn:self alignedAt:CENTER];
    if (IS_IPHONE_5) {
        [_asset setY:CGRectGetMaxY(_tagLine.frame) + kTaglineAssetSpacing];
    } else {
        [_asset setY:CGRectGetMaxY(_tagLine.frame) + kTaglineAssetSpacingOld];
    }
    
    [_text placeIn:self alignedAt:CENTER];
    [_text setY:CGRectGetMaxY(_asset.frame) + kAssetTextSpacing];
    
    [_inviteButton placeIn:self alignedAt:BOTTOM];
}

@end


@interface BCWaitingViewController ()<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) BCWaitingView *wv;
@end

@implementation BCWaitingViewController

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
    _wv = [[BCWaitingView alloc] init];
    [self.view addSubview:_wv];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)inviteButtonTap:(UITapGestureRecognizer*)gesture
{
    NSLog(@"Got a tap");
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *subject = [NSString stringWithFormat:@"Inviting you to our Backchannel"];
    [picker setSubject:subject];
    
    // Attach an image to the email
    /*NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
    */
    
    // Fill out the email body text
    NSString *emailBody = @"There's an app called Backchannel where you can read and share thoughts anonymously with (and only with) other fellow employees.<br/><br/><a href='https://bckchannelapp.com/backend/invite/'>Check out our Backchannel</a>.";
    [picker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteButtonTap:)];
    [_wv.getInviteButton addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma MFMail Compose Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail sending canceled");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"invite_cancel" withParams:nil];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail sending saved");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"invite_saved" withParams:nil];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sending sent");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"invite_sent" withParams:nil];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sending failed");
            [[BCGlobalsManager globalsManager] logFlurryEvent:@"invite_failed" withParams:nil];
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
