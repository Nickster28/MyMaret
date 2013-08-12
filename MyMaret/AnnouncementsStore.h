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

- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(int numAdded, NSError *err))completionBlock;

// Get the announcement at a given index
- (Announcement *)announcementAtIndex:(int)index;

// Mark the announcement at readIndex as read
- (void)markAnnouncementAtIndexAsRead:(int)readIndex;

// Delete the announcement at deleteIndex
- (void)deleteAnnouncementAtIndex:(int)deleteIndex;

// Switch the announcements at fromIndex and toIndex
- (void)moveAnnouncementFromIndex:(int)fromIndex toIndex:(int)toIndex;

// Returns the number of unread announcements
- (int)numberOfUnreadAnnouncements;

// Returns the total number of announcements
- (int)numberOfAnnouncements;

// Saves all Core Data changes
- (void)saveChanges;


@end
