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
#import "UIApplication+iOSVersionChecker.h"

@interface AnnouncementDetailViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation AnnouncementDetailViewController


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
    [self.titleLabel setText:[[self announcement] announcementTitle]];
    [self.bodyTextView setText:[[self announcement] description]];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.navigationController.toolbarHidden)
        [self.navigationController setToolbarHidden:YES animated:YES];
    
    [super viewWillAppear:animated];
    
    // Configure the layer used to draw the divider line
    CALayer *dividerLayer = [[CALayer alloc] init];
    [dividerLayer setBounds:CGRectMake(0,0,self.bodyTextView.bounds.size.width - 20.0, 1.0)];
    [dividerLayer setPosition:CGPointMake(self.bodyTextView.frame.size.width / 2.0,
                                          self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height)];
    
    [dividerLayer setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
    [dividerLayer setOpacity:0.0];
    
    [[self.view layer] addSublayer:dividerLayer];
    
    
    // Now fade in the line
    CABasicAnimation *fader = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fader setDuration:0.2];
    [fader setFromValue:[NSNumber numberWithFloat:0.0]];
    [fader setToValue:[NSNumber numberWithFloat:1.0]];
    [fader setDelegate:self];
    
    [dividerLayer setOpacity:1.0];
    
    [dividerLayer addAnimation:fader
                        forKey:@"fade"];
    
    
}


// Triggered when the user taps on the "Email" button - sends an email from one of the user's mail
// accounts with the contents of the announcement (title, announcement, date, sender)
- (IBAction)emailAnnouncement:(id)sender
{
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    mailView.mailComposeDelegate = self;
    
    [mailView setSubject:[[self announcement] announcementTitle]];
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
        UIAlertView *mailErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
        
        [mailErrorAlertView show];
    }
}





@end
