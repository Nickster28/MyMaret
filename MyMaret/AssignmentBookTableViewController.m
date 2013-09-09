//
//  AssignmentBookTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentBookTableViewController.h"
#import "UIApplication+iOSVersionChecker.h"
#import "UIColor+SchoolColor.h"


@interface AssignmentBookTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bottomToolbarButton;

- (void)changeAssignmentBookView:(UISegmentedControl *)sender;
@end


// Store the user's last selection in NSUserDefaults
NSString * const MyMaretAssignmentBookViewPrefKey = @"MyMaretAssignmentBookViewPrefKey";


@implementation AssignmentBookTableViewController

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
    
    [self setUpSegmentedControl];
}



- (void)setUpSegmentedControl
{
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"View By Class", @"View By Due Date"]];
    
    [segControl addTarget:self
                   action:@selector(changeAssignmentBookView:)
         forControlEvents:UIControlEventValueChanged];
    
    
    if ([UIApplication isPrevIOS]) {
        [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    }
    
    [self.bottomToolbarButton setCustomView:segControl];
    
    [segControl setTintColor:[UIColor schoolColor]];
    
    // Set the selected index to be whatever is saved (or 0 if there is no
    // saved preference)
    [segControl setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MyMaretAssignmentBookViewPrefKey]];
    
    [self changeAssignmentBookView:segControl];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeAssignmentBookView:(UISegmentedControl *)sender
{
    // Save the user's choice if the app is closed
    [[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex]
                                               forKey:MyMaretAssignmentBookViewPrefKey];
    
    if ([sender selectedSegmentIndex] == 0) {
        
    } else {
        
    }
}

@end
