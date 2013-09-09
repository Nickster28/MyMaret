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


@interface TodayTableViewController ()

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
    
    // Set the filters of all the stores
    [[AnnouncementsStore sharedStore] setSearchFilterString:AnnouncementsStoreFilterStringToday];
    [[NewspaperStore sharedStore] setSearchFilterString:NewspaperStoreFilterStringPopular];
    
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show the login screen if the user hasn't logged in yet
    if (![[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey]) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self performSegueWithIdentifier:@"showLoginScreen"
                                      sender:self];
        });
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Unset the filters on all the stores
    [[AnnouncementsStore sharedStore] setSearchFilterString:nil];
    [[NewspaperStore sharedStore] setSearchFilterString:nil];
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
            numRows = [[NewspaperStore sharedStore] numberOfArticlesInSection:nil];
            break;
            
        default:
            numRows = -1;
            break;
    }
    
    if (numRows == 0) numRows++;
    
    return numRows;
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
    }
    
    // Otherwise, get the corresponding class object and make a cell displaying it
    SchoolClass *class = [[ClassScheduleStore sharedStore] classWithDayIndex:todayIndexKey
                                                                  classIndex:ip.row];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"classCell"
                                                                 forIndexPath:ip];
    [[cell textLabel] setText:class.className];
    [[cell detailTextLabel] setText:class.classTime];
    
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"announcementCell"
                                                                 forIndexPath:ip];
    
    [[cell textLabel] setText:currAnnouncement.announcementTitle];
    [[cell detailTextLabel] setText:currAnnouncement.announcementAuthor];
    
    return cell;
}


- (UITableViewCell *)newspaperCellForIndexPath:(NSIndexPath *)ip
{
    // If there are no announcements today...
    if ([[NewspaperStore sharedStore] numberOfArticlesInSection:@""] == 0) {
        
        // Return a cell that says that
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                     forIndexPath:ip];
        [[cell textLabel] setText:@"No Recent Edition"];
        
        return cell;
    }
    
    // Otherwise, get the corresponding class object and make a cell displaying it
    NewspaperArticle *article = [[NewspaperStore sharedStore] articleInSection:@""
                                                                       atIndex:ip.row];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"newspaperCell"
                                                                 forIndexPath:ip];
    
    [[cell textLabel] setText:article.articleTitle];
    [[cell detailTextLabel] setText:article.articleAuthor];
    
    return cell;
}


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
