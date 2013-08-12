//
//  Announcement.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Announcement.h"


@implementation Announcement

@dynamic title;
@dynamic body;
@dynamic author;
@dynamic postDate;
@dynamic isUnread;
@dynamic orderingValue;

+ (Announcement *)announcementWithTitle:(NSString *)announcementTitle
                                   body:(NSString *)announcementBody
                                 author:(NSString *)announcementAuthor
                               postDate:(NSDate *)datePosted
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Announcement *announcement = [NSEntityDescription insertNewObjectForEntityForName:@"Announcement"
                                                               inManagedObjectContext:context];
    announcement.title = announcementTitle;
    announcement.body = announcementBody;
    announcement.author = announcementAuthor;
    announcement.postDate = [datePosted timeIntervalSinceReferenceDate];
    announcement.isUnread = TRUE;
    
    return announcement;
}

@end
