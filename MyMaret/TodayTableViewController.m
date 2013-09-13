//
//  TodayTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "TodayTableViewController.h"
#import "AppDelegate.h"
#import "AnnouncementsStore.h"
#import "NewspaperStore.h"
#import "ClassScheduleStore.h"
#import "SchoolClass.h"
#import "NewspaperArticle.h"
#import "Announcement.h"
#import "SchoolClassCell.h"
#import "TodayAnnouncementCell.h"
#import "NewspaperCell.h"
#import "TodaySettingsTableViewController.h"


@interface TodayTableViewController () <TodayIndexSetterDelegate>

@end

@implementation TodayTableViewController

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
    
    // Set the filter of the announcement store
    [[AnnouncementsStore sharedStore] setSearchFilterString:AnnouncementsStoreFilterStringToday];
    
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Unset the filter on the announcementsstore
    [[AnnouncementsStore sharedStore] setSearchFilterString:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numRows = 0;
    
    // We have to include this because we load this view controller
    // programatically (since it's the VC that modally presents the login screen)
    if (![[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey])
        return numRows;
    
    switch (section) {
        case 0:
            numRows = [[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:todayIndexKey];
            break;
            
        case 1:
            #warning Assignments here
            numRows = 0;
            break;
            
        case 2:
            numRows = [[AnnouncementsStore sharedStore] numberOfAnnouncements];
            break;
            
        case 3:
            
            // We only want articles in "Today" if the newspaper is new
            if ([[NewspaperStore sharedStore] isNewEditionOfNewspaper]) {
                
                // Section 0 is Popular Articles
                numRows = [[NewspaperStore sharedStore] numberOfArticlesInSection:@"Popular"];
            }
            
            break;
            
        default:
            numRows = -1;
            break;
    }
    
    if (numRows == 0) numRows++;
    
    return numRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 50.0;
            
        case 1:
            return 44.0;
            
        case 2:
            return 74.0;
            
        case 3:
            return 84.0;
            
        default:
            return 0.0;
    }
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Today's Classes";
            
        case 1:
            return @"Assignments Due Today";
            
        case 2:
            return @"Today's Announcements";
            
        case 3:
            return @"Popular Newspaper Articles";
            
        default:
            return @"Whoops!";
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [self classScheduleCellForIndexPath:indexPath];
            
        case 1:
            return [self assignmentCellForIndexPath:indexPath];
            
        case 2:
            return [self announcementCellForIndexPath:indexPath];
            
        case 3:
            return [self newspaperCellForIndexPath:indexPath];
            
        default:
            return nil;
    }
}



- (UITableViewCell *)classScheduleCellForIndexPath:(NSIndexPath *)ip
{
    // If there are no classes today...
    if ([[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:todayIndexKey] == 0) {
        
        // Return a cell that says that
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                     forIndexPath:ip];
        [[cell textLabel] setText:@"No Classes Today!"];
        
        return cell;
    } else if (ip.row == 0) {
        
        // Display our "Set today's schedule" cell
        return [self.tableView dequeueReusableCellWithIdentifier:@"daySettingsCell"
                                                    forIndexPath:ip];
    }
    
    // Otherwise, get the corresponding class object and make a cell displaying it
    SchoolClass *class = [[ClassScheduleStore sharedStore] classWithDayIndex:todayIndexKey
                                                                  classIndex:ip.row - 1];
    
    SchoolClassCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"classCell"
                                                                 forIndexPath:ip];
    [cell bindSchoolClass:class
          isAcademicClass:[[ClassScheduleStore sharedStore] isClassAcademicWithDayIndex:todayIndexKey
                                                                             classIndex:ip.row - 1]];
    
    return cell;
}


- (UITableViewCell *)assignmentCellForIndexPath:(NSIndexPath *)ip
{
#warning incomplete
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                 forIndexPath:ip];
    
    [[cell textLabel] setText:@"None!"];
    
    return cell;
}


- (UITableViewCell *)announcementCellForIndexPath:(NSIndexPath *)ip
{
    // If there are no announcements today...
    if ([[AnnouncementsStore sharedStore] numberOfAnnouncements] == 0) {
        
        // Return a cell that says that
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                     forIndexPath:ip];
        [[cell textLabel] setText:@"No Announcements Today"];
        
        return cell;
    }
    
    // Otherwise, get the corresponding class object and make a cell displaying it
    Announcement *currAnnouncement = [[AnnouncementsStore sharedStore] announcementAtIndex:ip.row];
    
    TodayAnnouncementCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"announcementCell"
                                                                 forIndexPath:ip];
    
    [cell bindAnnouncement:currAnnouncement];
    
    return cell;
}


- (UITableViewCell *)newspaperCellForIndexPath:(NSIndexPath *)ip
{
    // If there are no announcements today...
    if ([[NewspaperStore sharedStore] numberOfArticlesInSection:@"Popular"] == 0) {
        
        // Return a cell that says that
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                     forIndexPath:ip];
        [[cell textLabel] setText:@"No Recent Edition"];
        
        return cell;
    }
    
    // Otherwise, get the corresponding class object and make a cell displaying it
    NewspaperArticle *article = [[NewspaperStore sharedStore] articleInSection:@"Popular"
                                                                       atIndex:ip.row];
    
    NewspaperCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"newspaperCell"
                                                                 forIndexPath:ip];
    
    [cell bindArticle:article];
    
    return cell;
}


// Only reload the schedule if the day was changed
- (void)todaySettingsTableViewControllerDidOverrideTodayDayIndex:(TodaySettingsTableViewController *)settingsTVC
{
    [self.tableView reloadData];
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"todaySettingsSegue"] && [[segue destinationViewController] isKindOfClass:[TodaySettingsTableViewController class]]) {
        
        [(TodaySettingsTableViewController *)[segue destinationViewController] setDelegate:self];
    }
}



@end
