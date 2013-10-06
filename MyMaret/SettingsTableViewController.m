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
#import "MainMenuViewController.h"
#import "UIColor+SchoolColor.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@end

@implementation SettingsTableViewController



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // This could be the first view that appears after
    // a user logs back in, so we want to make sure it's
    // up to date
    [self.tableView reloadData];
}


// Show the email compose window
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



- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
    
    // Deselect the "Contact Us" cell
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                              inSection:0]
                                  animated:YES];
    
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            
        case 1:
            return 1;
            
        case 2:
            return 1;
            
        default:
            return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"User Information";
            
        case 1:
            return @"App Information";
            
        case 2:
            return @"Questions? Comments?";
            
        default:
            return @"";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // Return the appropriate cell
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"
                                               forIndexPath:indexPath];
        
        // Display the user's name
        [[cell detailTextLabel] setText:[[NSUserDefaults standardUserDefaults] objectForKey:MyMaretUserNameKey]];
        
        [[cell textLabel] setText:@"Name"];
        
    } else if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"
                                               forIndexPath:indexPath];
        
        // Set the Log Out cell to be the gold color
        [[cell textLabel] setTextColor:[UIColor schoolComplementaryColor]];
        
        [[cell textLabel] setText:@"Log Out"];
        
    } else if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"
                                               forIndexPath:indexPath];
        
        // Display the app version
        [[cell detailTextLabel] setText:@"2.0"];
        
        [[cell textLabel] setText:@"MyMaret Version"];
        
    } else if (indexPath.section == 2) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"
                                               forIndexPath:indexPath];
        
        // Set the Contact Us cell to be green
        [[cell textLabel] setTextColor:[UIColor schoolColor]];
        
        [[cell textLabel] setText:@"Contact Us"];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it's the Logout button...
    if ([indexPath section] == 0 && [indexPath row] == 1) {
        
        // Warn the user that their data may be erased if they log in as a different user
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                     message:@"If you log out and log back in as the same user, your data will be saved.  However, if you log out and log in as a different user, the data for the previous user will be erased.  Are you sure you want to log out?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Log Out", nil];
        
        [av show];
        
    // If it's the "Contact Us" button...
    } else if ([indexPath section] == 2) {
            [self showContactScreen];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    
    if (buttonIndex == 1) [self logOff];
}


- (void)logOff
{
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:MyMaretIsLoggedInKey];
    
    // Set the user to receive emails, if they are a registered user
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserEmailKey];
    
    if (![email isEqualToString:@""]) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Person"];
        [query whereKey:@"emailAddress" equalTo:[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserEmailKey]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                
                // Set shouldReceiveEmails to "YES"
                [object setObject:[NSNumber numberWithBool:YES] forKey:@"shouldReceiveEmails"];
                [object saveInBackground];
            }
        }];
    }
    
    
    // Set the badge to 0
    [[PFInstallation currentInstallation] setBadge:0];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Opt out of push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNone];
    
    // Make a new login screen and present it
    LoginViewController *loginScreen = [[LoginViewController alloc] init];
    [loginScreen setLoginStatus:LoginStatusLogout];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:loginScreen];
    
    [navController setNavigationBarHidden:YES];
    [navController.navigationBar setTintColor:[UIColor schoolColor]];
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}


@end
