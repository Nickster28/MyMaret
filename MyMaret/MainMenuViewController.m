//
//  MainMenuViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/28/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SWRevealViewController.h"
#import "UIApplication+iOSVersionChecker.h"
#import "PushNotificationUpdateable.h"


@interface MainMenuViewController ()
{
    // The background image
    IBOutlet UIView *mainMenuBackgroundView;
}


@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setSelectedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Set the background image
    [self.tableView setBackgroundView:[self mainMenuBackgroundView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView selectRowAtIndexPath:[self selectedIndexPath]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
}



- (UIView *)mainMenuBackgroundView
{
    if (!mainMenuBackgroundView) {
        
        // If we haven't already, load the XIB file containing the
        // background view
        [[NSBundle mainBundle] loadNibNamed:@"MainMenuBackgroundView"
                                      owner:self
                                    options:nil];
    }
    
    return mainMenuBackgroundView;
}


// Thanks to Max for suggesting this method for altering the height of a single row
// http://stackoverflow.com/questions/9823921/set-height-programmatically-for-a-single-uitableviewcell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return 53.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedIndexPath:indexPath];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]] && [segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        
        [(SWRevealViewControllerSegue *)segue setPerformBlock:^(SWRevealViewControllerSegue *segue, UIViewController *startVC, UIViewController *destinationVC) {
            
            [self.revealViewController setFrontViewController:destinationVC];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        }];
    }
    
    // If a UITableViewCell didn't trigger the segue and the segue isn't to
    // the today screen, then another view controller did, telling us that a push
    // notification was tapped and we should jump right to the content that was
    // updated
    if (![sender isKindOfClass:[UITableViewCell class]] && ![[segue identifier] isEqualToString:@"todaySegue"]) {
        
        UIViewController<PushNotificationUpdateable> *destinationVC = [[segue.destinationViewController viewControllers]objectAtIndex:0];
        
        // Tell the destination view controller that it should update its content
        [destinationVC reloadWhenShown];
    }
}


@end
