//
//  SettingsTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SettingsTableViewController

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
    
    // Set the name of the user
    UITableViewCell *userNameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[userNameCell detailTextLabel] setText:[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserNameKey]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showContactScreen
{
    // Can we send email?
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                     message:@"Sorry, but you need an email account set up on this device to contact us.  If you would like to use another email app or service, just send an email to mymaretsupport@maret.org."
                                                    delegate:nil
                                           cancelButtonTitle:@"Got it!"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    mailView.mailComposeDelegate = self;
    [mailView setToRecipients:@[@"mymaretsupport@maret.org"]];
    
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
    
    
    // If the user send an email to support, let them
    // know we'll respond shortly
    if (result == MFMailComposeResultSent) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Thanks!"
                                                     message:@"Thanks for the email!  We'll get back to you shortly."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it's the "Contact Us" button...
    if ([indexPath section] == 1 && [indexPath row] == 1) {
        [self showContactScreen];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
