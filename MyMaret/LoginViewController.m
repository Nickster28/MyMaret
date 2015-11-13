//
//  LoginViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "LoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"
#import "UIViewController+NavigationBarColor.h"


@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBarColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Hide the nav bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark Google Login and Authentication

- (IBAction)showLoginScreen:(id)sender
{
    if (![UIApplication hasNetworkConnection]) {
        NSString *errorMsg = @"Looks like you're not connected to the Internet.  You'll need an Internet connection to log in.  Make sure your WiFi or Cellular connection is on and try again.";
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                     message:errorMsg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    NSString *kMyClientID = @"41307471062.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"pCkySyz5CPUH-rsMvygfXC5K"; // pre-assigned by service
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.email"; // scope for Google user info API
    
    // Thanks to http://stackoverflow.com/questions/13859068/calling-arc-method-from-non-arc-code
    // for reminding me that ARC simply fills in retains/releases - so if I want to use non-ARC
    // code here I should just get rid of the autorelese on viewController.
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:kMyClientID
                                                            clientSecret:kMyClientSecret
                                                        keychainItemName:nil
                                                                delegate:nil
                                                        finishedSelector:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}






@end
