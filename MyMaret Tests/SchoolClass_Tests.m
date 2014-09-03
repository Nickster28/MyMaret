//
//  SchoolClass_Tests.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/16/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SchoolClass.h"

@interface SchoolClass_Tests : XCTestCase

@end

@implementation SchoolClass_Tests


- (void)testClassCreation
{
    SchoolClass *class = [[SchoolClass alloc] initWithName:@"Science" classTime:@"10:15-11:05"];
    
    XCTAssertNotNil(class, @"Class is nil!");
    XCTAssertEqualObjects(class.className, @"Science", @"Incorrect class name - %@", class.className);
    XCTAssertEqualObjects(class.classTime, @"10:15-11:05", @"Incorrect class time - %@", class.classTime);
    XCTAssertEqualObjects(class.classStartTime, @"10:15", @"Incorrect start time - %@", class.classStartTime);
    XCTAssertEqualObjects(class.classEndTime, @"11:05", @"Incorrect end time - %@", class.classEndTime);
}


- (void)testClassTimeParsing
{
    SchoolClass *class = [[SchoolClass alloc] initWithName:@"Math" classTime:@"1:15-2:05"];
    
    // 1:15-2:05
    XCTAssertEqualObjects(class.classTime, @"1:15-2:05", @"Incorrect class time - %@", class.classTime);
    XCTAssertEqualObjects(class.classStartTime, @"1:15", @"Incorrect start time - %@", class.classStartTime);
    XCTAssertEqualObjects(class.classEndTime, @"2:05", @"Incorrect end time - %@", class.classEndTime);
    
    // Test invalid class times
    [class setClassTime:@"1:152:05"];
    XCTAssertEqualObjects(class.classTime, @"1:152:05", @"Incorrect class time - %@", class.classTime);
    XCTAssertEqualObjects(class.classStartTime, @"", @"Incorrect start time - %@", class.classStartTime);
    XCTAssertEqualObjects(class.classEndTime, @"", @"Incorrect end time - %@", class.classEndTime);
}

@end
