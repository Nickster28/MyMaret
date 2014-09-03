//
//  Assignment_Tests.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/23/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Assignment.h"
#import "NSDate+DueDateStringifier.h"

@interface Assignment_Tests : XCTestCase

@end

@implementation Assignment_Tests


- (void)testAssignmentCreation
{
    NSDate *dueDate = [NSDate date];
    Assignment *a = [[Assignment alloc] initWithAssignmentName:@"Test Assignment" dueDate:dueDate forClassWithName:@"Advanced Chemistry" isOnNormalDay:NO];
    
    XCTAssertEqualObjects(a.assignmentName, @"Test Assignment", @"Assignment name incorrect - %@", a.assignmentName);
    XCTAssertEqualObjects(a.dueDate, dueDate, @"Assignment due date incorrect - %@", a.dueDate);
    XCTAssertEqualObjects(a.className, @"Advanced Chemistry", @"Assignment class name incorrect - %@", a.className);
    XCTAssertFalse(a.isCompleted, @"Assignment is completed!");
    XCTAssertEqualObjects(a.dueTimeString, [dueDate stringForDueDate], @"Assignment dueDateString incorrect - %@", a.dueTimeString);
    
    // Will test normal day below
}


- (void)testNormalDayDoubleDigitMinutes
{
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    dateComps.month = 10;
    dateComps.day = 2;
    dateComps.year = 2014;
    dateComps.hour = 10;
    dateComps.minute = 25;
    
    NSDate *dueDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    
    Assignment *a = [[Assignment alloc] initWithAssignmentName:@"Test Name"
                                                       dueDate:dueDate
                                              forClassWithName:@"Test Class"
                                                 isOnNormalDay:true];
    
    XCTAssertEqualObjects(a.dueTimeString, @"10:25", @"Incorrect time string - %@", a.dueTimeString);
}


- (void)testNormalDaySingleDigitMinutes
{
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    dateComps.month = 10;
    dateComps.day = 2;
    dateComps.year = 2014;
    dateComps.hour = 10;
    dateComps.minute = 02;
    
    NSDate *dueDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    
    Assignment *a = [[Assignment alloc] initWithAssignmentName:@"Test Name"
                                                       dueDate:dueDate
                                              forClassWithName:@"Test Class"
                                                 isOnNormalDay:true];
    
    XCTAssertEqualObjects(a.dueTimeString, @"10:02", @"Incorrect time string - %@", a.dueTimeString);
}


- (void)testNormalDayMilitaryTime
{
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    dateComps.month = 10;
    dateComps.day = 2;
    dateComps.year = 2014;
    dateComps.hour = 16;
    dateComps.minute = 21;
    
    NSDate *dueDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    
    Assignment *a = [[Assignment alloc] initWithAssignmentName:@"Test Name"
                                                       dueDate:dueDate
                                              forClassWithName:@"Test Class"
                                                 isOnNormalDay:true];
    
    XCTAssertEqualObjects(a.dueTimeString, @"4:21", @"Incorrect time string - %@", a.dueTimeString);
}


@end
