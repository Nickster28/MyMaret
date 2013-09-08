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
    return [[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SchoolClassCell";
    SchoolClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Get the class at the given index
    SchoolClass *currentClass = [[ClassScheduleStore sharedStore] classWithDayIndex:[indexPath section] classIndex:[indexPath row]];
    
    // Configure the cell...
    [cell bindSchoolClass:currentClass];
    
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editSchoolClass"] && [[segue destinationViewController] isKindOfClass:[SchoolClassEditTableViewController class]]) {
        
        // Get the index for the selected cell
        NSIndexPath *selectedIP = [self.tableView indexPathForCell:sender];
        
        // Pass the class to the editing table view controller
        SchoolClass *selectedClass = [[ClassScheduleStore sharedStore] classWithDayIndex:[selectedIP section] classIndex:[selectedIP row]];
        
        [[segue destinationViewController] setSelectedClass:selectedClass];
    }
}

@end
