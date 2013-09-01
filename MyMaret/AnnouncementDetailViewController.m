//
//  AnnouncementDetailViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementDetailViewController.h"
#import "Announcement.h"
#import <MessageUI/MessageUI.h>
#import "SWRevealViewController.h"
#import "UIApplication+iOSVersionChecker.h"

@interface AnnouncementDetailViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation AnnouncementDetailViewController

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
    
    // Set the email button image
    if ([UIApplication isPrevIOS]) {
        [self.emailButton setImage:[UIImage imageNamed:@"EmailIcon6"]];
    } else {
        [self.emailButton setImage:[UIImage imageNamed:@"EmailIcon7"]];
    }
    
    // Can we send email?
    if (![MFMailComposeViewController canSendMail]) {
        self.emailButton.enabled = NO;
    }
    
    
    // Set all of the announcement info
    //[self.navigationItem setTitle:self.announcement.postDateAsString];
    [self.titleLabel setText:self.announcement.title];
    [self.bodyTextView setText:self.announcement.description];
    
    
    // Configure the layer used to draw the divider line
    CALayer *dividerLayer = [[CALayer alloc] init];
    [dividerLayer setBounds:CGRectMake(0,0,self.bodyTextView.bounds.size.width - 20.0, 1.0)];
    [dividerLayer setPosition:CGPointMake(self.bodyTextView.frame.size.width / 2.0,
                                       self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height)];
    
    [dividerLayer setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
    
    [[self.view layer] addSublayer:dividerLayer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Triggered when the user taps on the "Email" button - sends an email from one of the user's mail
// accounts with the contents of the announcement (title, announcement, date, sender)
- (IBAction)emailAnnouncement:(id)sender
{
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    mailView.mailComposeDelegate = self;
    
    [mailView setSubject:self.announcement.title];
    [mailView setMessageBody:self.announcement.description
                      isHTML:NO];
    
    
    [self.navigationController presentViewController:mailView
                                            animated:YES
                                          completion:nil];
}



// Show the email compose window
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
    
    if (error) {
        UIAlertView *mailErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
        
        [mailErrorAlertView show];
    }
}





@end
