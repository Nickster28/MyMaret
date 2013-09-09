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


@interface ClassScheduleTableViewController () <ClassEditDismisserDelegate>
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
    
    [self.tableView reloadData];
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
        
        //[self.tableView reloadRowsAtIndexPaths:reloadIPs
          //                    withRowAnimation:UITableViewRowAnimationFade];
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
        
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
    // Don't display anything if we're not logged in
    if (![[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey])
        return 0;
    
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
    // Dismiss and update the given cell
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadRowsAtIndexPaths:@[updatedIP]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView selectRowAtIndexPath:updatedIP
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView deselectRowAtIndexPath:updatedIP animated:YES];

    });
}


- (void)schoolClassEditTableViewController:(SchoolClassEditTableViewController *)editTVC didCreateNewClassForSection:(NSUInteger)section
{
    // Dismiss an insert a new cell
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.tableView reloadData];
                             }];
}

@end
