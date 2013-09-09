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


// If this is given as the parameter for a day index,
// then the store will figure out what today is and
// return appropriate information
extern const NSUInteger todayIndexKey;


// Get the singleton instance of ClassScheduleStore
+ (ClassScheduleStore *)sharedStore;


// Downloads the user's class schedule from Parse and
// executes the passed-in block by either passing in nil
// or an error if there was one
- (void)fetchClassScheduleWithCompletionBlock:(void (^)(NSError *error))completionBlock;


// **** ALL CLASS ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices


// Get the class at the given index on the given day (supports todayIndexKey)
- (SchoolClass *)classWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex;


// Returns the total number of articles in a given section (filtered and non-filtered)
// (supports todayIndexKey)
- (NSUInteger)numberOfPeriodsInDayWithIndex:(NSUInteger)dayIndex;

// Returns the number of days in the schedule
- (NSUInteger)numberOfDays;

// Returns the string for the given day index
- (NSString *)dayNameForIndex:(NSUInteger)dayIndex;


// Removes the given class from the given day
- (void)deleteClassWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex;


// Moves the given class from one index to another
- (void)moveClassOnDayIndex:(NSUInteger)dayIndex fromClassIndex:(NSUInteger)fromClassIndex toClassIndex:(NSUInteger)toClassIndex;


// Change the information for a given class
- (void)setClassName:(NSString *)className classTime:(NSString *)classTime forClassWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex;


// Adds a new class period with the given info to the end of the given day
- (void)addClassWithName:(NSString *)className time:(NSString *)classTime toEndOfDayWithIndex:(NSUInteger)dayIndex;


- (BOOL)isClassAcademicWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex;

@end
