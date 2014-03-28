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
#import "AssignmentBookStore.h"
#import "SchoolClass.h"
#import "NewspaperArticle.h"
#import "Announcement.h"
#import "SchoolClassCell.h"
#import "AnnouncementCell.h"
#import "NewspaperCell.h"
#import "AssignmentCell.h"
#import "TodaySettingsTableViewController.h"
#import "AnnouncementDetailViewController.h"
#import "UIApplication+iOSVersionChecker.h"
#import "ArticleDetailViewController.h"


@interface TodayTableViewController () <TodayIndexSetterDelegate, AssignmentStateProtocol>

// Dictionary of section indices to BOOLs to keep track of whether the
// section is empty
// (we have to do this because we may not know if a section is empty when it has
// a "No items" cell).
@property (nonatomic, strong) NSMutableDictionary *emptySectionsDictionary;
@end

@implementation TodayTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Refresh today's assignments
    [[AssignmentBookStore sharedStore] refreshAssignmentsDueToday];
    
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![[AnnouncementsStore sharedStore] hasSearchFilterString]) {
        // Set the filter of the announcement store
        [[AnnouncementsStore sharedStore] setSearchFilterString:AnnouncementsStoreFilterStringToday];
    }
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
    self.emptySectionsDictionary = nil;
}


- (NSMutableDictionary *)emptySectionsDictionary
{
    if (!_emptySectionsDictionary) {
        
        _emptySectionsDictionary = [NSMutableDictionary dictionary];
        
        NSUInteger numKeys = [self.tableView numberOfSections];
        for (NSUInteger i = 0; i < numKeys; i++) {
            [_emptySectionsDictionary setObject:[NSNumber numberWithBool:FALSE]
                                   forKey:[NSNumber numberWithInteger:i]];
        }
    }
    
    return _emptySectionsDictionary;
}


- (void)setSection:(NSUInteger)sectionIndex isEmpty:(BOOL)isEmpty
{
    [[self emptySectionsDictionary] setObject:[NSNumber numberWithBool:isEmpty]
                                 forKey:[NSNumber numberWithInteger:sectionIndex]];
}


- (BOOL)sectionIsEmpty:(NSUInteger)sectionIndex
{
    return [[[self emptySectionsDictionary] objectForKey:[NSNumber numberWithInteger:sectionIndex]] boolValue];
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
    
    // We have to include this because we load this view controller when logging in
    // programatically (since it's the VC that modally presents the login screen)
    if (![[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey])
        return numRows;
    
    switch (section) {
        case 0:
            numRows = [[ClassScheduleStore sharedStore] numberOfPeriodsInDayWithIndex:todayIndexKey] + 1;
            break;
            
        case 1:
            numRows = [[AssignmentBookStore sharedStore] numberOfAssignmentsDueToday];
            break;
            
        case 2:
            // Make sure we're only looking at today
            if (![[AnnouncementsStore sharedStore] hasSearchFilterString]) {
                [[AnnouncementsStore sharedStore] setSearchFilterString:AnnouncementsStoreFilterStringToday];
            }
            
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
            
            // Shouldn't get here
            numRows = -1;
            break;
    }
    
    // Record whether or not the section is empty
    if (numRows == 0 || (section == 0 && numRows == 1)) [self setSection:section isEmpty:YES];
    else [self setSection:section isEmpty:NO];
    
    // If it is empty, then we want to put 1 cell there saying it's empty
    // This does NOT apply to the schedule section because we add 1 extra
    // row above for the "Set schedule day" button.  So if there is no schedule
    // today, THAT extra cell ends up acting as the "No content" cell.
    if (numRows == 0) numRows++;
    
    return numRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self sectionIsEmpty:indexPath.section]) return 44.0;
    
    switch (indexPath.section) {
        case 0:
            return 50.0;
            
        case 1:
            return 64.0;
            
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
            // Shouldn't get here
            return @"Whoops!";
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the section is empty, display a message in the section
    if ([self sectionIsEmpty:indexPath.section]) {
        return [self cellForEmptySectionWithIndex:indexPath.section];
    }
    
    // Otherwise, create a cell to display the correct entry in the given section
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



- (UITableViewCell *)cellForEmptySectionWithIndex:(NSUInteger)sectionIndex
{
    // Make a noEntriesCell that tells the user there are no entries for the given section
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noEntriesCell"
                                                                 forIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    
    switch (sectionIndex) {
        case 0:
            [[cell textLabel] setText:@"No Classes Today!"];
            break;
            
        case 1:
            [[cell textLabel] setText:@"None!"];
            break;
            
        case 2:
            [[cell textLabel] setText:@"No Announcements Today"];
            break;
            
        case 3:
            [[cell textLabel] setText:@"No Recent Edition"];
            break;
            
        default:
            [[cell textLabel] setText:@"Error: Could not fetch"];
            break;
    }
    
    return cell;
}



- (UITableViewCell *)classScheduleCellForIndexPath:(NSIndexPath *)ip
{
    if (ip.row == 0) {
        
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
    // get the corresponding assignment and make a cell displaying it
    Assignment *currAssignment = [[AssignmentBookStore sharedStore] assignmentDueTodayWithAssignmentIndex:ip.row];
    
    AssignmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"assignmentCell" forIndexPath:ip];
    
    [cell bindAssignment:currAssignment shouldDisplayDueTime:YES shouldDisplayClass:YES];
    
    // We should be notified if the user marks the assignment as completed
    [cell setAssignmentStateDelegate:self];
    
    return cell;
}


- (UITableViewCell *)announcementCellForIndexPath:(NSIndexPath *)ip
{

    // get the corresponding announcement object and make a cell displaying it
    Announcement *currAnnouncement = [[AnnouncementsStore sharedStore] announcementAtIndex:ip.row];
    
    AnnouncementCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"announcementCell"
                                                                 forIndexPath:ip];
    
    [cell bindAnnouncement:currAnnouncement];
    
    return cell;
}


