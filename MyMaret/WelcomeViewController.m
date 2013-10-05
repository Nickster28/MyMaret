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
@property (nonatomic, weak) IBOutlet UIScrollView *welcomeScrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@end

@implementation WelcomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Configure the scrollview's contents
    [[self welcomeScrollView] addSubview:[self contentView]];
    [[self welcomeScrollView] setContentSize:[self contentView].bounds.size];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}



- (UIView *)contentView
{
    if (!_contentView) {
        
        // Load the XIB file
        [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView"
                                      owner:self
                                    options:nil];
    }
    
    return _contentView;
}


#pragma mark UIScrollViewDelegate

// Track when the user finishes scrolling through sections and update the pagecontrol
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    NSUInteger newPageIndex = offset.x / self.welcomeScrollView.frame.size.width;
    [self.pageControl setCurrentPage:newPageIndex];
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
