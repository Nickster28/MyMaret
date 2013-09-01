//
//  NewspaperStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperStore.h"
#import <CoreData/CoreData.h>
#import "NewspaperArticle.h"
#import "NSDate+TwoWeeksAgo.h"
#import <Parse/Parse.h>
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"

@interface NewspaperStore() {
    // Core Data
    NSManagedObjectModel *model;
    NSManagedObjectContext *context;
}

@property (nonatomic, strong) NSDictionary *articleDictionary;
@property (nonatomic, strong) NSDate *lastNewspaperUpdate;


// Saves all Core Data changes
- (void)saveChanges;

@end

// NSUserDefaults key
NSString * const MyMaretLastNewspaperUpdateKey = @"MyMaretLastNewspaperUpdateKey";


@implementation NewspaperStore
@synthesize lastNewspaperUpdate = _lastNewspaperUpdate;



+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSDate dateTwoWeeksAgo]
                                                         forKey:MyMaretLastNewspaperUpdateKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


// Singleton instance
+ (NewspaperStore *)sharedStore
{
    static NewspaperStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[NewspaperStore alloc] init];
    });
    
    return sharedStore;
}


- (id)init {
    self = [super init];
    
    if (self) {
        // Read in AnnouncementsCDModel.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?
        NSString *path = [self newspaperArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"NewspaperStore: Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = psc;
        
        // The managed object context can manage undo, but we don't need it
        context.undoManager = nil;
    }
    
    return self;
}


- (NSString *)newspaperArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"newspaperstore.data"];
}



- (NSDictionary *)articleDictionary
{
    // If needed, read in announcements from Core Data
    if (!_articleDictionary) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        // Get all announcements, sorted by orderingValue
        NSEntityDescription *description = [[model entitiesByName] objectForKey:@"NewspaperArticle"];
        [request setEntity:description];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"section"
                                                                         ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        
        if (!result) {
            [NSException raise:@"Article fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        _announcements = [[NSMutableArray alloc] initWithArray:result];
    }
    
    return _announcements;
}



- (NSDate *)lastNewspaperUpdate
{
    // Read from NSUserDefaults if we haven't set lastAnnouncementsUpdate yet
    // (value will default to two weeks ago the very first time)
    if (!_lastNewspaperUpdate) {
        _lastNewspaperUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:MyMaretLastNewspaperUpdateKey];
    }
    
    return _lastNewspaperUpdate;
}


- (void)setLastNewspaperUpdate:(NSDate *)lastNewspaperUpdate
{
    _lastNewspaperUpdate = lastNewspaperUpdate;
    [[NSUserDefaults standardUserDefaults] setObject:_lastNewspaperUpdate
                                              forKey:MyMaretLastNewspaperUpdateKey];
}


- (void)addAnnouncements:(NSArray *)announcementsToAdd
{
    for (PFObject *object in announcementsToAdd) {
        Announcement *announcement = [Announcement announcementWithTitle:[object objectForKey:@"title"]
                                                                    body:[object objectForKey:@"body"]
                                                                  author:[object objectForKey:@"author"]
                                                                postDate:object.createdAt
                                                  inManagedObjectContext:context];
        
        // Set the ordering value
        if ([self numberOfAnnouncements] == 0) announcement.orderingValue = 1.0;
        else announcement.orderingValue = [[self announcementAtIndex:0] orderingValue] / 2.0;
        
        // Insert the new announcement into the announcements array
        [[self announcements] insertObject:announcement atIndex:0];
        
        [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] + 1];
    }
}


// Save Core Data changes
- (void)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Saving Announcements"
                                                            message:[err localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


#pragma mark Public API

- (void)fetchNewspaperWithCompletionBlock:(void (^)(NSUInteger, NSError *))completionBlock
{
    // If we're not connected to the internet, send an error back
    if (![UIApplication hasNetworkConnection]) {
        
        // Make the error info dictionary
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Looks like you're not connected to the Internet.  Check your WiFi or Cellular connection and try refreshing again."
                                                         forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:@"NSConnectionErrorDomain"
                                             code:2012
                                         userInfo:dict];
        
        completionBlock(0, error);
        return;
    }

    
    
    // Query for a new edition of the newspaper
    PFQuery *query = [PFQuery queryWithClassName:@"Article"];
    [query whereKey:@"createdAt" greaterThan:[self lastNewspaperUpdate]];
    [query whereKey:@"isPublished" equalTo:[NSNumber numberWithBool:YES]];
    
    // Sort the results so we have them by section
    [query orderByAscending:@"section"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Update lastNewspaperUpdate to now
            [self setLastNewspaperUpdate:[NSDate date]];
            
            // Add the new announcements to our current array of announcements
            [self addAnnouncements:objects];
            [self saveChanges];
            
            completionBlock([objects count], nil);
        } else {
            completionBlock(0, error);
        }
    }];
}


-(NSUInteger)numberOfAnnouncementsInSection:(NSString *)section
{
    #warning not implemented
    return 0;
}



- (Announcement *)announcementAtIndex:(NSUInteger)index
{
    // Return the corresponding announcement from whichever array
    // (The search results or all announcements) we want to access
    if (!self.filteredAnnouncements) {
        return [[self announcements] objectAtIndex:index];
    } else {
        return [[self filteredAnnouncements] objectAtIndex:index];
    }
}


- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex
{
    // If we're currently working with the filtered announcements,
    // we need to convert readIndex to be an index in the full announcements
    // array
    if (self.filteredAnnouncements) {
        Announcement *selectedFilteredAnnouncement = [self.filteredAnnouncements objectAtIndex:readIndex];
        readIndex = [self.announcements indexOfObject:selectedFilteredAnnouncement];
    }
    
    // Change to read if the announcement is unread
    if ([[self.announcements objectAtIndex:readIndex] isUnread]) {
        [[[self announcements] objectAtIndex:readIndex] setIsUnread:FALSE];
        [self saveChanges];
        
        // Update the number of unread announcements
        [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] - 1];
    }
}



// The searchString being nil or not determines whether
// the AnnouncementsStore is in "filter mode" or not
- (void)setSearchFilterString:(NSString *)searchString
{
    // If we want only today's announcements, filter out those whose postDateAsString is "Today"
    if (searchString && [searchString isEqualToString:AnnouncementsStoreFilterStringToday]) {
        NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"postDateAsString like \"Today\""];
        
        [self setFilteredAnnouncements:[self.announcements filteredArrayUsingPredicate:todayPredicate]];
        
        // Otherwise, filter them by whether they contain the given searchString
    } else if (searchString) {
        // Use NSPredicate - http://ygamretuta.me/2011/08/10/ios-implementing-a-basic-search-uisearchdisplaycontroller-and-interface-builder/
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(description contains[cd] %@) OR (title contains[cd] %@)", searchString, searchString];
        
        [self setFilteredAnnouncements:[self.announcements filteredArrayUsingPredicate:predicate]];
        
        // Otherwise, we want all announcements now
    } else {
        [self setFilteredAnnouncements:nil];
    }
}




@end
