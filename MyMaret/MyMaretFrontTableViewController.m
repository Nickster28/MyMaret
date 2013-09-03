//
//  MyMaretFrontTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretFrontTableViewController.h"
#import "UIColor+SchoolColor.h"
#import "UIApplication+iOSVersionChecker.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"

@implementation MyMaretFrontTableViewController


- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(respondToAnnouncementNotification:)
                                                 name:MyMaretNewAnnouncementNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(respondToNewspaperNotification:)
                                                 name:MyMaretNewNewspaperNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Go to announcements if there is a new announcement
- (void)respondToAnnouncementNotification:(NSNotification *)notification
{
    // Set the selected section
    MainMenuViewController *rearVC = (MainMenuViewController *)[self.revealViewController rearViewController];
    [rearVC setSelectedIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    // Segue to the announcements screen
    [rearVC performSegueWithIdentifier:@"announcementsSegue" sender:self];
}


// Go to newspaper if there is a new newspaper
- (void)respondToNewspaperNotification:(NSNotification *)notification
{
    // Set the selected section
    MainMenuViewController *rearVC = (MainMenuViewController *)[self.revealViewController rearViewController];
    [rearVC setSelectedIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    // Segue to the announcements screen
    [rearVC performSegueWithIdentifier:@"newspaperSegue" sender:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSAssert(self.navigationController, @"Must have a navigation controller!");
    NSAssert(self.revealViewController, @"Must have a reveal view controller!");
    
    [self.navigationController.navigationBar setTintColor:[UIColor schoolColor]];
    
    
    // Add the button to open the drawer
    UIBarButtonItem *drawerButton = [[UIBarButtonItem alloc] init];
    
    if ([UIApplication isPrevIOS]) {
        [drawerButton setImage:[UIImage imageNamed:@"DrawerIcon6"]];
    } else [drawerButton setImage:[UIImage imageNamed:@"DrawerIcon7"]];
    
    [drawerButton setTarget:self.revealViewController];
    [drawerButton setAction:@selector(revealToggle:)];
    
    [self.navigationItem setLeftBarButtonItem:drawerButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAssert(!self.revealViewController.delegate, @"Reveal controller delegate already set!");
    
    // Set the reveal controller delegate and add a pan gesture to open it
    [self.navigationController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.revealViewController setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove the reveal controller delegate and remove the pan gesture
    [self.revealViewController setDelegate:nil];
    [self.navigationController.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft) {
        [self.view setUserInteractionEnabled:YES];
    } else if (position == FrontViewPositionRight) {
        [self.view setUserInteractionEnabled:NO];
    }
}

@end
