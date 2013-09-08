//
//  ClassScheduleStore.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/7/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SchoolClass;

@interface ClassScheduleStore : NSObject

// Get the singleton instance of ClassScheduleStore
+ (ClassScheduleStore *)sharedStore;


// Downloads the user's class schedule from Parse and
// executes the passed-in block by either passing in nil
// or an error if there was one
- (void)fetchClassScheduleWithCompletionBlock:(void (^)(NSError *error))completionBlock;


// **** ALL CLASS ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices


// Get the class at the given index on the given day
- (SchoolClass *)classWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex;



// Returns the total number of articles in a given section (filtered and non-filtered)
- (NSUInteger)numberOfPeriodsInDayWithIndex:(NSUInteger)dayIndex;

// Returns the number of days in the schedule
- (NSUInteger)numberOfDays;

// Returns the string for the given day index
- (NSString *)dayNameForIndex:(NSUInteger)dayIndex;


// For accessing only today's class information
- (NSUInteger)numberOfPeriodsToday;
- (SchoolClass *)classTodayWithIndex:(NSUInteger)classIndex;

@end
