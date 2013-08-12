//
//  MyMaret_Tests.m
//  MyMaret Tests
//
//  Created by Nick Troccoli on 8/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+TwoWeeksAgo.h"

@interface MyMaret_Tests : XCTestCase

@end

@implementation MyMaret_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNSDateExtension
{
    NSArray *dayArray = @[@1, @30, @14, @3];
    NSArray *monthArray = @[@3, @9, @1, @12];
    NSArray *yearArray = @[@2013, @2013, @2013, @2013];
    
    NSArray *twoWeeksAgoDay = @[@15, @16, @31, @19];
    NSArray *twoWeeksAgoMonth = @[@2, @9, @12, @11];
    NSArray *twoWeeksAgoYear = @[@2013, @2013, @2012, @2013];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    for (int i = 0; i < [dayArray count]; i++) {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:(NSInteger)[dayArray[i] integerValue]];
        [components setMonth:(NSInteger)[monthArray[i] integerValue]];
        [components setYear:(NSInteger)[yearArray[i] integerValue]];
        NSDate *testDate = [calendar dateFromComponents:components];
        
        NSDate *twoWeeksAgo = [testDate dateTwoWeeksAgo];
        NSDateComponents *twoWeeksAgoComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                                              fromDate:twoWeeksAgo];
        
        XCTAssertTrue([twoWeeksAgoComponents day] == (NSInteger)[twoWeeksAgoDay[i] integerValue]);
        XCTAssertTrue([twoWeeksAgoComponents month] == (NSInteger)[twoWeeksAgoMonth[i] integerValue]);
        XCTAssertTrue([twoWeeksAgoComponents year] == (NSInteger)[twoWeeksAgoYear[i] integerValue]);
    }
}

@end
