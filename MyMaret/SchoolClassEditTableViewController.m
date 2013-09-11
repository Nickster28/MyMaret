//
//  SchoolClassEditTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClass.h"
#import "SchoolClassEditTableViewController.h"
#import "SchoolClassNameEditCell.h"
#import "SchoolClassTimeCell.h"
#import "SchoolClassTimeEditCell.h"
#import "ClassScheduleStore.h"


@interface SchoolClassEditTableViewController ()

// Keep track of where the drawer is
@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) SchoolClassTimeCell *drawerParentCell;
@property (nonatomic, weak) SchoolClass *selectedClass;

@end

@implementation SchoolClassEditTableViewController

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



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Change the navItem title depending on what we're doing
    if (self.selectedClass) {
        self.navigationItem.title = @"Edit Class";
    } else {
        self.navigationItem.title = @"Create Class";
        
        // If we're creating a new class, put a cancel button in the top left
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClassCreation)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    
    // If we're inside a nav controller,
    // we're making a new class so we shouldn't fetch one from the ClassScheduleStore
    if (!self.navigationController) {
        [self setSelectedClass:[[ClassScheduleStore sharedStore] classWithDayIndex:selectedIndexPath.section classIndex:selectedIndexPath.row]];
    }
}


- (void)cancelClassCreation
{
    // Tell our delegate we didn't create anything
    [self.delegate schoolClassEditTableViewControllerDidCancelClassCreation:self];
}



// Closes the time setter drawer if it is visible
- (void)closeDrawer
{
    if (self.drawerIndexPath) {
        NSArray *indexesToDelete = @[self.drawerIndexPath];
        
        self.drawerIndexPath = nil;
        
        // Remove the drawer
        [self.tableView deleteRowsAtIndexPaths:indexesToDelete
                              withRowAnimation:UITableViewRowAnimationFade];

        
        // Also deselect the parent cell
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:self.drawerParentCell]
                                      animated:YES];
        
        self.drawerParentCell = nil;
    }
}


- (void)changeParentCellTime:(UIDatePicker *)sender
{
    NSDate *displayedDate = [sender date];
    
    // We just want the hour and minutes in a string
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:displayedDate];
    
    // Account for military time
    if (dateComps.hour > 12) dateComps.hour -= 12;
    
    // Make sure if the minutes are only 1 digit that there is a leading 0
    NSString *minutesString = (dateComps.minute < 10) ? [NSString stringWithFormat:@"0%d", dateComps.minute] :
    [NSString stringWithFormat:@"%d", dateComps.minute];
    
    NSString *timeString = [NSString stringWithFormat:@"%d:%@", dateComps.hour, minutesString];
    
    // Set the parent cell to display that time
    [self.drawerParentCell setDisplayedClassTime:timeString];
}


- (void)saveScheduleChanges
{
    // Get the entered classname
    NSString *name = [(SchoolClassNameEditCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] enteredClassName];
    
    // Get the start time
    NSString *startTime = [(SchoolClassTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] enteredClassTime];
    
    // The row number of the end time cell will vary depending on where the
    // drawer is
    NSUInteger endTimeCellRowNum = (self.drawerIndexPath && self.drawerIndexPath.row == 1) ? 2 : 1;
    NSString *endTime = [(SchoolClassTimeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endTimeCellRowNum inSection:1]] enteredClassTime];
    
    // Combine the start and end times
    NSString *classTime = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
    
    // If we're editing a class, change the info in the store and pop ourselves off the
    // view controller stack
    if (self.selectedClass) {
        
        // Change the class info
        [[ClassScheduleStore sharedStore] setClassName:name
                                             classTime:classTime
                                  forClassWithDayIndex:self.selectedIndexPath.section
                                            classIndex:self.selectedIndexPath.row];
        
        // Tell our delegate that we changed a class
        [self.delegate schoolClassEditTableViewController:self
                                didUpdateClassAtIndexPath:self.selectedIndexPath];
        
    } else {
        
        // Otherwise, we need to create a new class
        [[ClassScheduleStore sharedStore] addClassWithName:name
                                                      time:classTime
                                       toEndOfDayWithIndex:self.selectedIndexPath.section];
        
        // Tell our delegate that we created a new class
        [self.delegate schoolClassEditTableViewController:self
                              didCreateNewClassForSection:self.selectedIndexPath.section];
    }
}


