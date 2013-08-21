//
//  AnnouncementCreationBodyViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementCreationBodyViewController.h"
#import "AnnouncementsStore.h"
#import "UIColor+SchoolColor.h"

@interface AnnouncementCreationBodyViewController ()

@end

@implementation AnnouncementCreationBodyViewController

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
    
    [self.bodyTextView becomeFirstResponder];
    [self.postButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if (range.length == self.bodyTextView.text.length && [text isEqualToString:@""]) {
        [[self postButton] setEnabled:NO];
    } else {
        [[self postButton] setEnabled:YES];
    }
    
    return YES;
}


- (IBAction)postAnnouncement:(id)sender {
    NSString *announcementTitle = self.announcementTitle;
    NSString *announcementBody = [self.bodyTextView text];
    
    if ([announcementTitle isEqualToString:@""] || [announcementBody isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Announcement Error"
                                                     message:@"Please complete all fields before posting an announcement."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        
        [av show];
        return;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    if (![UIApplication isPrevIOS]) {
        [activityIndicator setColor:[UIColor schoolColor]];
    }
    
    [activityIndicator startAnimating];
    
    [self.navigationItem.backBarButtonItem setEnabled:NO];
    [self.postButton setCustomView:activityIndicator];
    
    // Post the announcement
    [[AnnouncementsStore sharedStore] postAnnouncementWithTitle:announcementTitle
                                                           body:announcementBody
                                                completionBlock:^(NSError *err) {
                                                    
                                                    // Display the error if there is one
                                                    if (err) {
                                                        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Post Error"
                                                                                                     message:err.localizedDescription
                                                                                                    delegate:nil cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles:nil];
                                                        [av show];
                                                        
                                                        // Stop the activity indicator and re-enable the cancel button
                                                        [activityIndicator stopAnimating];
                                                        [self.navigationItem.backBarButtonItem setEnabled:YES];
                                                        [self.postButton setTitle:@"Post"];
                                                        
                                                        // Otherwise, dismiss the modal screen
                                                    } else [self.presentingViewController dismissViewControllerAnimated:YES
                                                                                                             completion:nil];
                                                }];
}


@end
