//
//  Announcement.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Announcement.h"
#import "NSDate+DueDateStringifier.h"

#define SECONDS_IN_WEEK 604800
@implementation Announcement

@dynamic announcementTitle;
@dynamic announcementBody;
@dynamic announcementAuthor;
@dynamic announcementPostDateComps;
@dynamic announcementPostDate;
@dynamic isUnreadAnnouncement;
@dynamic announcementOrderingValue;

+ (id)announcementWithTitle:(NSString *)aTitle
                       body:(NSString *)aBody
                     author:(NSString *)author
                   postDate:(NSDate *)datePosted
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    Announcement *announcement = [NSEntityDescription insertNewObjectForEntityForName:@"Announcement"
                                                               inManagedObjectContext:context];
    [announcement setAnnouncementTitle:aTitle];
    [announcement setAnnouncementBody:aBody];
    [announcement setAnnouncementAuthor:author];
    [announcement setAnnouncementPostDate:[datePosted timeIntervalSinceReferenceDate]];
    [announcement setIsUnreadAnnouncement:YES];
    [announcement setAnnouncementOrderingValue:0.0];
    
    
    // Make the date components also so we have quick access to the day, month, year, and weekday
    announcement.announcementPostDateComps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:datePosted];
    
    return announcement;
}


- (NSString *)postDateAsString
{
    return [[NSDate dateWithTimeIntervalSinceReferenceDate:self.announcementPostDate] stringForDueDate];
}


- (NSString *)description
{
    NSString *fullAnnouncement = [NSString stringWithFormat:@"%@\n\nPosted %@ by %@", [self announcementBody], [self postDateAsString], [self announcementAuthor]];
    
    return fullAnnouncement;
}

@end
