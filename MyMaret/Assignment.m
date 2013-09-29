//
//  Assignment.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Assignment.h"


// The keys for archiving an assignment
NSString * const AssignmentAssignmentNameEncodingKey = @"assignmentName";
NSString * const AssignmentDueDateEncodingKey = @"dueDate";
NSString * const AssignmentClassNameEncodingKey = @"className";
NSString * const AssignmentDueDateDayDateCompsEncodingKey = @"dueDateDayDateComps";
NSString * const AssignmentDueTimeStringEncodingKey = @"dueTimeString";

#define SECONDS_IN_WEEK 604800
@implementation Assignment



- (id)initWithAssignmentName:(NSString *)assignmentName dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className
{
    self = [super init];
    if (self) {
        [self setAssignmentName:assignmentName];
        [self setDueDate:dueDate];
        [self setClassName:className];
        
        // Pull out the day, month, and weekday to store in our date comps
        [self setDueDateDayDateComps:[[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit)
                                                                     fromDate:dueDate]];
        
        // Pull out the time the assignment is due to store in our due time string
        NSDateComponents *dueDateDateComps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dueDate];
        
        // Get the hour, adjusting for military time
        NSUInteger hour = dueDateDateComps.hour;
        if (hour > 12) hour -= 12;
        
        // Get the minutes, adjusting for < 10 (ex. 9:5 vs 9:05)
        NSUInteger minutes = dueDateDateComps.minute;
        NSString *minutesString = (minutes < 10) ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
        
        [self setDueTimeString:[NSString stringWithFormat:@"%d:%@", hour, minutesString]];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self assignmentName] forKey:AssignmentAssignmentNameEncodingKey];
    [aCoder encodeObject:[self dueDate] forKey:AssignmentDueDateEncodingKey];
    [aCoder encodeObject:[self className] forKey:AssignmentClassNameEncodingKey];
    [aCoder encodeObject:[self dueDateDayDateComps] forKey:AssignmentDueDateDayDateCompsEncodingKey];
    [aCoder encodeObject:[self dueTimeString] forKey:AssignmentDueTimeStringEncodingKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setAssignmentName:[aDecoder decodeObjectForKey:AssignmentAssignmentNameEncodingKey]];
        [self setDueDate:[aDecoder decodeObjectForKey:AssignmentDueDateEncodingKey]];
        [self setClassName:[aDecoder decodeObjectForKey:AssignmentClassNameEncodingKey]];
        [self setDueDateDayDateComps:[aDecoder decodeObjectForKey:AssignmentDueDateDayDateCompsEncodingKey]];
        [self setDueTimeString:[aDecoder decodeObjectForKey:AssignmentDueTimeStringEncodingKey]];
    }
    
    return self;
}



- (NSString *)dueDateAsString
{
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
    
    // See if the announcement was posted today
    if (self.dueDateDayDateComps.day == todayDateComponents.day &&
        self.dueDateDayDateComps.month == todayDateComponents.month) {
        
        return @"Today";
        
        // See if the announcement was posted some time in the last week
    } else if ([self.dueDate timeIntervalSinceDate:[NSDate date]] < SECONDS_IN_WEEK) {
        
        switch (self.dueDateDayDateComps.weekday) {
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
        NSNumber *day = [NSNumber numberWithInteger:self.dueDateDayDateComps.day];
        NSNumber *month = [NSNumber numberWithInteger:self.dueDateDayDateComps.month];
        
        return [NSString stringWithFormat:@"%@/%@", month, day];
    }
    
    // Should never reach here
    return @"ERROR";
}


- (BOOL)isEqual:(id)object
{
    Assignment *assignmentToCompare = (Assignment *)object;
    
    return [assignmentToCompare.assignmentName isEqualToString:self.assignmentName] && [assignmentToCompare.dueDate isEqualToDate:self.dueDate] && [assignmentToCompare.className isEqualToString:self.className] && [assignmentToCompare.dueTimeString isEqualToString:self.dueTimeString];
}


@end
