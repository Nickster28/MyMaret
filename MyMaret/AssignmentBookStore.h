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


/*! Returns the single shared instance of AssignmentBookStore
 * @return the single instance of AssignmentBookStore
 */
+ (AssignmentBookStore *)sharedStore;


/*! Deletes ALL announcements in the entire store.
 * @return a boolean indicating whether the clean was successful or not.
 */
- (BOOL)clearStore;


/*! Adds an assignment to the store with the given name, due date, 
 * class, and whether or not the class is on a normal schedule day
 * or if it's on a wierd schedule day we don't know about.
 * @param name the assignment name/description
 * @param dueDate the date the assignment is due (time is calculated by the store)
 * based on the day and the class the assignment is for
 * @param className the name of the class the assignment is for
 * @param isNormalDay a boolean indicating whether the assignment
 * is due on a day with a normal class schedule (ex. not a Friday schedule
 * on a Wednesday).
 */
- (void)addAssignmentWithName:(NSString *)name
                      dueDate:(NSDate *)dueDate
             forClassWithName:(NSString *)className
                  isNormalDay:(BOOL)isNormalDay;



/*! Cleans out assignments that are due in the past.
 * @return true or false depending on whether or not assignments were cleaned out or not.
 */
- (BOOL)removeOldAssignments;




/************ ACCESSING ASSIGNMENTS BY CLASS ****************/


/*! Returns the number of classes that have assignments due.
 */
- (NSUInteger)numberOfClassesWithAssignments;



/*! Returns the name of the class at the given index,
 * up to numberOfClassesWithAssignments - 1.
 * @param index the index of the class you want the name of.
 * @return the name of the class at the given index.
 */
- (NSString *)nameOfClassWithIndex:(NSUInteger)index;


/*! Returns the number of assignments due for the class with the given index.
 * @param index the index of the class you want the number of assignments for.
 * @return the number of assignments for the given class.
 */
 - (NSUInteger)numberOfAssignmentsForClassWithIndex:(NSUInteger)index;



/*! Returns the assignment at the given index
 * for the class with the given index.
 * @param classIndex the index of the class the assignment is for.
 * @param assignmentIndex the index of the assignment within the class.
 * @return the assignment at the given index for the class with the given index.
 */
- (Assignment *)assignmentWithClassIndex:(NSUInteger)classIndex
                         assignmentIndex:(NSUInteger)assignmentIndex;



/*! Removes the assignment at the given index for the class with
 * the given index from the store.
 * @param classIndex the index of the class the assignment is for.
 * @param assignmentIndex the index of the assignment within the class.
 */
- (void)removeAssignmentWithClassIndex:(NSUInteger)classIndex
                       assignmentIndex:(NSUInteger)assignmentIndex;


/*! Sets an assignment's completion state as either true or false.
 * @param classIndex the index of the class the assignment is for.
 * @param assignmentIndex the index of the assignment within the class.
 * @param isCompleted a boolean indicating the completion state of the assignment.
 */
- (void)setAssignmentWithClassIndex:(NSUInteger)classIndex
                    assignmentIndex:(NSUInteger)assignmentIndex
                        asCompleted:(BOOL)isCompleted;





/************ ACCESSING ASSIGNMENTS BY DUE DATE *************/


/*! Returns the number of days that have assignments due.
 */
- (NSUInteger)numberOfDaysWithAssignments;


/*! Returns the name of the day at the given index,
 * up to numberOfDaysWithAssignments - 1.
 * @param dayIndex the index of the day you want the name of.
 * @return the name of the day at the given index.
 * The name will either be a weekday or a date with the format
 * "day/month" (ex. "Monday" or "10/22").
 */
- (NSString *)nameOfDayWithIndex:(NSUInteger)dayIndex;



/*! Returns the number of assignments due on the day with the given index.
 * @param dayIndex the index of the day you want the number of assignments for.
 * @return the number of assignments for the given day.
 */
- (NSUInteger)numberOfAssignmentsForDayWithIndex:(NSUInteger)dayIndex;



/*! Returns the assignment at the given index
 * for the day with the given index.
 * @param dayIndex the index of the day the assignment is due on.
 * @param assignmentIndex the index of the assignment within the day.
 * @return the assignment at the given index due on the day with the given index.
 */
- (Assignment *)assignmentWithDayIndex:(NSUInteger)dayIndex
                       assignmentIndex:(NSUInteger)assignmentIndex;




/*! Removes the assignment at the given index due on the day with
 * the given index from the store.
 * @param dayIndex the index of the day the assignment is due on.
 * @param assignmentIndex the index of the assignment within the day.
 */
- (void)removeAssignmentWithDayIndex:(NSUInteger)dayIndex
                     assignmentIndex:(NSUInteger)assignmentIndex;


/*! Sets an assignment's completion state as either true or false.
 * @param dayIndex the index of the day on which the assignment is due.
 * @param assignmentIndex the index of the assignment within the day.
 * @param isCompleted a boolean indicating the completion state of the assignment.
 */
- (void)setAssignmentWithDayIndex:(NSUInteger)dayIndex
                  assignmentIndex:(NSUInteger)assignmentIndex
                      asCompleted:(BOOL)isCompleted;




/*********** ACCESSING ASSIGNMENTS DUE TODAY ****************/



/*! Researches the store for assignments due today.
 * Call this method before accessing today's assignments
 * to make sure the store is up to date.
 */
- (void)refreshAssignmentsDueToday;




/*! Returns the number of assignments due today.
 */
- (NSUInteger)numberOfAssignmentsDueToday;



/*! Returns the assignment due today at the given index.
 * @param assignmentIndex the index of the assignment due today.
 */
- (Assignment *)assignmentDueTodayWithAssignmentIndex:(NSUInteger)assignmentIndex;



/*! Removes the assignment due today at the given index.
 * @param assignmentIndex the index of the assignment due today to delete.
 */
- (void)removeAssignmentDueTodayWithAssignmentIndex:(NSUInteger)assignmentIndex;



/*! Sets an assignment due today's completion state as either true or false.
 * @param assignmentIndex the index of the assignment due today.
 */
- (void)setAssignmentDueTodayWithAssignmentIndex:(NSUInteger)assignmentIndex
                                     asCompleted:(BOOL)isCompleted;

@end
