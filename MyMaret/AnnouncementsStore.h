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

+ (AnnouncementsStore *)sharedStore;

- (Announcement *)announcementAtIndex:(int)index;
- (void)markAnnouncementAtIndexAsRead:(int)readIndex;
- (void)deleteAnnouncementAtIndex:(int)deleteIndex;
- (void)moveAnnouncementFromIndex:(int)fromIndex toIndex:(int)toIndex;
- (int)numberOfUnreadAnnouncements;
- (int)numberOfAnnouncements;

- (void)saveChanges;


@end
