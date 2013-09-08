//
//  SchoolClassEditTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClassEditTableViewController.h"

@interface SchoolClassEditTableViewController () <UITextFieldDelegate>
@property (nonatomic, weak) UITextField *classNameTextField;
@property (nonatomic, weak) UISegmentedControl *classNamePrefSegControl;

// For handling the time-setting slide-out "drawer"
@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
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



// UITextFieldDelegate for dismissing keyboard when user hits
// "Done"
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}


- (void)saveScheduleChanges
{
    
}


#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            
        case 1:
            if (self.drawerIndexPath) return 3;
            return 2;
            
        case 2:
            return 1;
            
        default:
            return 0;
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
    
    if (self.drawerIndexPath && drawerRow == row && drawerSec == sec) {
        return 163.0;
    }
    
    else return 44.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.drawerIndexPath && indexPath.row == self.drawerIndexPath.row && indexPath.section == self.drawerIndexPath.section) {
     
        return [tableView dequeueReusableCellWithIdentifier:@"timePickerCell"];
    }
    
    // Thanks to http://stackoverflow.com/questions/9322885/combine-static-and-prototype-content-in-a-table-view
    // for helping me combine storyboard cells and XIB cells
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"nameEditCell"];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        return [tableView dequeueReusableCellWithIdentifier:@"nameSegControlCell"];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"startTimeCell"];
    } else if (indexPath.section == 1) {
        return [tableView dequeueReusableCellWithIdentifier:@"endTimeCell"];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"saveChangesCell"];
    } else return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user tapped the save button...
    if (indexPath.section == 2) {
        [self saveScheduleChanges];
        return;
    }
    
    if (indexPath.section != 1) return;
    
    double delayInSeconds = 0.0;
    BOOL shouldAdjustDrawerRow = YES;
    BOOL didTapAboveDrawer = (self.drawerIndexPath && indexPath.row + 1 == self.drawerIndexPath.row);
    
    // If the drawer is already visible
    if (self.drawerIndexPath) {
        
        // If the drawer is before the tapped row, we SHOULDN'T add 1
        // to the drawer row # at the end because removing a row will make
        // the rows below where the drawer was +1 higher than they should be
        if (self.drawerIndexPath.row <= indexPath.row) shouldAdjustDrawerRow = NO;
        
        NSArray *indexesToDelete = @[self.drawerIndexPath];
        
        // We want a slight delay between the deletion and insertion
        delayInSeconds = 0.3;
        
        self.drawerIndexPath = nil;
        
        // Remove the drawer
        [tableView deleteRowsAtIndexPaths:indexesToDelete
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
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
        
        // Animate in the drawer
        [tableView insertRowsAtIndexPaths:@[self.drawerIndexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
