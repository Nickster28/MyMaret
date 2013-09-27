//
//  AssignmentBookTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentBookTableViewController.h"
#import "AssignmentBookStore.h"
#import "Assignment.h"
#import "UIApplication+iOSVersionChecker.h"
#import "UIColor+SchoolColor.h"
#import "AppDelegate.h"
#import "AssignmentCreationTableViewController.h"
#import "AssignmentCell.h"

enum kMyMaretAssignmentBookView {
    kMyMaretAssignmentBookViewClass = 0,
    kMyMaretAssignmentBookViewDate = 1
    };

@interface AssignmentBookTableViewController () <AssignmentCreationDismisserDelegate, AssignmentCompletionProtocol>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bottomToolbarButton;
@property (nonatomic) NSUInteger assignmentBookViewIndex;

- (void)changeAssignmentBookView:(UISegmentedControl *)sender;
@end


// Store the user's last selection in NSUserDefaults
NSString * const MyMaretAssignmentBookViewPrefKey = @"MyMaretAssignmentBookViewPrefKey";


@implementation AssignmentBookTableViewController
@synthesize assignmentBookViewIndex = _assignmentBookViewIndex;



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
    [self setAssignmentBookViewIndex:[sender selectedSegmentIndex]];
}



- (NSUInteger)assignmentBookViewIndex
{
    if (!_assignmentBookViewIndex) {
        _assignmentBookViewIndex = [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretAssignmentBookViewPrefKey];
    }
    
    return _assignmentBookViewIndex;
}



- (void)setAssignmentBookViewIndex:(NSUInteger)assignmentBookViewIndex
{
    [[NSUserDefaults standardUserDefaults] setInteger:assignmentBookViewIndex
                                               forKey:MyMaretAssignmentBookViewPrefKey];
    
    _assignmentBookViewIndex = assignmentBookViewIndex;
    
    [self.tableView reloadData];
}


#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        return [[AssignmentBookStore sharedStore] numberOfAssignmentsForClassWithIndex:section];
    } else {
        return [[AssignmentBookStore sharedStore] numberOfAssignmentsForDayWithIndex:section];
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        return [[AssignmentBookStore sharedStore] nameOfClassWithIndex:section];
    } else {
        return [[AssignmentBookStore sharedStore] nameOfDayWithIndex:section];
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        return [[AssignmentBookStore sharedStore] numberOfClasses];
    } else {
        return [[AssignmentBookStore sharedStore] numberOfDaysWithAssignments];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning not updated to AssignmentCell - need date vs time
    static NSString *CellIdentifier = @"assignmentCell";
    AssignmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // We want to know when a user finishes an assignment
    [cell setDelegate:self];
    
    // Get the assignment at the given index
    Assignment *currentAssignment;
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        currentAssignment = [[AssignmentBookStore sharedStore] assignmentWithClassIndex:indexPath.section
                                                                        assignmentIndex:indexPath.row];
    } else {
        currentAssignment = [[AssignmentBookStore sharedStore] assignmentWithDayIndex:indexPath.section
                                                                      assignmentIndex:indexPath.row];
    }
    
    [[cell textLabel] setText:[currentAssignment assignmentName]];
    
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        [[cell detailTextLabel] setText:[currentAssignment dueDateAsString]];
    } else {
        [[cell detailTextLabel] setText:[currentAssignment className]];
    }
    
    return cell;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"createAnnouncement"] &&
        [[segue destinationViewController] isKindOfClass:[UINavigationController class]]) {
        
        AssignmentCreationTableViewController *createVC = [[(UINavigationController *)[segue destinationViewController] viewControllers] objectAtIndex:0];
        
        // Set ourselves as the delegate
        [createVC setDelegate:self];
    }
}


#pragma mark Dismisser Protocol

- (void)assignmentCreationTableViewControllerDidCreateAssignment:(AssignmentCreationTableViewController *)creationTVC
{
    // We have to refresh
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.tableView reloadData];
                             }];
}


- (void)assignmentCreationTableViewControllerDidCancelAssignmentCreation:(AssignmentCreationTableViewController *)creationTVC
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
