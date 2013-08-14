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


- (NSString *)postDateAsString
{
    NSDate *postedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:self.postDate];
    
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

@end
