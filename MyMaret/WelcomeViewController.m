//
//  WelcomeViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SWRevealViewController.h"
#import "TodayTableViewController.h"
#import "UIColor+SchoolColor.h"


@implementation WelcomeViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (IBAction)dismissWelcomeScreen:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES
                                                                           completion:nil];
    
    SWRevealViewController *revealController = (SWRevealViewController *)self.navigationController.presentingViewController;
    
    // Make sure the screen we're about to go to is refreshed
    UIViewController *nextScreen = [[(UINavigationController *)revealController.frontViewController viewControllers] objectAtIndex:0];
    
    if ([nextScreen isKindOfClass:[TodayTableViewController class]]) {
        
        [[(TodayTableViewController *)nextScreen tableView] reloadData];
    }
}

@end
