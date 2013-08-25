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


@interface AnnouncementsTableViewController () <UISearchDisplayDelegate>

@end

@implementation AnnouncementsTableViewController

- (id)init
{
    self = [super init];
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


#pragma mark - Table view data source

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
    [self performSegueWithIdentifier:@"showAnnouncement"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}


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
    [[AnnouncementsStore sharedStore] setSearchFilterString:nil];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected Announcement to the new view controller.
    if ([[segue identifier] isEqualToString:@"showAnnouncement"] && [[segue destinationViewController] isKindOfClass:[AnnouncementDetailViewController class]]) {
        
        // Get the index path of the selected cell
        NSIndexPath *selectedIndexPath;
        if (self.searchDisplayController.isActive) {
            selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:sender];
        } else {
            selectedIndexPath = [self.tableView indexPathForCell:sender];
        }

        
        // Mark the selected announcement as read and pass the
        // announcement to the detail view controller
        [[AnnouncementsStore sharedStore] markAnnouncementAtIndexAsRead:[selectedIndexPath row]];
            
        [[segue destinationViewController] setAnnouncement:[[AnnouncementsStore sharedStore] announcementAtIndex:[selectedIndexPath row]]];
    }
}



@end
