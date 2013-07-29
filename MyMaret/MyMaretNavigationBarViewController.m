//
//  MyMaretNavigationBarViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretNavigationBarViewController.h"

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
    
    
    UIBarButtonItem *drawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self.revealViewController
                                                                                  action:@selector(revealToggle:)];
    
    if ([UIApplication isPrevIOS]) {
        [drawerButton setImage:[UIImage imageNamed:@"DrawerIcon6"]];
    } else [drawerButton setImage:[UIImage imageNamed:@"DrawerIcon7"]];
    
    [self.navigationItem setLeftBarButtonItem:drawerButton];
}

@end
