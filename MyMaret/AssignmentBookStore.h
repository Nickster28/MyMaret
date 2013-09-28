//
//  AssignmentBookStore.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Assignment;
@interface AssignmentBookStore : NSObject


// Get the singleton instance of AssignmentBookStore
+ (AssignmentBookStore *)sharedStore;


// Clears all store data
- (BOOL)clearStore;


// Adds an assignment to the store
- (void)addAssignmentWithName:(NSString *)name dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className;

// Removes old assignments that were due previously
- (void)removeOldAssignments;


/************ ACCESSING ASSIGNMENTS BY CLASS ****************/

// The number of classes the user is in
- (NSUInteger)numberOfClasses;


// Returns the name of the class at the given index
- (NSString *)nameOfClassWithIndex:(NSUInteger)index;


// Returns the number of assignments the user has for the given class name
- (NSUInteger)numberOfAssignmentsForClassWithIndex:(NSUInteger)index;


// Returns the assignment in the given class at the given index
- (Assignment *)assignmentWithClassIndex:(NSUInteger)classIndex assignmentIndex:(NSUInteger)assignmentIndex;


// Removes the given assignment
- (void)removeAssignmentWithClassIndex:(NSUInteger)classIndex assignmentIndex:(NSUInteger)assignmentIndex;



/************ ACCESSING ASSIGNMENTS BY DUE DATE *************/


// The number of days the user has assignments due
- (NSUInteger)numberOfDaysWithAssignments;


// The name of the day (either "day/month" or the name of the weekday
// if the date is within a week)
- (NSString *)nameOfDayWithIndex:(NSUInteger)dayIndex;


// The number of assignments due on the day with the given index
- (NSUInteger)numberOfAssignmentsForDayWithIndex:(NSUInteger)dayIndex;


// Returns the assignment in the given day at the given index
- (Assignment *)assignmentWithDayIndex:(NSUInteger)dayIndex assignmentIndex:(NSUInteger)assignmentIndex;


// Removes the given assignment
- (void)removeAssignmentWithDayIndex:(NSUInteger)dayIndex assignmentIndex:(NSUInteger)assignmentIndex;



/*********** ACCESSING ASSIGNMENTS DUE TODAY ****************/

// Reloads the list of assignments due today
// Should be called before the screen appears showing
// today's assignments
- (void)refreshAssignmentsDueToday;

// The number of assignments due today
- (NSUInteger)numberOfAssignmentsDueToday;


// Returns the assignment due today at the given index
- (Assignment *)assignmentDueTodayWithAssignmentIndex:(NSUInteger)assignmentIndex;

// Removes the given assignment
- (void)removeAssignmentDueTodayWithAssignmentIndex:(NSUInteger)assignmentIndex;

@end
