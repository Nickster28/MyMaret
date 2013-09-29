//
//  Assignment.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Assignment.h"


NSString * const AssignmentAssignmentNameEncodingKey = @"assignmentName";
NSString * const AssignmentDueDateEncodingKey = @"dueDate";
NSString * const AssignmentClassNameEncodingKey = @"className";
NSString * const AssignmentDueDateDateCompsEncodingKey = @"dueDateDateComps";

#define SECONDS_IN_WEEK 604800
@implementation Assignment



- (id)initWithAssignmentName:(NSString *)assignmentName dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className
{
    self = [super init];
    if (self) {
        [self setAssignmentName:assignmentName];
        [self setDueDate:dueDate];
        [self setClassName:className];
        
        [self setDueDateDateComps:[[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit)
                                                                  fromDate:dueDate]];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self assignmentName] forKey:AssignmentAssignmentNameEncodingKey];
    [aCoder encodeObject:[self dueDate] forKey:AssignmentDueDateEncodingKey];
    [aCoder encodeObject:[self className] forKey:AssignmentClassNameEncodingKey];
    [aCoder encodeObject:[self dueDateDateComps] forKey:AssignmentDueDateDateCompsEncodingKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setAssignmentName:[aDecoder decodeObjectForKey:AssignmentAssignmentNameEncodingKey]];
        [self setDueDate:[aDecoder decodeObjectForKey:AssignmentDueDateEncodingKey]];
        [self setClassName:[aDecoder decodeObjectForKey:AssignmentClassNameEncodingKey]];
        [self setDueDateDateComps:[aDecoder decodeObjectForKey:AssignmentDueDateDateCompsEncodingKey]];
    }
    
    return self;
}



- (NSString *)dueDateAsString
{
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:[NSDate date]];
    
    // See if the announcement was posted today
    if (self.dueDateDateComps.day == todayDateComponents.day &&
        self.dueDateDateComps.month == todayDateComponents.month &&
        self.dueDateDateComps.year == todayDateComponents.year) {
        
        return @"Today";
        
        // See if the announcement was posted some time in the last week
    } else if ([[NSDate date] timeIntervalSinceDate:self.dueDate] < SECONDS_IN_WEEK) {
        
        switch (self.dueDateDateComps.weekday) {
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
        NSNumber *day = [NSNumber numberWithInteger:self.dueDateDateComps.day];
        NSNumber *month = [NSNumber numberWithInteger:self.dueDateDateComps.month];
        
        return [NSString stringWithFormat:@"%@/%@", month, day];
    }
    
    // Should never reach here
    return @"ERROR";
}


- (NSString *)dueTimeAsString
{
    return [NSString stringWithFormat:@"%d:%d", self.dueDateDateComps.hour, self.dueDateDateComps.minute];
}


- (BOOL)isEqual:(id)object
{
    Assignment *assignmentToCompare = (Assignment *)object;
    
    return [assignmentToCompare.assignmentName isEqualToString:self.assignmentName] && [assignmentToCompare.dueDate isEqualToDate:self.dueDate] && [assignmentToCompare.className isEqualToString:self.className];
}


@end
