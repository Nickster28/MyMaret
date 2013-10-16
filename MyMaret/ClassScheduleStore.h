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


/*! If this is given as the parameter for a day index,
 * then the store will figure out what today is and
 * return appropriate information about today's class schedule.
 */
extern const NSUInteger todayIndexKey;


/*! Get the singleton instance of ClassScheduleStore
 * @return the singleton instance of ClassScheduleStore.
 */
+ (ClassScheduleStore *)sharedStore;


/*! Fetches the user's class schedule from the server and adds it
 * to the store.  Requires having the user's email stored with the
 * MyMaretUserEmailKey in NSUserDefaults.
 * @param completionBlock the block to execute after downloading the class
 * schedule.  err will be non-nil if an error occurred, or nil otherwise.
 */
- (void)fetchClassScheduleWithCompletionBlock:(void (^)(NSError *error))completionBlock;



/*! Creates a new blank schedule.  Call this method if the user is not
 * an official user and cannot have their schedule downloaded automatically.
 */
- (void)createEmptySchedule;


// **** ALL CLASS ACCESS IS DONE VIA INDICES **** //
// This works more easily with tableViews/row indices


/********* ACCESSING CLASSES ********************/

/*! Returns the class at the given classIndex on the day with the given dayIndex.
 * If todayIndexKey is provided as the day index, then the store will return
 * the class at the given classIndex in today's schedule.  Returns nil if
 * there is no class today.
 * @param dayIndex the index of the day the class is on.
 * @param classIndex the index of the class in the given day.
 * @return the class at the given dayIndex and classIndex.
 */
- (SchoolClass *)classWithDayIndex:(NSUInteger)dayIndex
                        classIndex:(NSUInteger)classIndex;


/*! Returns the number of periods in the schedule on the day with the given
 * dayIndex.
 * If todayIndexKey is provided as the day index, then the store will return
 * the number of periods in today's schedule.
 * @param dayIndex the index of the class to return the period count for.
 * @return the number of class periods in the day with the given dayIndex.
 */
- (NSUInteger)numberOfPeriodsInDayWithIndex:(NSUInteger)dayIndex;



/*! Returns the number of days in the class schedule.
 * @return the number of days in the class schedule.
 */
- (NSUInteger)numberOfDays;



/*! Returns the string name of the day with the given index.
 * If todayIndexKey is provided as the day index, then the store will return
 * the name of today (the weekday) or "Weekend" if today is a weekend.
 * @param dayIndex the index of the day to return the name for.
 * @return the name of the day at the specified dayIndex.
 */
- (NSString *)dayNameForIndex:(NSUInteger)dayIndex;



/*! Returns true or false depending on whether the class at the given day
 * and class indices is an academic class (academic means not break, assembly,
 * convocation, or lunch).
 * If todayIndexKey is provided as the day index, then the store will check
 * if the class at the given classIndex today is academic or not.  If
 * there is no class today, then this method returns false.
 * @param dayIndex the index of the day on which the class takes place.
 * @param classIndex the index of the class within the given day.
 * @return true or false depending on whether or not the class is academic.
 */
- (BOOL)isClassAcademicWithDayIndex:(NSUInteger)dayIndex
                         classIndex:(NSUInteger)classIndex;



/*! Call this when you want to manually set the day type of
 * today's schedule.  For example, if you set the today index
 * to 1 then the store will manually override its definition of "today"
 * to say that it is a Tuesday schedule.
 * @param tempDayIndex the override index of the day type of today's schedule.
 */
- (void)overrideTodayIndexWithIndex:(NSUInteger)tempDayIndex;




/*! Returns the weekday index of today, where Monday = 0, ... Friday = 4.
 * @return the weekday index of today.
 */
- (NSUInteger)todayDayIndex;


/*! Returns an array of the names of all the ACADEMIC classes the user is
 * taking.
 * @return an array of the names of the user's academic classes.
 */
- (NSArray *)allClasses;


/*! Returns the number of ACADEMIC classes the user is taking.
 * @return the number of academic classes the user is taking.
 */
- (NSUInteger)numberOfClasses;


/*! Returns a string representation of the start time of the class
 * with the given name on the day with the given index.  If todayIndexKey
 * is provided as the day index, then this method will look for a class
 * with the given name in today's schedule (or return @"00:00" if today
 * is a weekend).
 * @param className the name of the class to look for.
 * @param dayIndex the day on which to look for the class.
 * @return the string representation of the class's start time (@"8:10")
 */
- (NSString *)startTimeForClassNamed:(NSString *)className
                      onDayWithIndex:(NSUInteger)dayIndex;


/*! Returns true or false depending on whether the class with the given name
 * meets on the day with the given dayIndex.  If todayIndexKey is provided as
 * the day index, then this method will look for a class with the given name
 * in today's schedule (or return false if today is a weekend).
 * @param className the name of the class to look for.
 * @param dayIndex the day on which to look for the class.
 * @return true or false depending on whether or not the specified class
 * meets on the day with the given dayIndex.
 */
- (BOOL)isClassNamed:(NSString *)className
      onDayWithIndex:(NSUInteger)dayIndex;


/*! Deletes ALL classes in the entire store.
 * @return a boolean indicating whether the clean was successful or not.
 */
- (BOOL)clearStore;



/*********** MODIFYING CLASSES **************/

/*! Deletes the class at the given day and class indices.
 * If todayIndexKey is provided as the day index, then the store will 
 * delete the class at the given classIndex in today's schedule (or do
 * nothing if today is a weekend).
 * @param dayIndex the index of the day containing the class to delete.
 * @param classIndex the index within the given day's schedule of the class
 * to delete.
 */
- (void)deleteClassWithDayIndex:(NSUInteger)dayIndex
                     classIndex:(NSUInteger)classIndex;



/*! Moves the class on the day with the given index from fromClassIndex to
 * toClassIndex.  Note that this only moves classes within the same day - you
 * cannot move a class from one day to another.
 * @param dayIndex the index of the day the class you want to move is in.
 * @param fromClassIndex the index of the class within the given day.
 * @param toClassIndex the index within the given day where you want to move
 * the class to.
 */
- (void)moveClassOnDayIndex:(NSUInteger)dayIndex
             fromClassIndex:(NSUInteger)fromClassIndex
               toClassIndex:(NSUInteger)toClassIndex;



/*! Changes the information (name or meet time) for the class at the given day
 * and class indices.  If todayIndexKey is provided as the day index, then the
 * store will edit the class at classIndex within today's schedule (or do nothing 
 * if today is a weekend).
 * @param className the (potentially new) name of the class.
 * @param classTime the (potentially new) string containing the time when
 * the class meets (ex. @"8:10-9:00").
 * @param dayIndex the index of the day on which this class meets.
 * @param classIndex the index within the given day where the class is located.
 */
- (void)setClassName:(NSString *)className
           classTime:(NSString *)classTime
forClassWithDayIndex:(NSUInteger)dayIndex
          classIndex:(NSUInteger)classIndex;




/*! Adds a new class period with the given name and time slot to the end
 * of the day with the given index.  If todayIndexKey is provided as the day
 * index, then the store will add this class to the end of today's schedule (or
 * do nothing if today is a weekend).
 * @param className the name of the class to add.
 * @param classTime the string containing the class's time slot (ex. @"8:10-9:00").
 * @param dayIndex the index of the day on which this class should meet.
 */
- (void)addClassWithName:(NSString *)className
                    time:(NSString *)classTime
     toEndOfDayWithIndex:(NSUInteger)dayIndex;



@end
