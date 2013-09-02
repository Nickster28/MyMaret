//
//  Announcement.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Announcement.h"

#define SECONDS_IN_DAY 86400
#define SECONDS_IN_WEEK 604800
@implementation Announcement

@dynamic announcementTitle;
@dynamic announcementBody;
@dynamic announcementAuthor;
@dynamic announcementPostDate;
@dynamic isUnreadAnnouncement;
@dynamic announcementOrderingValue;

+ (Announcement *)announcementWithTitle:(NSString *)aTitle
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
    
    return announcement;
}


- (NSString *)postDateAsString
{
    NSDate *postedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[self announcementPostDate]];
    
    NSDateComponents *postedDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:postedDate];
    
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
    
    // See if the announcement was posted today
    if (postedDateComponents.day == todayDateComponents.day &&
        postedDateComponents.month == todayDateComponents.month &&
        postedDateComponents.year == todayDateComponents.year) {
        
        return @"Today";
        
    // See if the announcement was posted some time in the last week
    } else if ([[NSDate date] timeIntervalSinceDate:postedDate] < SECONDS_IN_WEEK) {
        
        switch ([[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:postedDate].weekday) {
            case 1:
                return @"Sun.";
                
            case 2:
                return @"Mon.";
                
            case 3:
                return @"Tues.";
                
            case 4:
                return @"Wed.";
                
            case 5:
                return @"Thurs.";
                
            case 6:
                return @"Fri.";
                
            case 7:
                return @"Sat.";
            default: ;
        }
    } else {
    
        // Otherwise just return the month/day in string form
        NSNumber *day = [NSNumber numberWithInteger:postedDateComponents.day];
        NSNumber *month = [NSNumber numberWithInteger:postedDateComponents.month];
    
        return [NSString stringWithFormat:@"%@/%@", month, day];
    }
    
    // Should never reach here
    return @"ERROR";
}


- (NSString *)description
{
    NSString *fullAnnouncement = [NSString stringWithFormat:@"%@\n\nPosted %@ by %@", [self announcementBody], [self postDateAsString], [self announcementAuthor]];
    
    return fullAnnouncement;
}

@end
