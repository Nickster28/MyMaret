//
//  AnnouncementCreationTitleViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementCreationTitleViewController.h"
#import "AnnouncementCreationBodyViewController.h"

@interface AnnouncementCreationTitleViewController ()

@end

@implementation AnnouncementCreationTitleViewController

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
    
    [[self titleTextField] becomeFirstResponder];
    [[self nextButton] setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Dismiss the modal view controller
- (IBAction)cancelAnnouncement:(id)sender {
    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextAnnouncementCreationScreen:(id)sender {
    [self performSegueWithIdentifier:@"announcementCreationSegue"
                              sender:self.nextButton];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![[textField text] isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"announcementCreationSegue"
                                  sender:self];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Title"
                                                     message:@"Please enter an announcement title"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (range.length == self.titleTextField.text.length && [string isEqualToString:@""]) {
        [[self nextButton] setEnabled:NO];
    } else {
        [[self nextButton] setEnabled:YES];
    }
    
    return YES;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"announcementCreationSegue"] && [[segue destinationViewController] isKindOfClass:[AnnouncementCreationBodyViewController class]]) {
 
        [[segue destinationViewController] setAnnouncementTitle:self.titleTextField.text];
    }
}

@end
