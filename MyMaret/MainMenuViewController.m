//
//  MainMenuViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/28/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SWRevealViewController.h"


@interface MainMenuViewController ()
{
    // The background image
    IBOutlet UIView *mainMenuBackgroundView;
}

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation MainMenuViewController
@synthesize selectedIndexPath = _selectedIndexPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setSelectedIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (indexPath.row == 0) {
        if ([UIApplication isPrevIOS]) return 0.0;
        else return 20.0;
    }
    
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
}


@end
