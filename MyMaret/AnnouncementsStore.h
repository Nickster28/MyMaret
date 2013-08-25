//
//  AnnouncementsStore.h
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Announcement;

@interface AnnouncementsStore : NSObject

// Get the singleton instance of AnnouncementStore
+ (AnnouncementsStore *)sharedStore;


// **** ALL ANNOUNCEMENT ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices

- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(NSUInteger numAdded, NSError *err))completionBlock;

// Get the announcement at a given index
- (Announcement *)announcementAtIndex:(NSUInteger)index;

// Mark the announcement at readIndex as read
- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex;

// Delete the announcement at deleteIndex
- (void)deleteAnnouncementAtIndex:(NSUInteger)deleteIndex;

// Switch the announcements at fromIndex and toIndex
- (void)moveAnnouncementFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

// Returns the number of unread announcements
- (NSUInteger)numberOfUnreadAnnouncements;

// Returns the total number of announcements
- (NSUInteger)numberOfAnnouncements;

// Saves all Core Data changes
- (void)saveChanges;

// Post a new announcement
- (void)postAnnouncementWithTitle:(NSString *)title
                             body:(NSString *)body
                  completionBlock:(void (^)(NSError *err))completionBlock;



// ****** FOR USING A SEARCH DISPLAY CONTROLLER ******** //
// Set the string the user is searching by
// MUST SET THIS BEFORE ACCESSING FILTERED ANNOUNCMENTS
- (void)setSearchFilterString:(NSString *)searchString;

// Get the filtered announcements array index by index
- (Announcement *)searchFilterAnnouncementAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfFilteredAnnouncements;


@end
