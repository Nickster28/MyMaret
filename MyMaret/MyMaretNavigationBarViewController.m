//
//  MyMaretNavigationBarViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretNavigationBarViewController.h"
#import "SWRevealViewController.h"

@implementation MyMaretNavigationBarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSAssert(self.navigationController, @"Must have a navigation controller!");
    NSAssert(self.revealViewController, @"Must have a reveal view controller!");
    
    [self.navigationController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:16.0/255.0
                                                                          green:105.0/255.0
                                                                           blue:53.0/255.0
                                                                          alpha:1.0]];
    
    
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
    
    [self.revealViewController setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.revealViewController setDelegate:nil];
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
