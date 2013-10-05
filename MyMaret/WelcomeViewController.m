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


@interface WelcomeViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *welcomeScrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *startButton;

// To keep track of page indices mid-animation
@property (nonatomic) NSUInteger newPageIndex;

- (IBAction)dismissWelcomeScreen:(id)sender;

@end

@implementation WelcomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Configure the scrollview's contents
    [[self welcomeScrollView] addSubview:[self contentView]];
    [[self welcomeScrollView] setContentSize:[self contentView].bounds.size];
    
    // Make a border around the imageview
    self.imageView.layer.borderWidth = 3.0;
    self.imageView.layer.borderColor = [[UIColor schoolComplementaryColor] CGColor];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Deactivate the start button for now
    [self.startButton setHidden:YES];
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
    // Calculate which page the user is on by using the scrollview's
    // offset from the first screen
    CGPoint offset = [scrollView contentOffset];
    NSUInteger newPageIndex = offset.x / self.welcomeScrollView.frame.size.width;
    
    [self setWelcomePage:newPageIndex];
}



- (void)setWelcomePage:(NSUInteger)pageIndex
{
    // If the user didn't actually scroll, do nothing
    if (pageIndex == [self.pageControl currentPage]) return;
    
    // Set the page control
    [self.pageControl setCurrentPage:pageIndex];

    
    // Keep track of the page we're going to so we can have the data
    // between methods (for animationDidStop:finished:)
    [self setNewPageIndex:pageIndex];
    
    // Activate the start button if we're going to the last screen
    if (pageIndex + 1 == self.pageControl.numberOfPages) {
        self.imageView.layer.borderWidth = 0.0;
        [self.startButton setHidden:NO];
    } else {
        [self.startButton setHidden:YES];
    }
    
    
    // Fade away the image view
    CABasicAnimation *fader = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fader setDuration:0.3];
    [fader setFromValue:[NSNumber numberWithFloat:1.0]];
    [fader setToValue:[NSNumber numberWithFloat:0.2]];
    [fader setDelegate:self];
    
    [self.imageView.layer setOpacity:0.2];
    [self.imageView.layer addAnimation:fader
                                forKey:@"fadeAnimation"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // Now replace the image
    NSString *newImageName = [NSString stringWithFormat:@"WelcomeImage%d", self.newPageIndex];
    [self.imageView setImage:[UIImage imageNamed:newImageName]];
    
    // and fade back in
    // Fade away the image view
    CABasicAnimation *unfader = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [unfader setDuration:0.3];
    [unfader setFromValue:[NSNumber numberWithFloat:0.2]];
    [unfader setToValue:[NSNumber numberWithFloat:1.0]];
    
    [self.imageView.layer setOpacity:1.0];
    [self.imageView.layer addAnimation:unfader
                                forKey:@"unfadeAnimation"];
    
    // If we swiped back from the final screen, re-add the border
    // around the image
    if (self.startButton.hidden) {
        self.imageView.layer.borderWidth = 3.0;
    }
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
