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


@interface AnnouncementsTableViewController ()

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor schoolColor]];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAnnouncements)
                  forControlEvents:UIControlEventValueChanged];
    
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
                                                        delegate:Nil
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
    return [[AnnouncementsStore sharedStore] numberOfAnnouncements];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"announcementCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Announcement *announcement = [[AnnouncementsStore sharedStore] announcementAtIndex:[indexPath row]];
    [[cell textLabel] setText:announcement.title];
    [[cell detailTextLabel] setText:announcement.author];
    
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
