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

@interface AnnouncementsStore() {
    NSManagedObjectModel *model;
    NSManagedObjectContext *context;
}

@property (nonatomic, strong) NSMutableArray *announcements;
@end

@implementation AnnouncementsStore
@synthesize announcements = _announcements;


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
        // Read in MyMaret.xcdatamodeld
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


-(int)numberOfAnnouncements
{
    return [[self announcements] count];
}

- (Announcement *)announcementAtIndex:(int)index
{
    return [[self announcements] objectAtIndex:index];
}

- (void)markAnnouncementAtIndexAsRead:(int)readIndex
{
    [[[self announcements] objectAtIndex:readIndex] setIsUnread:FALSE];
    [self saveChanges];
}

- (void)moveAnnouncementFromIndex:(int)fromIndex toIndex:(int)toIndex
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

- (void)deleteAnnouncementAtIndex:(int)deleteIndex
{
    [context deleteObject:[self announcementAtIndex:deleteIndex]];
    [[self announcements] removeObjectAtIndex:deleteIndex];
    [self saveChanges];
}

@end
