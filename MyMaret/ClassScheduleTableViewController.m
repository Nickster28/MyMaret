//
//  ClassScheduleTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "ClassScheduleTableViewController.h"
#import "ClassScheduleStore.h"
#import "SchoolClass.h"
#import "SchoolClassCell.h"
#import "SchoolClassEditTableViewController.h"
#import "AppDelegate.h"


@interface ClassScheduleTableViewController () <ClassEditDismisserDelegate> {
    
    // To keep track of whether the sections have an extra "Add" row
    BOOL hasExtraRowAtEndOfSections;
}
@end

@implementation ClassScheduleTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Put an edit button in the top right
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    hasExtraRowAtEndOfSections = editing;
    
    //Make an array of the indexpaths of the last row in each section
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < [self.tableView numberOfSections]; i++) {
        NSUInteger numRowsInSec = [self.tableView numberOfRowsInSection:i];
        
        NSUInteger delta = (editing) ? 0 : -1;
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:numRowsInSec + delta
                                                 inSection:i]];
        
    }
    
    // Add them in editing mode - delete them in normal mode
    if (self.tableView.isEditing) {
        
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationTop];
        
    } else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationTop];
    }
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[ClassScheduleStore sharedStore] dayNameForIndex:section];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[ClassScheduleStore sharedStore] numberOfDays];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Account for the extra "add" cell when in editing mode
    if (tableView.isEditing)
        return [[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:section] + 1;
    
    else return [[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If this is the special "add" cell, return it
    if (tableView.isEditing && indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section]) {
        
        static NSString *CellIdentifier = @"AddClassCell";
        return [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    // Otherwise, configure a standard class cell
    } else {
        static NSString *CellIdentifier = @"SchoolClassCell";
        SchoolClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Get the class at the given index
        SchoolClass *currentClass = [[ClassScheduleStore sharedStore] classWithDayIndex:[indexPath section] classIndex:[indexPath row]];
        
        BOOL isAcademicClass = [[ClassScheduleStore sharedStore] isClassAcademicWithDayIndex:[indexPath section] classIndex:[indexPath row]];
        
        // Configure the cell...
        [cell bindSchoolClass:currentClass isAcademicClass:isAcademicClass];
        
        return cell;
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (hasExtraRowAtEndOfSections && indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section]) {
        
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row + 1 < [tableView numberOfRowsInSection:indexPath.section]) {
        return true;
    }
    
    return false;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[ClassScheduleStore sharedStore] moveClassOnDayIndex:sourceIndexPath.section
                                          fromClassIndex:sourceIndexPath.row
                                            toClassIndex:destinationIndexPath.row];
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSUInteger numSectionRows = [tableView numberOfRowsInSection:sourceIndexPath.section];
    
    // If the user's trying to jump sections, or if they're trying to put the
    // cell after the "Add period" button, don't let them
    if (proposedDestinationIndexPath.section != sourceIndexPath.section || (proposedDestinationIndexPath.section == sourceIndexPath.section && proposedDestinationIndexPath.row + 1 >= numSectionRows)) {
        
        return [NSIndexPath indexPathForRow:numSectionRows - 2
                                  inSection:sourceIndexPath.section];
    }
    
    // Otherwise, their move is fine
    return proposedDestinationIndexPath;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user wants to delete a cell, tell the store
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ClassScheduleStore sharedStore] deleteClassWithDayIndex:indexPath.section
                                                       classIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
    // If the user tapped on the "+" next to the "Add Period" cell,
    // pretend like they tapped on the cell itself
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self performSegueWithIdentifier:@"createSchoolClass" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Thanks to http://stackoverflow.com/questions/1269506/selecting-a-uitableviewcell-in-edit-mode for helping me have the cells
    // only selectable when in editing mode
    BOOL isEditingClass = [[segue identifier] isEqualToString:@"editSchoolClass"] && [[segue destinationViewController] isKindOfClass:[SchoolClassEditTableViewController class]];
    
    BOOL isCreatingClass = [[segue identifier] isEqualToString:@"createSchoolClass"] && [[segue destinationViewController] isKindOfClass:[UINavigationController class]];
    
    if (isEditingClass || isCreatingClass) {
        
        // Get the index for the selected cell
        NSIndexPath *selectedIP = [self.tableView indexPathForCell:sender];
        
        // Set the editing screen to the selected indexpath, and set us as the delegate
        if (isEditingClass) {
            [[segue destinationViewController] setSelectedIndexPath:selectedIP];
            [(SchoolClassEditTableViewController *)[segue destinationViewController] setDelegate:self];
        } else {
            
            SchoolClassEditTableViewController *editVC = [[(UINavigationController *)[segue destinationViewController] viewControllers] objectAtIndex:0];
            
            [editVC setSelectedIndexPath:selectedIP];
            [editVC setDelegate:self];
        }
    }
}



#pragma mark SchoolClassEditTableViewControllerDelegate


- (void)schoolClassEditTableViewControllerDidCancelClassCreation:(SchoolClassEditTableViewController *)editTVC
{
    // Dismiss and don't do anything
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)schoolClassEditTableViewController:(SchoolClassEditTableViewController *)editTVC didUpdateClassAtIndexPath:(NSIndexPath *)updatedIP
{
    // update the given cell
    [self.tableView reloadRowsAtIndexPaths:@[updatedIP]
                          withRowAnimation:UITableViewRowAnimationFade];
}


- (void)schoolClassEditTableViewController:(SchoolClassEditTableViewController *)editTVC didCreateNewClassForSection:(NSUInteger)section
{
    // Make a weak version of self to avoid a retain cycle
    ClassScheduleTableViewController * __weak weakSelf = self;
    // Dismiss an insert a new cell
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [weakSelf.tableView reloadData];
                             }];
}

@end
