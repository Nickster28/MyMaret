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

@interface ClassScheduleTableViewController ()
@end

@implementation ClassScheduleTableViewController

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
    
    // Put an edit button in the top right
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    //Make an array of the indexpaths of the last row in each section
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        NSUInteger numRowsInSec = [self.tableView numberOfRowsInSection:i];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:numRowsInSec - 1
                                                 inSection:i]];
        
    }
    
    // Add them in editing mode - delete them in normal mode
    if (self.tableView.isEditing) {
        
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationTop];
        
        
        // We also want to reload the currently visible cells
        NSMutableArray *reloadIPs = [NSMutableArray array];
        
        NSArray *visibleCells = self.tableView.visibleCells;
        for (UITableViewCell *cell in visibleCells) {
            [reloadIPs addObject:[self.tableView indexPathForCell:cell]];
        }
        
        [self.tableView reloadRowsAtIndexPaths:reloadIPs
                              withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationTop];
    }
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
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
        
        // Configure the cell...
        [cell bindSchoolClass:currentClass];
        
        return cell;
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing && indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section]) {
        
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row + 1 < [tableView numberOfRowsInSection:indexPath.section])
        return true;
    
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
    // If the user's trying to jump sections, keep them within their own section
    if (proposedDestinationIndexPath.section != sourceIndexPath.section) {
        
        // If we're in the same section but the user's trying to move past the
        // "Add Period" cell, don't let them
        if (proposedDestinationIndexPath.row + 1 == [tableView numberOfRowsInSection:proposedDestinationIndexPath.section]) {
            
            return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row -1
                                      inSection:sourceIndexPath.section];
        }
        
        return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row
                                  inSection:sourceIndexPath.section];
    }
    
    // If we're in the same section but the user's trying to move past the
    // "Add Period" cell, don't let them
    if (proposedDestinationIndexPath.row + 1 == [tableView numberOfRowsInSection:proposedDestinationIndexPath.section]) {
        
        return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row -1
                                  inSection:proposedDestinationIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Thanks to http://stackoverflow.com/questions/1269506/selecting-a-uitableviewcell-in-edit-mode for helping me have the cells
    // only selectable when in editing mode
    if ([[segue identifier] isEqualToString:@"editSchoolClass"] && [[segue destinationViewController] isKindOfClass:[SchoolClassEditTableViewController class]]) {
        
        // Get the index for the selected cell
        NSIndexPath *selectedIP = [self.tableView indexPathForCell:sender];
        
        // Pass the class to the editing table view controller
        SchoolClass *selectedClass = [[ClassScheduleStore sharedStore] classWithDayIndex:[selectedIP section] classIndex:[selectedIP row]];
        
        [[segue destinationViewController] setSelectedClass:selectedClass];
    }
}

@end
