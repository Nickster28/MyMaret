//
//  MyMaretFrontTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretFrontTableViewController.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"
#import "UIViewController+NavigationBarColor.h"
#import "LoginViewController.h"
#import "UIColor+SchoolColor.h"



@interface MyMaretFrontTableViewController()
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapRecognizer;
@end

@implementation MyMaretFrontTableViewController
@synthesize tapRecognizer = _tapRecognizer;


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


- (UITapGestureRecognizer *)tapRecognizer
{
    if (!_tapRecognizer) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.revealViewController
                                                                 action:@selector(revealToggle:)];
    }
    
    return _tapRecognizer;
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
    
    // Configure the nav bar color (UIViewController category)
    [self configureNavigationBarColor];
    
    // Add the button to open the drawer
    UIBarButtonItem *drawerButton = [[UIBarButtonItem alloc] init];
    
    [drawerButton setImage:[UIImage imageNamed:@"DrawerIcon7"]];
    
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



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        
        // Put the login viewcontroller inside a nav controller
        // (required for the google login controller)
        // but hide the nav bar initially
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:loginVC];
        
        [navController setNavigationBarHidden:YES];
        [navController.navigationBar setTintColor:[UIColor schoolColor]];
        [self presentViewController:navController animated:true completion:nil];
    }
}


- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    // If the drawer is open, the only interaction enabled
    // should be a tap on the front view to close the drawer
    if (position == FrontViewPositionLeft) {
        [self.view setUserInteractionEnabled:YES];
        [self.navigationController.view removeGestureRecognizer:[self tapRecognizer]];
    } else if (position == FrontViewPositionRight) {
        [self.view setUserInteractionEnabled:NO];
        [self.navigationController.view addGestureRecognizer:[self tapRecognizer]];
    }
}

@end
