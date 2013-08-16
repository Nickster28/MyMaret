//
//  AnnouncementCreationViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/13/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementCreationViewController.h"
#import "AnnouncementsStore.h"
#import "UIColor+SchoolColor.h"


@interface AnnouncementCreationViewController ()

@end

@implementation AnnouncementCreationViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Draw a border around the body UITextView
    // Thanks to http://stackoverflow.com/questions/2647164/border-around-uitextview
    self.bodyTextView.layer.borderWidth = 2.0f;
    self.bodyTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.bodyTextView.layer.cornerRadius = 8.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)postAnnouncement:(id)sender {
    NSString *announcementTitle = [self.titleTextField text];
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
    [activityIndicator startAnimating];
    
    [self.cancelButton setEnabled:NO];
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
                                                        [self.cancelButton setEnabled:YES];
                                                        [self.postButton setTitle:@"Post"];
                                                        
                                                    // Otherwise, dismiss the modal screen
                                                    } else [self cancelAnnouncement:self.cancelButton];
                                                }];
}


// Dismiss the modal view controller
- (IBAction)cancelAnnouncement:(id)sender {
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES
                                                                               completion:nil];
}


#pragma mark - UITextView/UITextField Delegate

// Hide the fake placeholder text
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.bodyPlaceholderText.layer.opacity == 1.0) {
        // Animate the placeholder text out (make it completely transparent)
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeAnimation setDuration:0.25];
        [fadeAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
        [fadeAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        
        [self.bodyPlaceholderText.layer setOpacity:0.0];
        
        [self.bodyPlaceholderText.layer addAnimation:fadeAnimation forKey:@"Fade"];
    }
    
    return YES;
}


// If no text was entered, show the placeholder text
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        
        // Animate the placeholder text in (make it completely opaque)
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeAnimation setDuration:0.25];
        [fadeAnimation setFromValue:[NSNumber numberWithFloat:0.0]];
        [fadeAnimation setToValue:[NSNumber numberWithFloat:1.0]];
        
        [self.bodyPlaceholderText.layer setOpacity:1.0];
        
        [self.bodyPlaceholderText.layer addAnimation:fadeAnimation forKey:@"Fade"];
    }
    
    return YES;
}


// Hide the keyboard when the user taps the "Done" keyboard
// button while editing the Announcement title
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
