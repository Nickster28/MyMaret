//
//  DueDateStringifier_Tests.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+DueDateStringifier.h"

#define NUM_SECONDS_IN_DAY 86400

@interface DueDateStringifier_Tests : XCTestCase

@end

@implementation DueDateStringifier_Tests

- (NSDate *)createDateWithMonth:(NSUInteger)month
                            day:(NSUInteger)day
                           year:(NSUInteger)year
                           hour:(NSUInteger)hour
                         minute:(NSUInteger)minute
                         second:(NSUInteger)second
{
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    dateComps.day = day;
    dateComps.month = month;
    dateComps.year = year;
    dateComps.hour = hour;
    dateComps.minute = minute;
    dateComps.second = second;
    
    return [[NSCalendar currentCalendar] dateFromComponents:dateComps];
}


- (NSString *)nameOfWeekdayForDate:(NSDate *)date
{
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    switch (dateComps.weekday) {
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
            
        default:
            return @"ERROR";
    }
}


- (void)testPastDatesStringForDueDate
{
    // Today
    NSDate *postDate = [NSDate date];
    XCTAssertEqualObjects([postDate stringForDueDate], @"Today", @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // 9/7/12 4:46:00 PM (The launch of MyMaret 1.0!)
    postDate = [self createDateWithMonth:9 day:7 year:2012 hour:16 minute:46 second:00];
    XCTAssertEqualObjects([postDate stringForDueDate], @"9/7", @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // yesterday (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:-NUM_SECONDS_IN_DAY sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // three days ago (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:-NUM_SECONDS_IN_DAY * 3 sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // six days ago (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:-NUM_SECONDS_IN_DAY * 6 sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // 7 days ago (should be X/Y)
    postDate = [NSDate dateWithTimeInterval:-NUM_SECONDS_IN_DAY * 7 sinceDate:[NSDate date]];
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:postDate];
    
    NSNumber *day = [NSNumber numberWithLong:dateComps.day];
    NSNumber *month = [NSNumber numberWithLong:dateComps.month];
    NSString *dateString = [NSString stringWithFormat:@"%@/%@", month, day];
    XCTAssertEqualObjects([postDate stringForDueDate], dateString, @"Incorrect date string - %@", [postDate stringForDueDate]);
}


- (void)testFutureDatesStringForDueDate
{
    // 9/7/2100 4:45:00 PM
    NSDate *postDate = [self createDateWithMonth:9 day:7 year:2020 hour:16 minute:45 second:00];
    NSString *str = [postDate stringForDueDate];
    XCTAssertEqualObjects(str, @"9/7", @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // tomorrow (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_DAY sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // three days in the future (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_DAY * 3 sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // six days in the future (should be weekday name)
    postDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_DAY * 6 sinceDate:[NSDate date]];
    XCTAssertEqualObjects([postDate stringForDueDate], [self nameOfWeekdayForDate:postDate], @"Incorrect date string - %@", [postDate stringForDueDate]);
    
    // 7 days in the future (should be X/Y)
    postDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_DAY * 7 + 1 sinceDate:[NSDate date]];
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:postDate];
    
    NSNumber *day = [NSNumber numberWithLong:dateComps.day];
    NSNumber *month = [NSNumber numberWithLong:dateComps.month];
    NSString *dateString = [NSString stringWithFormat:@"%@/%@", month, day];
    XCTAssertEqualObjects([postDate stringForDueDate], dateString, @"Incorrect date string - %@", [postDate stringForDueDate]);
}

@end