- (UITableViewCell *)newspaperCellForIndexPath:(NSIndexPath *)ip
{
    // get the corresponding article object and make a cell displaying it
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the user selected an announcement...
    // (We need to do this manually because of the 2 different screens for iOS 6 + 7)
    if (indexPath.section == 2) {
        [[AnnouncementsStore sharedStore] markAnnouncementAtIndexAsRead:[indexPath row]];
        
        // Reload the cell to reflect that it's been read,
        // but make sure it's still selected!
        [tableView reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
        [tableView selectRowAtIndexPath:indexPath animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
        
        NSString *segueIdentifier = @"showAnnouncement7";
        if ([UIApplication isPrevIOS]) {
            segueIdentifier = @"showAnnouncement6";
        }
        
        // Trigger the detail view controller segue
        [self performSegueWithIdentifier:segueIdentifier
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // If the user wants to change what day today is...
    if ([[segue identifier] isEqualToString:@"todaySettingsSegue"] && [[segue destinationViewController] isKindOfClass:[TodaySettingsTableViewController class]]) {
        
        [(TodaySettingsTableViewController *)[segue destinationViewController] setDelegate:self];
        
    // If the user tapped on an announcement...
    } else if (([[segue identifier] isEqualToString:@"showAnnouncement6"] ||
                [[segue identifier] isEqualToString:@"showAnnouncement7"]) &&
               [[segue destinationViewController] isKindOfClass:[AnnouncementDetailViewController class]]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
    
    
        // Pass the announcement to the detail view controller
        [[segue destinationViewController] setAnnouncement:[[AnnouncementsStore sharedStore] announcementAtIndex:[selectedIndexPath row]]];
        
    
    // If the user tapped on a newspaper article...
    } else if ([[segue identifier] isEqualToString:@"showArticle"] && [[segue destinationViewController] isKindOfClass:[ArticleDetailViewController class]]) {
        
        ArticleDetailViewController *articleDVC = [segue destinationViewController];
        
        // Get the selected article from the correct tableview
        NSIndexPath *selectedIP = [self.tableView indexPathForCell:sender];

        NewspaperArticle *selectedArticle = [[NewspaperStore sharedStore] articleInSection:@"Popular" atIndex:[selectedIP row]];
        
        // Mark the article as read
        [[NewspaperStore sharedStore] markArticleAsReadInSection:@"Popular"
                                                         atIndex:[selectedIP row]];
        
        // Reload the cell to reflect that it's been read,
        // but make sure it's still selected!
        [self.tableView reloadRowsAtIndexPaths:@[selectedIP]
                                withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:selectedIP animated:NO
                                scrollPosition:UITableViewScrollPositionNone];
        
        // Give the article to the detail view controller
        [articleDVC setArticle:selectedArticle];
    }
    
}


#pragma mark AssignmentStateDelegate


// Called when the user marks an assignment as completed
- (void)setAssignmentCell:(AssignmentCell *)cell asCompleted:(BOOL)isCompleted
{
    // Find out which cell is being modified
    NSIndexPath *cellIP = [self.tableView indexPathForCell:cell];
    
    // Change the corresponding assignment's completion state
    [[AssignmentBookStore sharedStore] setAssignmentDueTodayWithAssignmentIndex:cellIP.row
                                                                    asCompleted:isCompleted];
}



// Called when the user deletes an assignment
- (void)deleteAssignmentCell:(AssignmentCell *)cell
{
    NSIndexPath *completedIP = [self.tableView indexPathForCell:cell];
    
    // Get the number of assignments for this class after we delete 1
    NSUInteger numAssignmentsInSection = [[AssignmentBookStore sharedStore] numberOfAssignmentsDueToday] - 1;
    
    // Remove the assignment
    [[AssignmentBookStore sharedStore] removeAssignmentDueTodayWithAssignmentIndex:completedIP.row];

    
    // If this is the last assignment, we need to remove its row and THEN ADD ANOTHER row
    // (The "No assignments" row)
    if (numAssignmentsInSection == 0) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[completedIP]
                              withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView insertRowsAtIndexPaths:@[completedIP]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
        // Otherwise, just remove the row
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[completedIP]
                              withRowAnimation:UITableViewRowAnimationRight];
    }
    
}



@end
