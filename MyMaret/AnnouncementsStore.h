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

/*! The filter key for only accessing announcements posted today.
 */
extern NSString * const AnnouncementsStoreFilterStringToday;


/*! Get the singleton instance of AnnouncementStore
 * @return the singleton instance of AnnouncementStore.
 */
+ (AnnouncementsStore *)sharedStore;


// **** ALL ANNOUNCEMENT ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices

/*! Fetches new announcements, if any, from the server, and adds them
 * to the store.
 * @param completionBlock the block to execute after checking
 * for new announcements.  numAdded will be the number of new announcements 
 * downloaded (or 0 if there are no new announcements).  err will be non-nil
 * if an error occurred, or nil otherwise.
 */
- (void)fetchAnnouncementsWithCompletionBlock:(void (^)(NSUInteger numAdded, NSError *err))completionBlock;


/*! Returns the announcement at the given index.  If the filter string is non-nil,
 * then this index will be treated as relative to the results of the filter
 * rather than to the entire group of announcements.
 * @param index the index of the announcement to find.
 * @return the announcement at the given index.
 */
- (Announcement *)announcementAtIndex:(NSUInteger)index;


/*! Marks the announcement at the given index as read.  If the filter string is
 * non-nil, then this index will be treated as relative to the results of the 
 * filter rather than to the entire group of announcements.
 * @param readIndex the index of the announcement to mark as read.
 */
- (void)markAnnouncementAtIndexAsRead:(NSUInteger)readIndex;


/*! Deletes the announcement at the given index.  This method will not change
 * if the filter string is nil or non-nil.  The supplied index will always be
 * treated as relative to the entire group of announcements.
 * @param deleteIndex the index of the announcement to delete.
 */
- (void)deleteAnnouncementAtIndex:(NSUInteger)deleteIndex;


/*! Switches the announcements at indexes fromIndex and toIndex.  This method will 
 * not change if the filter string is nil or non-nil.  The supplied indices will 
 * always be treated as relative to the entire group of announcements.
 * @param fromIndex the first index of the announcement to switch.
 * @param toIndex the second index of the announcement to switch.
 */
- (void)moveAnnouncementFromIndex:(NSUInteger)fromIndex
                          toIndex:(NSUInteger)toIndex;


/*! Returns the number of unread announcements.  This method will not change if
 * the filter string is nil or non-nil.  The number of unread announcements will
 * always be returned for the entire group of announcements.
 * @return the number of unread announcements in the store.
 */
- (NSUInteger)numberOfUnreadAnnouncements;


/*! Returns the total number of announcements.  If the filter string is
 * non-nil, then the total count of announcements that satisfy the filter string
 * will be returned instead.
 * @return the total number of announcements, or the number of announcements
 * that satisfy the current filter string.
 */
- (NSUInteger)numberOfAnnouncements;


/*! Posts a new announcement to the server with the given information.
 * Posting an announcement requires a valid logged in user's name
 * to be stored in NSUserDefaults under MyMaretUserNameKey.
 * @param title the title of the announcement to post.
 * @param body the body of the announcement to post.
 * @param completionBlock the block that is executed after posting the
 * announcement.  If there was an error, err will be non-nil.  Otherwise,
 * err will be nil.
 */
- (void)postAnnouncementWithTitle:(NSString *)title
                             body:(NSString *)body
                  completionBlock:(void (^)(NSError *err))completionBlock;



/*! Sets the store-wide filter string (text you are searching for in an
 * announcement).  This is used to access only announcements
 * that fit a given filter string.  If searchString is non-nil,
 * AnnouncementsStore will respond differently when calling certain methods
 * such as numberOfAnnouncements or announcementAtIndex: because these methods
 * will now return information about just the announcements that fit the given
 * filter string.  To go back to accessing all announcements, set the filter
 * string to nil.
 * @param searchString the string you are looking for inside an announcement.
 * Set this to AnnouncementsStoreFilterStringToday to filter by announcements
 * that were posted today.
 */
- (void)setSearchFilterString:(NSString *)searchString;



/*! Returns whether or not the store currently has a filter set.
 * @return true or false depending on whether the store has a filter string or not.
 */
- (BOOL)hasSearchFilterString;


/*! Deletes ALL announcements in the entire store.
 * @return a boolean indicating whether the clean was successful or not.
 */
- (BOOL)clearStore;


@end
