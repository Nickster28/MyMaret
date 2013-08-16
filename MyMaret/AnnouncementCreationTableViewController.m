//
//  AnnouncementCreationTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/13/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementCreationTableViewController.h"
#import "AnnouncementsStore.h"

@interface AnnouncementCreationTableViewController ()

@end

@implementation AnnouncementCreationTableViewController

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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The first and third rows are normally-sized (for title text field and post button)
    if ([indexPath row] == 2 || [indexPath row] == 0) {
        return 44.0;
        
    // The second row is large to hold the text field for the announcement body (we want it
    // and the other two cells to fill the whole screen)
    } else if ([indexPath row] == 1) {
        // Get the height of the table
        CGFloat tableHeight = tableView.window.bounds.size.height;
        
        // Subtract off the height of the two other cells
        tableHeight -= 88.0;
        
        // Subtract the height of the navigation bar and status bar
    #warning Doesn't account for in-call status bar
        tableHeight -= 64.0;
        
        return tableHeight;
    } else return 0.0;
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
    
    // Animate the activity Indicator and disable the cancel button
    [self.activityIndicator startAnimating];
    [self.cancelButton setEnabled:NO];
    
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
                                                        [self.activityIndicator stopAnimating];
                                                        [self.cancelButton setEnabled:YES];
                                                        
                                                    // Otherwise, dismiss the modal screen
                                                    } else [self cancelAnnouncement:nil];
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
    // Animate the placeholder text out (make it completely transparent)
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeAnimation setDuration:0.25];
    [fadeAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
    [fadeAnimation setToValue:[NSNumber numberWithFloat:0.0]];

    [self.bodyPlaceholderText.layer setOpacity:0.0];
    
    [self.bodyPlaceholderText.layer addAnimation:fadeAnimation forKey:@"Fade"];
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
