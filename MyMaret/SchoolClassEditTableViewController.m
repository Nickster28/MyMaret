//
//  SchoolClassEditTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClass.h"
#import "SchoolClassEditTableViewController.h"
#import "TextEditCell.h"
#import "DateTimeDisplayCell.h"
#import "DateTimePickerCell.h"
#import "ClassScheduleStore.h"
#import "UIViewController+NavigationBarColor.h"


@interface SchoolClassEditTableViewController ()

// Keep track of where the drawer is
@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, strong) NSIndexPath *drawerParentIndexPath;
@property (nonatomic, strong) SchoolClass *selectedClass;

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



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // If we're being dismissed, if we're updating a class
    // we should automatically save changes
    if (self.selectedClass) [self saveScheduleChanges];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Configure the nav bar color (UIViewController category)
    [self configureNavigationBarColor];
    
    
    // Change the navItem title depending on what we're doing
    if (self.selectedClass) {
        self.navigationItem.title = @"Edit Class";
    } else {
        self.navigationItem.title = @"Create Class";
        
        // If we're creating a new class, put a cancel button in the top left
        // and a done button in the top right
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClassCreation)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveScheduleChanges)];
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
    
    // If we're not inside a nav controller,
    // we're updating a class so get it from the ClassScheduleStore
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



- (void)saveScheduleChanges
{
    // Get the entered classname
    NSString *name = [(TextEditCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] enteredText];
    
    // Get the start time (remember that timeText returns the time WITH am/pm!)
    NSString *startTime = [(DateTimeDisplayCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] timeText];
    startTime = [startTime substringToIndex:startTime.length - 3];
    
    // The row number of the end time cell will vary depending on where the
    // drawer is
    NSUInteger endTimeCellRowNum = (self.drawerIndexPath && self.drawerIndexPath.row == 1) ? 2 : 1;
    NSString *endTime = [(DateTimeDisplayCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:endTimeCellRowNum inSection:1]] timeText];
    endTime = [endTime substringToIndex:endTime.length - 3];
    
    
    // Combine the start and end times
    NSString *classTime = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
    
    // If we're editing a class, change the info in the store and pop ourselves off the
    // view controller stack
    if (self.selectedClass) {
        
        // If the user actually changed something...
        if (![self.selectedClass.className isEqualToString:name] || ![self.selectedClass.classTime isEqualToString:classTime]) {
            
            // Change the class info
            [[ClassScheduleStore sharedStore] setClassName:name
                                                 classTime:classTime
                                      forClassWithDayIndex:self.selectedIndexPath.section
                                                classIndex:self.selectedIndexPath.row];
            
            // Tell our delegate that we changed a class
            [self.delegate schoolClassEditTableViewController:self
                                    didUpdateClassAtIndexPath:self.selectedIndexPath];
        }
        
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
    return 2;
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
    
    // If it's the drawer...
    if (self.drawerIndexPath && indexPath.row == self.drawerIndexPath.row && indexPath.section == self.drawerIndexPath.section) {
        
        DateTimePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timePickerCell"
                                                                        forIndexPath:indexPath];
        
        // Set the drawer's delegate to be its parent so it can communicate what date
        // or time it's displaying to its parent
        [cell setDelegate:(DateTimeDisplayCell *)[tableView cellForRowAtIndexPath:self.drawerParentIndexPath]];
        
        // Get the time it should display from its parent
        NSString *timeToDisplay = [(DateTimeDisplayCell *)[tableView cellForRowAtIndexPath:self.drawerParentIndexPath] timeText];
        
        [cell setDisplayedTime:timeToDisplay];
        
        return cell;
        
    // If it's the name edit cell...
    } else if (indexPath.section == 0) {
        
        TextEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameEditCell"
                                                                        forIndexPath:indexPath];
        
        // If we're editing a class, display its name in the text field
        if (self.selectedClass) {
            // Set the cell's text field to initially display the class title
            [cell setDisplayedText:[[self selectedClass] className]];
        } else [cell setDisplayedText:@""];
        
        return cell;
        
    // If it's the time display cells...
    } else if (indexPath.section == 1) {
        
        DateTimeDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"
                                                                    forIndexPath:indexPath];
        
        // Get the class's start/end time
        // (Or the generic start/end times if we're creating a new class)
        NSMutableArray *classTimes = [NSMutableArray array];
        
        if (self.selectedClass) {
            NSArray *times = [[[self selectedClass] classTime] componentsSeparatedByString:@"-"];
            
            // We need to add am/pm to each time
            for (NSString *time in times) {
                
                NSArray *timeComponents = [time componentsSeparatedByString:@":"];
                
                // If it's in the morning, add "am"
                if ([timeComponents[0] integerValue] >= 7 && [timeComponents[0] integerValue] < 12) {
                    [classTimes addObject:[NSString stringWithFormat:@"%@ AM", time]];
                    
                // Otherwise, add "pm"
                } else [classTimes addObject:[NSString stringWithFormat:@"%@ PM", time]];
            }
            
        } else classTimes = [NSMutableArray arrayWithArray:@[@"8:10 AM", @"9:00 AM"]];
        
        
        // If this is the class start time cell, set the text to be the start time (which is
        // at index 0 in the times array).  Otherwise, it's the end time (at index 1 in the
        // times array)
        if (indexPath.row == 0) {
            [cell setTitleText:@"Start Time"];
            [cell setTimeText:classTimes[0]];
        } else {
            [cell setTitleText:@"End Time"];
            [cell setTimeText:classTimes[1]];
        }
        
        return cell;
        
    // Shouldn't reach here!
    } else return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user taps the first row, pretend like they tapped on the text field
    if (indexPath.section == 0) {
        [(TextEditCell *)[tableView cellForRowAtIndexPath:indexPath] showKeyboard];
        return;
    }
    
    
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
        self.drawerParentIndexPath = [NSIndexPath indexPathForRow:self.drawerIndexPath.row - 1 inSection:self.drawerIndexPath.section];
        
        // Animate in the drawer
        [tableView insertRowsAtIndexPaths:@[self.drawerIndexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    });
}


@end
