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
#import <Parse/Parse.h>
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"


@interface AnnouncementsStore() {
    // Core Data
    NSManagedObjectModel *model;
    NSManagedObjectContext *context;
}

// The array that holds all of the announcements
@property (nonatomic, strong) NSMutableArray *announcements;

// The array pertaining to the user's announcement search
@property (nonatomic, strong) NSArray *filteredAnnouncements;

@property (nonatomic) NSUInteger numUnreadAnnouncements;
@property (nonatomic, strong) NSDate *lastAnnouncementsUpdate;


// Saves all Core Data changes
- (BOOL)saveChanges;

@end

// NSUserDefaults keys
NSString * const MyMaretNumUnreadAnnouncementsKey = @"MyMaretNumUnreadAnnouncementsKey";
NSString * const MyMaretLastAnnouncementsUpdateKey = @"MyMaretLastAnnouncementsUpdateKey";

NSString * const AnnouncementsStoreFilterStringToday = @"AnnouncementsStoreFilterStringToday";

@implementation AnnouncementsStore
@synthesize numUnreadAnnouncements = _numUnreadAnnouncements;
@synthesize lastAnnouncementsUpdate = _lastAnnouncementsUpdate;


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
            [NSException raise:@"AnnouncementsStore: Open failed"
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
    
    return [directory stringByAppendingPathComponent:@"mymaretstore.data"];
}



- (NSMutableArray *)announcements
{
    // If needed, read in announcements from Core Data
    if (!_announcements) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        // Get all announcements, sorted by orderingValue
        NSEntityDescription *description = [[model entitiesByName] objectForKey:@"Announcement"];
        [request setEntity:description];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"announcementOrderingValue"
                                                                         ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        
        if (!result) {
            [NSException raise:@"Announcement fetch failed" format:@"Reason: %@", [error localizedDescription]];
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
    
    [[PFInstallation currentInstallation] setBadge:numUnreadAnnouncements];
    [[PFInstallation currentInstallation] saveInBackground];
    
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
        
        // Set the ordering value by setting it to be 1 if there are no other announcements
        // or to the lowest ordering value divided by 2
        if ([self numberOfAnnouncements] == 0) [announcement setAnnouncementOrderingValue:1.0];
        else [announcement setAnnouncementOrderingValue:
              [[self announcementAtIndex:0] announcementOrderingValue] / 2.0];
        
        // Insert the new announcement into the announcements array
        [[self announcements] insertObject:announcement atIndex:0];
    }
    
    // Update our number of unread announcements
    [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] + announcementsToAdd.count];
}


// Save Core Data changes
- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    
#if DEBUG
    if (!successful) {
        NSLog(@"Could not save the announcements.");
    }
#endif
    
    return successful;
}


// Returns the array of announcements that is currently
// being searched (filtered announcements or all announcements)
- (NSArray *)currentRelevantAnnouncementsArray
{
    if (self.filteredAnnouncements) return self.filteredAnnouncements;
    else return self.announcements;
}



// Called if the user's Person object has not yet been successfully downloaded.
// Returns nil or an error if there was one.
- (NSError *)downloadUserInformation {
    
    // Query for the "Person" object for this user
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query whereKey:@"emailAddress" equalTo:[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserEmailKey]];
    
    NSError *error = nil;
    PFObject *object = [query getFirstObject:&error];
        
    // Save their name in NSUserDefaults and update their Person object in Parse
    if (!error) {
        NSString *userFullName = [NSString stringWithFormat:@"%@ %@",
                                    [object objectForKey:@"firstName"],
                                    [object objectForKey:@"lastName"]];
            
        [[NSUserDefaults standardUserDefaults] setObject:userFullName
                                                  forKey:MyMaretUserNameKey];
        
        [[NSUserDefaults standardUserDefaults] setInteger:[[object objectForKey:@"grade"] integerValue]
                                                   forKey:MyMaretUserGradeKey];
            
            
        // Update the object so the user won't receive email (since they have the app)
        [object setObject: [NSNumber numberWithBool:NO] forKey:@"shouldReceiveEmail"];
        [object saveInBackground];
    }
    
    return error;
}


#pragma mark Public API

- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(NSUInteger, NSError *))completionBlock
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

    
    
    // Query for announcements posted after we last checked for announcements
    PFQuery *query = [PFQuery queryWithClassName:@"Announcement"];
    
    // If we've updated before, only download announcements
    // that have been added since we last updated.
    if ([self lastAnnouncementsUpdate]) {
        [query whereKey:@"createdAt" greaterThan:[self lastAnnouncementsUpdate]];
    }
    
    // Sort the results so we have them newest to oldest
    [query orderByAscending:@"createdAt"];
    
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


