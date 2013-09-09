//
//  WelcomeViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "WelcomeViewController.h"

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
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end
