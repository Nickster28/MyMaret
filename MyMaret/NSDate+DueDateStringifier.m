//
//  NSDate+DueDateStringifier.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import "NSDate+DueDateStringifier.h"

#define SECONDS_IN_WEEK 604800

@implementation NSDate (DueDateStringifier)

- (NSString *)stringForDueDate
{
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
    
    NSDateComponents *selfDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
    
    // See if the announcement was posted today
    if (selfDateComponents.day == todayDateComponents.day &&
        selfDateComponents.month == todayDateComponents.month) {
        
        return @"Today";
        
        // See if the announcement was posted some time in the last week
    } else if (fabs([self timeIntervalSinceDate:[NSDate date]]) < SECONDS_IN_WEEK) {
        
        switch (selfDateComponents.weekday) {
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
        NSNumber *day = [NSNumber numberWithInteger:selfDateComponents.day];
        NSNumber *month = [NSNumber numberWithInteger:selfDateComponents.month];
        
        return [NSString stringWithFormat:@"%@/%@", month, day];
    }
    
    // Should never reach here
    return @"ERROR";
}

@end
