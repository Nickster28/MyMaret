//
//  AnnouncementsTableViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementsTableViewController.h"
#import "AnnouncementsStore.h"
#import "Announcement.h"
#import "UIColor+SchoolColor.h"
#import "AnnouncementCell.h"
#import "AnnouncementDetailViewController.h"
#import "AppDelegate.h"


@interface AnnouncementsTableViewController () <UISearchDisplayDelegate>

@end

@implementation AnnouncementsTableViewController


- (void)awakeFromNib
{
    // Register for the new announcement notification
    // to have the table refresh when a notification comes in
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAnnouncements)
                                                 name:MyMaretNewAnnouncementNotification
                                               object:nil];
}


- (void)dealloc
{
    // Remove ourselves from NSNotificationCenter
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Add an Edit button in the navigation bar
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Add the tableView's refresh control for refreshing announcements
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor schoolColor]];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAnnouncements)
                  forControlEvents:UIControlEventValueChanged];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refreshAnnouncements
{
    [self.refreshControl beginRefreshing];
    
    [[AnnouncementsStore sharedStore] fetchAnnouncementsWithCompletionBlock:^(NSUInteger numAdded, NSError *err) {
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Refresh Error"
                                                         message:[err localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        } else {
            // Make an array of all the NSIndexPaths to insert
            NSMutableArray *rowsToInsert = [NSMutableArray array];
            for (int i = 0; i < numAdded; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i
                                                     inSection:0];
                [rowsToInsert addObject:ip];
            }
            
            [self.tableView insertRowsAtIndexPaths:rowsToInsert
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark - Tableview Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the count for both the regular announcements tableview and the
    // search results tableview
    return [[AnnouncementsStore sharedStore] numberOfAnnouncements];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Register the cell's NIB file
    [tableView registerNib:[UINib nibWithNibName:@"AnnouncementCell"
                                          bundle:nil]
    forCellReuseIdentifier:@"announcementCell"];
    
    AnnouncementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"announcementCell"
                                                             forIndexPath:indexPath];
    
    // Get the selected announcement
    Announcement *announcement = [[AnnouncementsStore sharedStore] announcementAtIndex:[indexPath row]];
    
    // Configure the cell
    [cell bindAnnouncementToCell:announcement];

    return cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the announcements store and the tableView
        [[AnnouncementsStore sharedStore] deleteAnnouncementAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    [[AnnouncementsStore sharedStore] moveAnnouncementFromIndex:[fromIndexPath row]
                                                        toIndex:[toIndexPath row]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark Search Display Delegate


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    // Set the announcements store search string so it filters out
    // the announcements we want
    [[AnnouncementsStore sharedStore] setSearchFilterString:searchString];
    
    return YES;
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    // Set the filter string to nil so the AnnouncementsStore knows
    // we're done searching and want info about ALL announcements now
    [[AnnouncementsStore sharedStore] setSearchFilterString:nil];
    
    [self.tableView reloadData];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected Announcement to the new view controller.
    if (([[segue identifier] isEqualToString:@"showAnnouncement6"] ||
         [[segue identifier] isEqualToString:@"showAnnouncement7"]) &&
         [[segue destinationViewController] isKindOfClass:[AnnouncementDetailViewController class]]) {
        
        // Get the index path of the selected cell
        NSIndexPath *selectedIndexPath;
        if (self.searchDisplayController.isActive) {
            selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        } else {
            selectedIndexPath = [self.tableView indexPathForCell:sender];
        }

        
        // Pass the announcement to the detail view controller
        [[segue destinationViewController] setAnnouncement:[[AnnouncementsStore sharedStore] announcementAtIndex:[selectedIndexPath row]]];
    }
}



@end
