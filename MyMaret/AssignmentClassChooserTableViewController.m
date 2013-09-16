//
//  AssignmentClassChooserTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/16/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentClassChooserTableViewController.h"
#import "ClassScheduleStore.h"
#import "AssignmentCreationTableViewController.h"

@interface AssignmentClassChooserTableViewController ()
@property (nonatomic, strong) NSIndexPath *selectedIP;
@end

@implementation AssignmentClassChooserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[ClassScheduleStore sharedStore] numberOfClasses];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"classNameCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [[cell textLabel] setText:[[[ClassScheduleStore sharedStore] allClasses] objectAtIndex:indexPath.row]];
    
    // If it's the one the user has previously chosen, checkmark it - otherwise, no checkmark
    if ([[[cell textLabel] text] isEqualToString:[self selectedClassName]]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setSelectedIP:indexPath];
        
    } else [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user selected a new class...
    if (!self.selectedIP || (indexPath.row != self.selectedIP.row)) {
        
        // Remove the checkmark from the old choice
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:self.selectedIP];
        [oldCell setAccessoryType:UITableViewCellAccessoryNone];
        
        // Put a checkmark next to the newly selected cell
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        // Tell our delegate that we changed the selected class
        [self.delegate assignmentClassChooserTableViewController:self
                                          didSelectClassWithName:[[[ClassScheduleStore sharedStore] allClasses] objectAtIndex:indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Pop ourselves off the VC stack
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
