//
//  AnnouncementsStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementsStore.h"
#import <CoreData/CoreData.h>
#import "Announcement.h"
#import "NSDate+TwoWeeksAgo.h"
#import <Parse/Parse.h>


@interface AnnouncementsStore() {
    // Core Data
    NSManagedObjectModel *model;
    NSManagedObjectContext *context;
}

// The array that holds all of the announcements
@property (nonatomic, strong) NSMutableArray *announcements;

@property (nonatomic) NSUInteger numUnreadAnnouncements;
@property (nonatomic, strong) NSDate *lastAnnouncementsUpdate;
@end

// NSUserDefaults keys
NSString * const MyMaretNumUnreadAnnouncementsKey = @"MyMaretNumUnreadAnnouncementsKey";
NSString * const MyMaretLastAnnouncementsUpdateKey = @"MyMaretLastAnnouncementsUpdateKey";

@implementation AnnouncementsStore
@synthesize numUnreadAnnouncements = _numUnreadAnnouncements;
@synthesize lastAnnouncementsUpdate = _lastAnnouncementsUpdate;


+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSDate dateTwoWeeksAgo]
                                                         forKey:MyMaretLastAnnouncementsUpdateKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


// Singleton instance
+ (AnnouncementsStore *)sharedStore
{
    static AnnouncementsStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[AnnouncementsStore alloc] init];
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
        NSString *path = [self announcementsArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"AnnouncementStore: Open failed"
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


- (NSString *)announcementsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"announcementsstore.data"];
}



- (NSMutableArray *)announcements
{
    // If needed, read in announcements from Core Data
    if (!_announcements) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        // Get all announcements, sorted by orderingValue
        NSEntityDescription *description = [[model entitiesByName] objectForKey:@"Announcement"];
        [request setEntity:description];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                                         ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
             
        _announcements = [[NSMutableArray alloc] initWithArray:result];
    }
    
    return _announcements;
}


- (NSUInteger)numUnreadAnnouncements
{
    // Read from NSUserDefaults if we haven't set numUnreadAnnouncements yet
    // (value will default to 0 the very first time)
    if (!_numUnreadAnnouncements) {
        _numUnreadAnnouncements =
        [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretNumUnreadAnnouncementsKey];
    }
    
    return _numUnreadAnnouncements;
}


- (void)setNumUnreadAnnouncements:(NSUInteger)numUnreadAnnouncements
{
    _numUnreadAnnouncements = numUnreadAnnouncements;
    [[NSUserDefaults standardUserDefaults] setInteger:_numUnreadAnnouncements
                                               forKey:MyMaretNumUnreadAnnouncementsKey];
}


- (NSDate *)lastAnnouncementsUpdate
{
    // Read from NSUserDefaults if we haven't set lastAnnouncementsUpdate yet
    // (value will default to two weeks ago the very first time)
    if (!_lastAnnouncementsUpdate) {
        _lastAnnouncementsUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:MyMaretLastAnnouncementsUpdateKey];
    }
    
    return _lastAnnouncementsUpdate;
}


- (void)setLastAnnouncementsUpdate:(NSDate *)lastAnnouncementsUpdate
{
    _lastAnnouncementsUpdate = lastAnnouncementsUpdate;
    [[NSUserDefaults standardUserDefaults] setObject:_lastAnnouncementsUpdate
                                              forKey:MyMaretLastAnnouncementsUpdateKey];
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


#pragma mark Public APIs

- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(NSUInteger, NSError *))completionBlock
{
    // Query for announcements posted after we last checked for announcements
    PFQuery *query = [PFQuery queryWithClassName:@"Announcement"];
    [query whereKey:@"createdAt" greaterThan:[self lastAnnouncementsUpdate]];
    
    // Sort the results so we have them newest to oldest
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Update lastAnnouncementsUpdate to now
            [self setLastAnnouncementsUpdate:[NSDate date]];
            
            // Add the new announcements to our current array of announcements
            [self addAnnouncements:objects];
            [self saveChanges];
            
            completionBlock([objects count], nil);
        } else {
            completionBlock(0, error);
        }
    }];
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


-(NSUInteger)numberOfAnnouncements
{
    return [[self announcements] count];
}


- (NSUInteger)numberOfUnreadAnnouncements
{
    return [self numUnreadAnnouncements];
}


- (Announcement *)announcementAtIndex:(NSUInteger)index
{
    return [[self announcements] objectAtIndex:index];
}


- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex
{
    [[[self announcements] objectAtIndex:readIndex] setIsUnread:FALSE];
    [self saveChanges];
    
    // Update the number of unread announcements
    [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] - 1];
}


- (void)moveAnnouncementFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) return;

    [self.announcements exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (toIndex > 0) {
        lowerBound = [[self announcementAtIndex:toIndex - 1] orderingValue];
    } else {
        lowerBound = [[self announcementAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (toIndex < [self numberOfAnnouncements] - 1) {
        upperBound = [[self announcementAtIndex:toIndex + 1] orderingValue];
    } else {
        upperBound = [[self announcementAtIndex:toIndex - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [self announcementAtIndex:toIndex].orderingValue = newOrderValue;
    
    [self saveChanges];
}


- (void)deleteAnnouncementAtIndex:(NSUInteger)deleteIndex
{
    Announcement *announcementToDelete = [self announcementAtIndex:deleteIndex];
    
    // Update the number of unread announcements if needed
    if ([announcementToDelete isUnread]) {
        [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] - 1];
    }
    
    [context deleteObject:announcementToDelete];
    [[self announcements] removeObjectAtIndex:deleteIndex];
    [self saveChanges];
}

@end
