//
//  AssignmentCreationTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentCreationTableViewController.h"
#import "TextEditCell.h"
#import "DateTimePickerCell.h"
#import "DateTimeDisplayCell.h"
#import "AssignmentClassChooserTableViewController.h"


@interface AssignmentCreationTableViewController ()
@property (nonatomic, strong) NSIndexPath *drawerParentIndexPath;
@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, strong) NSString *className;
@end

@implementation AssignmentCreationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    // We want to close the drawer when the keyboard pops up
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeDrawer)
                                                 name:UIKeyboardDidShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Closes the time setter drawer if it is visible
- (void)closeDrawer
{
    if (self.drawerIndexPath) {
        NSArray *indexesToDelete = @[self.drawerIndexPath];
        
        // Remove the drawer
        self.drawerIndexPath = nil;
        [self.tableView deleteRowsAtIndexPaths:indexesToDelete
                              withRowAnimation:UITableViewRowAnimationFade];
        
        
        // Also deselect the parent cell
        [self.tableView deselectRowAtIndexPath:[self drawerParentIndexPath]
                                      animated:YES];
        
        self.drawerParentIndexPath = nil;
    }
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.drawerIndexPath) return 4;
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger sec = indexPath.section;
    NSInteger drawerRow = self.drawerIndexPath.row;
    NSInteger drawerSec = self.drawerIndexPath.section;
    
    // The drawer is 163, the other cells are 44
    if (self.drawerIndexPath && drawerRow == row && drawerSec == sec) {
        return 163.0;
    }
    
    else return 44.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it's the name edit cell...
    if (indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"nameEditCell" forIndexPath:indexPath];
        
    // If it's the class selection cell...
    } else if (indexPath.row == 1) {
        UITableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:@"classCell" forIndexPath:indexPath];
        
        // Set the cell to show the selected class the assignment is for
        if (!self.className) {
            [[classCell detailTextLabel] setText:@"Choose Class"];
        } else [[classCell detailTextLabel] setText:self.className];
        
        return classCell;
        
    // If it's the due date cell...
    } else if (indexPath.row == 2) {
        DateTimeDisplayCell *dueDateCell = [tableView dequeueReusableCellWithIdentifier:@"dueDateCell" forIndexPath:indexPath];
        
        // Set the initial date to be now
        [dueDateCell setDate:[NSDate date]];
        
        return dueDateCell;
        
    // If it's the drawer... (We should only get here if the drawer is visible)
    } else if (indexPath.row == 3) {
        DateTimePickerCell *drawerCell = [tableView dequeueReusableCellWithIdentifier:@"dueDatePickerCell" forIndexPath:indexPath];
        
        DateTimeDisplayCell *parentCell = (DateTimeDisplayCell *)[tableView cellForRowAtIndexPath:self.drawerParentIndexPath];
        
        // Set the delegate to be its parent cell
        [drawerCell setDelegate:parentCell];
        
        // Set the date to be what's showing in the parent cell
        [drawerCell setDisplayedDate:parentCell.date];
        
        return drawerCell;
        
    // Shouldn't get past this!
    } else return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user taps the first row, pretend like they tapped on the text field
    if (indexPath.row == 0) {
        [(TextEditCell *)[tableView cellForRowAtIndexPath:indexPath] showKeyboard];
        return;
    }
    
    
    if (indexPath.row == 1) return;
    
    // If the user taps the drawer itself, ignore it
    if (self.drawerIndexPath && indexPath.row == self.drawerIndexPath.row) {
        [tableView selectRowAtIndexPath:self.drawerParentIndexPath
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
        return;
    }
    
    
    // If the keyboard is visible, dismiss it
    TextEditCell *nameCell = (TextEditCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [nameCell dismissKeyboard];
    
    
    // If the drawer is already visible, close it
    if (self.drawerIndexPath) {
        [self closeDrawer];
        return;
    }
    
    // Set the drawer index path accordingly
    self.drawerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                              inSection:indexPath.section];
    
    // Set the parent cell
    self.drawerParentIndexPath = indexPath;
    
    // Animate in the drawer
    [tableView insertRowsAtIndexPaths:@[self.drawerIndexPath]
                     withRowAnimation:UITableViewRowAnimationTop];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chooseClass"] && [[segue destinationViewController] isKindOfClass:[AssignmentClassChooserTableViewController class]]) {
        
        // Get the class the user previously chose (or "Choose Class" if the user hasn't picked one yet)
        NSString *chosenClassName = [[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                             inSection:0]] detailTextLabel] text];
        
        [[segue destinationViewController] setSelectedClassName:chosenClassName];
        [(AssignmentClassChooserTableViewController *)[segue destinationViewController] setDelegate:self];
        
        
        if (self.drawerIndexPath) {
            [self closeDrawer];
        }
    }
}



- (void)assignmentClassChooserTableViewController:(AssignmentClassChooserTableViewController *)chooserTVC didSelectClassWithName:(NSString *)name
{
    // Update our class name
    [self setClassName:name];
    
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:1 inSection:0];
    
    // Reload the cell displaying the selected class
    [self.tableView reloadRowsAtIndexPaths:@[rowToReload]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView selectRowAtIndexPath:rowToReload animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    
    [self.tableView deselectRowAtIndexPath:rowToReload animated:YES];
}


@end
