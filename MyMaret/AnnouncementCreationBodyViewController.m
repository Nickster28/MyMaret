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
#import "UIApplication+iOSVersionChecker.h"

@interface AnnouncementCreationBodyViewController ()

@end

@implementation AnnouncementCreationBodyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.bodyTextView becomeFirstResponder];
    [self.postButton setEnabled:NO];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Only activate the post button if the body is not empty
    if (range.length == self.bodyTextView.text.length && [text isEqualToString:@""]) {
        [[self postButton] setEnabled:NO];
    } else {
        [[self postButton] setEnabled:YES];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    // Make sure to scroll the text view if the user gets to the bottom
    if (self.bodyTextView.text.length > 0) {
        [textView scrollRangeToVisible:NSMakeRange(self.bodyTextView.text.length - 1, 1)];
    }
}


- (IBAction)postAnnouncement:(id)sender {
    NSString *announcementTitle = self.announcementTitle;
    NSString *announcementBody = [self.bodyTextView text];
    
    // We shouldn't get inside this if statement...
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