-(NSUInteger)numberOfAnnouncements
{
    // Return whichever array (the search results or all announcements)
    // we want to count
    return [[self currentRelevantAnnouncementsArray] count];
}


- (NSUInteger)numberOfUnreadAnnouncements
{
    return [self numUnreadAnnouncements];
}


- (Announcement *)announcementAtIndex:(NSUInteger)index
{
    // Return the corresponding announcement from whichever array
    // (The search results or all announcements) we want to access
    return [[self currentRelevantAnnouncementsArray] objectAtIndex:index];
}


- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex
{
    NSArray *announcementsArray = [self currentRelevantAnnouncementsArray];
    
    // If it's unread, mark it as read
    if ([[announcementsArray objectAtIndex:readIndex] isUnreadAnnouncement]) {
        [[announcementsArray objectAtIndex:readIndex] setIsUnreadAnnouncement:NO];
        [self saveChanges];
        
        // Update the number of unread announcements
        [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] - 1];
    }
}


- (void)moveAnnouncementFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) return;

    [self.announcements exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (toIndex > 0) {
        lowerBound = [[self announcementAtIndex:toIndex - 1] announcementOrderingValue];
    } else {
        lowerBound = [[self announcementAtIndex:1] announcementOrderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (toIndex < [self numberOfAnnouncements] - 1) {
        upperBound = [[self announcementAtIndex:toIndex + 1] announcementOrderingValue];
    } else {
        upperBound = [[self announcementAtIndex:toIndex - 1] announcementOrderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    [[self announcementAtIndex:toIndex] setAnnouncementOrderingValue:newOrderValue];
    
    [self saveChanges];
}


- (void)deleteAnnouncementAtIndex:(NSUInteger)deleteIndex
{
    Announcement *announcementToDelete = [self announcementAtIndex:deleteIndex];
    
    // Update the number of unread announcements if needed
    if ([announcementToDelete isUnreadAnnouncement]) {
        [self setNumUnreadAnnouncements:[self numUnreadAnnouncements] - 1];
    }
    
    [context deleteObject:announcementToDelete];
    [[self announcements] removeObjectAtIndex:deleteIndex];
    [self saveChanges];
}


- (void)postAnnouncementWithTitle:(NSString *)title
                             body:(NSString *)body
                  completionBlock:(void (^)(NSError *))completionBlock
{
    // If we're not connected to the internet, send an error back
    if (![UIApplication hasNetworkConnection]) {
        
        // Make the error info dictionary
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Looks like you're not connected to the Internet.  Check your WiFi or Cellular connection and try refreshing again."
                                                         forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:@"NSConnectionErrorDomain"
                                             code:2012
                                         userInfo:dict];
        
        completionBlock(error);
        return;
    }
    
    
    // If the user hasn't yet connected to Parse to sync with his/her "Person" object,
    // do that now
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserNameKey] isEqualToString:@""] &&
        ![[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserEmailKey] isEqualToString:@""]) {
        
        NSError *err = [self downloadUserInformation];
        if (err) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Sorry, there was an error fetching your user profile from our server.  Unfortunately, we need to download your profile before you can start posting announcements.  Double check that you're connected to the internet and try again." forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:@"NSConnectionErrorDomain"
                                                 code:2012
                                             userInfo:dict];
            
            completionBlock(error);
            return;
        }
    }

    // Create a new Parse announcement
    PFObject *newAnnouncement = [PFObject objectWithClassName:@"Announcement"];
    [newAnnouncement setObject:title forKey:@"title"];
    [newAnnouncement setObject:body forKey:@"body"];
    
    [newAnnouncement setObject:[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserNameKey]
                        forKey:@"author"];
    
    // Save it and execute the completion block
    [newAnnouncement saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) completionBlock(nil);
        else {
            if (error.code == kPFErrorConnectionFailed) {
                [error.userInfo setValue:@"Connection error.  Please make sure you are connected to the internet."
                                  forKey:NSLocalizedDescriptionKey];
            }
            completionBlock(error);
        }
    }];
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
                                  @"(description contains[cd] %@) OR (announcementTitle contains[cd] %@)", searchString, searchString];
        
        [self setFilteredAnnouncements:[self.announcements filteredArrayUsingPredicate:predicate]];
        
    // Otherwise, we want all announcements now
    } else {
        [self setFilteredAnnouncements:nil];
    }
}


- (BOOL)hasSearchFilterString
{
    return (self.filteredAnnouncements) ? YES : NO;
}



- (BOOL)clearStore
{
    // Remove the announcements from Core Data
    for (Announcement *announcement in self.announcements) {
        [context deleteObject:announcement];
    }
    
    self.announcements = nil;
    
    return [self saveChanges];
}


@end
