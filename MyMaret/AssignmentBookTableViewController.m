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

@interface AssignmentBookTableViewController () <AssignmentCreationDismisserDelegate, AssignmentStateProtocol>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bottomToolbarButton;
@property (nonatomic) NSUInteger assignmentBookViewIndex;

- (void)changeAssignmentBookView:(UISegmentedControl *)sender;
@end


// Store the user's last selection in NSUserDefaults
NSString * const MyMaretAssignmentBookViewPrefKey = @"MyMaretAssignmentBookViewPrefKey";


@implementation AssignmentBookTableViewController
@synthesize assignmentBookViewIndex = _assignmentBookViewIndex;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpSegmentedControl];
    
    // Delete old assignments - if there were old assignments,
    // reload the table
    if ([[AssignmentBookStore sharedStore] removeOldAssignments]) {
        [self.tableView reloadData];
    }
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
    [segControl setSelectedSegmentIndex:self.assignmentBookViewIndex];
    
    [self changeAssignmentBookView:segControl];
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
        return [[AssignmentBookStore sharedStore] numberOfClassesWithAssignments];
    } else {
        return [[AssignmentBookStore sharedStore] numberOfDaysWithAssignments];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"assignmentCell";
    AssignmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // We want to know when a user finishes an assignment
    [cell setAssignmentStateDelegate:self];
    
    // Get the assignment at the given index
    Assignment *currentAssignment;
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        currentAssignment = [[AssignmentBookStore sharedStore] assignmentWithClassIndex:indexPath.section
                                                                        assignmentIndex:indexPath.row];
    } else {
        currentAssignment = [[AssignmentBookStore sharedStore] assignmentWithDayIndex:indexPath.section
                                                                      assignmentIndex:indexPath.row];
    }
    
    // Display the appropriate info in the cell
    // (If we're viewing by class, display the due date and assignment only -
    // If we're viewing by day, display the due time, class, and assignment)
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        [cell bindAssignment:currentAssignment shouldDisplayDueTime:NO shouldDisplayClass:NO];
    } else {
        [cell bindAssignment:currentAssignment shouldDisplayDueTime:YES shouldDisplayClass:YES];
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



#pragma mark AssignmentStateDelegate


// Called when the user marks an assignment as completed or not completed
- (void)setAssignmentCell:(AssignmentCell *)cell asCompleted:(BOOL)isCompleted
{
    // Find out which cell is being modified
    NSIndexPath *cellIP = [self.tableView indexPathForCell:cell];
    
    // Change the corresponding assignment's completion state
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        [[AssignmentBookStore sharedStore] setAssignmentWithClassIndex:cellIP.section
                                                       assignmentIndex:cellIP.row
                                                           asCompleted:isCompleted];
    } else {
        [[AssignmentBookStore sharedStore] setAssignmentWithDayIndex:cellIP.section
                                                     assignmentIndex:cellIP.row
                                                         asCompleted:isCompleted];
    }
}
    
    
    
// Called when the user deletes an assignment
- (void)deleteAssignmentCell:(AssignmentCell *)cell
{
    NSIndexPath *completedIP = [self.tableView indexPathForCell:cell];
    
    NSUInteger numAssignmentsInSection;
    
    // Delete the assignment from the store
    if ([self assignmentBookViewIndex] == kMyMaretAssignmentBookViewClass) {
        
        // Get the number of assignments for this class after we delete 1
        numAssignmentsInSection = [[AssignmentBookStore sharedStore] numberOfAssignmentsForClassWithIndex:completedIP.section] - 1;
        
        [[AssignmentBookStore sharedStore] removeAssignmentWithClassIndex:completedIP.section
                                                          assignmentIndex:completedIP.row];
    } else {
        
        // Get the number of assignments for this day after we delete 1
        numAssignmentsInSection = [[AssignmentBookStore sharedStore] numberOfAssignmentsForDayWithIndex:completedIP.section] - 1;
        
        [[AssignmentBookStore sharedStore] removeAssignmentWithDayIndex:completedIP.section
                                                        assignmentIndex:completedIP.row];
    }
    
    // Remove the assignment from our table
    // If this was the only assignment in the section, remove the whole section
    // Otherwise, just remove the row
    if (numAssignmentsInSection == 0) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:completedIP.section]
                      withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[completedIP]
                              withRowAnimation:UITableViewRowAnimationFade];
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
