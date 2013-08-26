//
//  CalendarViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "CalendarViewController.h"
#import "UIColor+SchoolColor.h"
#import "SWRevealViewController.h"


@interface CalendarViewController () <UIWebViewDelegate, SWRevealViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *calendarWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bottomToolbarButton;

- (void)changeCalendar:(UISegmentedControl *)sender;

@end

// The URLs for the two calendars
NSString * const SchoolAthleticsCalendarURLString = @"https://www.maret.org/mobile/index.aspx?v=c&mid=126&t=Athletic%20Events";

NSString * const SchoolGeneralCalendarURLString = @"https://www.maret.org/mobile/index.aspx?v=c&mid=120&t=Upper%20School";

// The URL that we don't want anyone going to
NSString * const SchoolMobileHomepageURLString = @"https://www.maret.org/mobile/index.aspx";

NSString * const MyMaretCalendarPrefKey = @"MyMaretCalendarPrefKey";


@implementation CalendarViewController


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
    
    [self setUpSegmentedControl];
}


- (void)setUpSegmentedControl
{
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"School Calendar", @"Athletics"]];
    
    [segControl addTarget:self
                   action:@selector(changeCalendar:)
         forControlEvents:UIControlEventValueChanged];
    
    
    if ([UIApplication isPrevIOS]) {
        [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    }
    
    [self.bottomToolbarButton setCustomView:segControl];
    
    [segControl setTintColor:[UIColor schoolColor]];
    
    // Set the selected index to be whatever is saved (or 0 if there is no
    // saved preference)
    [segControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MyMaretCalendarPrefKey]];
    
    [self changeCalendar:segControl];
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


// Make the given string into a URLRequest and have the webview
// load it while the activity indicator animates
- (void)loadWebURLString:(NSString *)urlString
{
    NSURL *calendarURL = [NSURL URLWithString:urlString];
    
    [self.calendarWebView loadRequest:[NSURLRequest requestWithURL:calendarURL]];
    [self.activityIndicator startAnimating];
}


- (void)changeCalendar:(UISegmentedControl *)sender
{
    // Save the user's choice if the app is closed
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex]
                                               forKey:MyMaretCalendarPrefKey];
    
    if ([sender selectedSegmentIndex] == 0) {
        [self loadWebURLString:SchoolGeneralCalendarURLString];
    } else {
        [self loadWebURLString:SchoolAthleticsCalendarURLString];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *urlToLoad = [request URL];
    NSURL *homeURL = [NSURL URLWithString:SchoolMobileHomepageURLString];
    
    if ([urlToLoad isEqual:homeURL]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Heads Up!"
                                                     message:@"This button has been disabled within MyMaret.  To view the full Maret mobile site, please visit maret.org in your browser."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return NO;
    }
    return YES;
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // If the load failed, stop the activity indicator
    // and show an alert view with a description of the error
    [self.activityIndicator stopAnimating];

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Calendar Error"
                                                 message:[error localizedDescription]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}







@end
