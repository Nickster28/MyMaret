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

// Use this string if you would like the filter to be
// only Announcements sent today
extern NSString * const AnnouncementsStoreFilterStringToday;


// Get the singleton instance of AnnouncementStore
+ (AnnouncementsStore *)sharedStore;


// **** ALL ANNOUNCEMENT ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices

// Fetches new announcements from Parse and executes the passed-in
// block by either passing in the number of new announcements,
// or an error.
- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(NSUInteger numAdded, NSError *err))completionBlock;


// Get the announcement at a given index (filtered and all)
- (Announcement *)announcementAtIndex:(NSUInteger)index;


// Mark the announcement at readIndex as read (filtered and all)
- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex;


// Delete the announcement at deleteIndex (only all announcements)
- (void)deleteAnnouncementAtIndex:(NSUInteger)deleteIndex;


// Switch the announcements at fromIndex and toIndex (only all announcements)
- (void)moveAnnouncementFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;


// Returns the number of unread announcements (only all announcements)
- (NSUInteger)numberOfUnreadAnnouncements;


// Returns the total number of announcements (filtered and all)
- (NSUInteger)numberOfAnnouncements;


// Post a new announcement to Parse and execute the given completion block,
// either passing in nil for the error, or an error if there is one.
- (void)postAnnouncementWithTitle:(NSString *)title
                             body:(NSString *)body
                  completionBlock:(void (^)(NSError *err))completionBlock;



// ****** FOR ONLY ACCESSING CERTAIN ANNOUNCEMENTS (FILTERING) ******** //
// Set the string to filter by
// MUST SET THIS BEFORE ACCESSING FILTERED ANNOUNCMENTS
// The marked methods above (announcementAtIndex, markAnnouncementAtIndexAsRead,
// and numberOfAnnouncements) will return different values
// depending on whether the filter string is nil or not
- (void)setSearchFilterString:(NSString *)searchString;


@end
