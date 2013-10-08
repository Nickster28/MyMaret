//
//  TodaySettingsTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "TodaySettingsTableViewController.h"
#import "ClassScheduleStore.h"

@interface TodaySettingsTableViewController ()
@property (nonatomic, strong) NSIndexPath *selectedIP;
@end

@implementation TodaySettingsTableViewController



- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Figure out what day it is
    [self setSelectedIP:[NSIndexPath indexPathForRow:[[ClassScheduleStore sharedStore] todayDayIndex] inSection:0]];
}


#pragma mark UITableView Data Source/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Today is a...";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dayCell" forIndexPath:indexPath];
    
    // Set the label's text
    NSString *labelText = [NSString stringWithFormat:@"%@ Schedule", [[ClassScheduleStore sharedStore] dayNameForIndex:indexPath.row]];
    [[cell textLabel] setText:labelText];
    
    // Only put a check next to the cell if it's today
    if (indexPath.row == self.selectedIP.row) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user selected a new day...
    if (indexPath.row != self.selectedIP.row) {
        
        // Remove the checkmark from the old choice
        __weak UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:self.selectedIP];
        [oldCell setAccessoryType:UITableViewCellAccessoryNone];
        
        // Put a checkmark next to the newly selected cell
        __weak UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        // Tell the store to override the today index
        [[ClassScheduleStore sharedStore] overrideTodayIndexWithIndex:indexPath.row];
        
        // Tell our delegate that we changed the today day index
        [self.delegate todaySettingsTableViewControllerDidOverrideTodayDayIndex:self];
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
