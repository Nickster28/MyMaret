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

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

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
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // Go back to the start in case the user logs off
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
