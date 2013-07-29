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

@end

@implementation MainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([UIApplication isPrevIOS]) {
        [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    } else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor darkGrayColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
