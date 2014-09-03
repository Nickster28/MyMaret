//
//  Assignment.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Assignment.h"
#import "NSDate+DueDateStringifier.h"


// The keys for archiving an assignment
NSString * const AssignmentAssignmentNameEncodingKey = @"assignmentName";
NSString * const AssignmentDueDateEncodingKey = @"dueDate";
NSString * const AssignmentClassNameEncodingKey = @"className";
NSString * const AssignmentDueDateDayDateCompsEncodingKey = @"dueDateDayDateComps";
NSString * const AssignmentDueTimeStringEncodingKey = @"dueTimeString";
NSString * const AssignmentIsCompletedEncodingKey = @"isCompleted";

@implementation Assignment



- (id)initWithAssignmentName:(NSString *)assignmentName dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className isOnNormalDay:(BOOL)isNormalDay
{
    self = [super init];
    if (self) {
        [self setAssignmentName:assignmentName];
        [self setDueDate:dueDate];
        [self setClassName:className];
        [self setIsCompleted:false];
        
        // Pull out the day, month, and weekday to store in our date comps
        [self setDueDateDayDateComps:[[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit)
                                                                     fromDate:dueDate]];
        
        if (isNormalDay) {
            // Pull out the time the assignment is due to store in our due time string
            NSDateComponents *dueDateDateComps = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dueDate];
            
            // Get the hour, adjusting for military time
            NSUInteger hour = dueDateDateComps.hour;
            if (hour > 12) hour -= 12;
            
            // Get the minutes, adjusting for < 10 (ex. 9:5 vs 9:05)
            NSUInteger minutes = dueDateDateComps.minute;
            NSString *minutesString = (minutes < 10) ? [NSString stringWithFormat:@"0%lu", (unsigned long)minutes] : [NSString stringWithFormat:@"%lu", (unsigned long)minutes];
            
            [self setDueTimeString:[NSString stringWithFormat:@"%lu:%@", (unsigned long)hour, minutesString]];
        } else {
            
            // Just put the day it's due
            [self setDueTimeString:[self dueDateAsString]];
        }
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
    [aCoder encodeObject:[NSNumber numberWithBool:[self isCompleted]] forKey:AssignmentIsCompletedEncodingKey];
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
        [self setIsCompleted:[[aDecoder decodeObjectForKey:AssignmentIsCompletedEncodingKey] boolValue]];
    }
    
    return self;
}



- (NSString *)dueDateAsString
{
    return [self.dueDate stringForDueDate];
}


- (BOOL)isEqual:(id)object
{
    Assignment *assignmentToCompare = (Assignment *)object;
    
    return [assignmentToCompare.assignmentName isEqualToString:self.assignmentName] && [assignmentToCompare.dueDate isEqualToDate:self.dueDate] && [assignmentToCompare.className isEqualToString:self.className] && [assignmentToCompare.dueTimeString isEqualToString:self.dueTimeString];
}


@end