#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            
        case 1:
            if (self.drawerIndexPath) return 3;
            return 2;
            
        case 2:
            return 1;
            
        default:
            return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Class Name";
        
        case 1:
            return @"Class Time";
        
        default:
            return @"";
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    
    // Thanks to http://stackoverflow.com/questions/9322885/combine-static-and-prototype-content-in-a-table-view
    // for helping me combine storyboard cells and XIB cells
    if (self.drawerIndexPath && indexPath.row == self.drawerIndexPath.row && indexPath.section == self.drawerIndexPath.section) {
        
        SchoolClassTimeEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timePickerCell"
                                                                        forIndexPath:indexPath];
        
        // Set the picker to display the same time as its parent cell
        [cell setDisplayedClassTime:[self.drawerParentCell enteredClassTime]];
        
        // Set the picker to send us a message each time the user changes the time
        [[cell classTimePicker] addTarget:self
                                   action:@selector(changeParentCellTime:)
                         forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    } else if (indexPath.section == 0) {
        
        SchoolClassNameEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameEditCell"
                                                                        forIndexPath:indexPath];
        
        // If we're editing a class, display its name in the text field
        if (self.selectedClass) {
            // Set the cell's text field to initially display the class title
            [cell setDisplayedClassName:[[self selectedClass] className]];
        } else [cell setDisplayedClassName:@""];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        SchoolClassTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"
                                                                    forIndexPath:indexPath];
        
        // Get the class's start/end time
        NSArray *times;
        if (self.selectedClass)
            times = [[[self selectedClass] classTime] componentsSeparatedByString:@"-"];
        else times = @[@"8:10", @"9:00"];
        
        // If this is the class start time cell, set the text to be the start time (which is
        // at index 0 in the times array).  Otherwise, it's the end time (at index 1 in the
        // times array)
        [cell setIsStartTimeCell:indexPath.row == 0];
        [cell setDisplayedClassTime:times[(indexPath.row == 0) ? 0 : 1]];
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
        UITableViewCell *saveChangesCell = [tableView dequeueReusableCellWithIdentifier:@"saveChangesCell"
                                                                           forIndexPath:indexPath];
        
        if (self.selectedClass) [[saveChangesCell textLabel] setText:@"Save Changes"];
        else [[saveChangesCell textLabel] setText:@"Create Class"];
        
        return saveChangesCell;
        
    // Shouldn't reach here!
    } else return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't let the user select the first row
    if (indexPath.section == 0) return;
    
    // If the keyboard is visible, dismiss it
    SchoolClassNameEditCell *nameCell = (SchoolClassNameEditCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [nameCell dismissKeyboard];
    
    
    // If the user tapped the save button...
    if (indexPath.section == 2) {
        [self saveScheduleChanges];
        return;
    }
    
    
    double delayInSeconds = 0.0;
    BOOL shouldAdjustDrawerRow = YES;
    BOOL didTapAboveDrawer = (self.drawerIndexPath && indexPath.row + 1 == self.drawerIndexPath.row);
    
    // If the drawer is already visible
    if (self.drawerIndexPath) {
        
        // If the drawer is before the tapped row, we SHOULDN'T add 1
        // to the drawer row # at the end because removing a row will make
        // the rows below where the drawer was +1 higher than they should be
        if (self.drawerIndexPath.row <= indexPath.row) shouldAdjustDrawerRow = NO;
        
        delayInSeconds = 0.3;
        
        
        
        [self closeDrawer];
        
        
    }
    
    if (didTapAboveDrawer) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // Set the drawer index path accordingly
        if (shouldAdjustDrawerRow) {
            self.drawerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                      inSection:indexPath.section];
        } else self.drawerIndexPath = indexPath;
        
        // Set the parent cell
        self.drawerParentCell = (SchoolClassTimeCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.drawerIndexPath.row - 1 inSection:self.drawerIndexPath.section]];
        
        // Animate in the drawer
        [tableView insertRowsAtIndexPaths:@[self.drawerIndexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    });
}


@end
