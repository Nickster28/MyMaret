//
//  ClassScheduleStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/7/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "ClassScheduleStore.h"
#import "UIApplication+HasNetworkConnection.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "SchoolClass.h"

@interface ClassScheduleStore()
@property (nonatomic, strong) NSDictionary *classScheduleDictionary;
@property (nonatomic) NSUInteger todayDayIndex;
@property (nonatomic, strong) NSDate *lastTodayIndexOverride;
@property (nonatomic, strong) NSMutableArray *classList;
@end


const NSUInteger todayIndexKey = -1;
NSString * const ClassScheduleStoreTempTodayIndexPrefKey = @"ClassScheduleStoreTodayIndexPrefKey";
NSString * const ClassScheduleStoreTodayIndexOverrideDateKey = @"ClassScheduleStoreTodayIndexOverrideDateKey";

@implementation ClassScheduleStore
@synthesize todayDayIndex = _todayDayIndex;
@synthesize lastTodayIndexOverride = _lastTodayIndexOverride;
@synthesize classList = _classList;


// Singleton instance
+ (ClassScheduleStore *)sharedStore
{
    static ClassScheduleStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[ClassScheduleStore alloc] init];
    });
    
    return sharedStore;
}


- (NSString *)classScheduleArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"classSchedule.archive"];
}


- (NSString *)classListArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"classList.archive"];
}


- (void)checkLastTodayIndexOverride
{
    // If we're not on the day when the index was overriden,
    // ignore it
    if (self.lastTodayIndexOverride) {
        NSDateComponents *todayComps = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit)
                                                                       fromDate:[NSDate date]];
        NSDateComponents *lastOverrideComps = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit)
                                                                              fromDate:[self lastTodayIndexOverride]];
        
        if (todayComps.month != lastOverrideComps.month || todayComps.day != lastOverrideComps.day) {
            [self setLastTodayIndexOverride:nil];
        }
    }
}


- (NSUInteger)todayDayIndex
{
    // Checks to see if it's still the same day
    // that the user last overrode the today index
    // (If the last update is nil, then there is no override)
    [self checkLastTodayIndexOverride];
    
    // If there is a recent override, return it rather than
    // calculating what day it is
    if (self.lastTodayIndexOverride) {
        _todayDayIndex = [[NSUserDefaults standardUserDefaults] integerForKey:ClassScheduleStoreTempTodayIndexPrefKey];
        
        return _todayDayIndex;
    }
    
    // If there's no override, we need to figure out what today is
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    // In NSDateComponents, Sunday = 1 ... Saturday = 7
    // We want Monday = 0 ... Sunday = 6
    
    // Sunday = 0 ... Saturday = 6
    NSUInteger dayIndex = [dateComps weekday] - 1;
    
    // Sunday = -1 ... Saturday = 5;
    dayIndex -= 1;
    
    // Monday = 0 ... Sunday = 6
    if (dayIndex == -1) dayIndex = 6;
    
    _todayDayIndex = dayIndex;
    
    return _todayDayIndex;
}


- (void)setTodayDayIndex:(NSUInteger)todayDayIndex
{
    _todayDayIndex = todayDayIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:todayDayIndex
                                               forKey:ClassScheduleStoreTempTodayIndexPrefKey];
    
    // set the date we last changed the today index so we know when it's out of date
    [self setLastTodayIndexOverride:[NSDate date]];
}


- (NSDate *)lastTodayIndexOverride
{
    if (!_lastTodayIndexOverride) {
        _lastTodayIndexOverride = [[NSUserDefaults standardUserDefaults] objectForKey:ClassScheduleStoreTodayIndexOverrideDateKey];
    }
    
    return _lastTodayIndexOverride;
}


- (void)setLastTodayIndexOverride:(NSDate *)lastTodayIndexOverride
{
    _lastTodayIndexOverride = lastTodayIndexOverride;
    [[NSUserDefaults standardUserDefaults] setObject:lastTodayIndexOverride
                                              forKey:ClassScheduleStoreTodayIndexOverrideDateKey];
}


- (NSDictionary *)classScheduleDictionary
{
    if (!_classScheduleDictionary) {
        
        // Unarchive the schedule from disk
        _classScheduleDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self classScheduleArchivePath]];
        
        // If we haven't saved one yet, download it from Parse (if the user is a student)
        if (!_classScheduleDictionary &&
            [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretUserGradeKey] <= 12) {
            
            [self fetchClassScheduleWithCompletionBlock:^(NSError *error) {
                
            }];
        } else if (!_classScheduleDictionary) {
            [self createNewClassScheduleDictionary];
        }
    }
    
    return _classScheduleDictionary;
}


- (NSMutableArray *)classList
{
    if (!_classList) {
        
        // Unarchive it from disk
        _classList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self classListArchivePath]];
        
        // If we don't have one saved, make a new one
        if (!_classList) {
            _classList = [NSMutableArray array];
        }
    }
    
    return _classList;
}



// If this class is gone from the schedule, remove it from our class list
// CALL AFTER REMOVING A CLASS FROM THE SCHEDULE
- (void)removeClassFromClassListIfNoneLeft:(NSString *)className
{
    // Filter through all the class periods and see how many instances
    // there are of the given class name
    NSArray *allDays = [[self classScheduleDictionary] allValues];
    
    // Now combine all the periods from each day into one array
    NSMutableArray *allPeriods = [NSMutableArray array];
    for (NSArray *day in allDays) {
        [allPeriods addObjectsFromArray:day];
    }
    
    NSUInteger numOthers = [[allPeriods indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([[(SchoolClass *)obj className] isEqualToString:className]) {

            // We only need to know that there is another class with this name
            *stop = true;
            
            return true;
        } return false;
    
    }] count];
    
    // If there are none left, remove the class
    if (numOthers == 0) {
        [self.classList removeObject:className];
    }
}


// If this class is new to our schedule (ie there are no other instances), add it to our class list
- (void)addClassToClassListIfNew:(NSString *)className
{
    // Search for the class
    NSUInteger index = [[self classList] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        return [(NSString *)obj isEqualToString:className];
    }];
    
    // If there are none, add the class
    if (index == NSNotFound) {
        [self.classList addObject:className];
    }
}


- (void)createNewClassScheduleDictionary
{
    // Make a new dictionary to hold the class schedule (keys = strings (days), values = arrays of SchoolClasses)
    [self setClassScheduleDictionary:[[NSDictionary alloc] initWithObjects:@[[NSMutableArray array],
                                                                             [NSMutableArray array],
                                                                             [NSMutableArray array],
                                                                             [NSMutableArray array],
                                                                             [NSMutableArray array]]
                                                                   forKeys:@[@"Monday",
                                                                             @"Tuesday",
                                                                             @"Wednesday",
                                                                             @"Thursday",
                                                                             @"Friday"]]];
    
    // Get a dictionary where keys = strings (days), values = arrays of times as strings
    NSDictionary *classTimes = [self schoolClassTimes];
    
    // Loop through each day in our class schedule dictionary and set up an empty schedule
    for (NSString *day in [[self classScheduleDictionary] allKeys]) {

        // Get the array of class times for the current day
        NSArray *dayClassTimes = [classTimes objectForKey:day];
        
        // Loop through them, making a SchoolClass for each one and adding
        // it to the day's array of classes
        for (NSUInteger i = 0; i < dayClassTimes.count; i++) {
            SchoolClass *class = [[SchoolClass alloc] init];
            [class setClassTime:dayClassTimes[i]];
            
            [[[self classScheduleDictionary] objectForKey:day] addObject:class];
        }
    }
}


// Returns a dictionary where the key is the day and the value is an array
// of class times (taking into account the user's grade)
- (NSDictionary *)schoolClassTimes
{
    // Get the user's grade
    NSUInteger grade = [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretUserGradeKey];
    
    NSArray *mondayArray = @[], *tuesdayArray = @[], *wednesdayArray = @[], *thursdayArray = @[], *fridayArray = @[];
    
    if (grade == 9) {
        mondayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:15-10:40", @"10:45-11:35", @"11:40-12:20", @"12:25-1:15", @"1:20-2:10", @"2:15-3:05"];
        tuesdayArray = @[@"8:10-9:00", @"9:05-9:55", @"9:55-10:10", @"10:15-11:25", @"11:30-12:05", @"12:10-1:00", @"1:05-1:55", @"2:00-3:10"];
        thursdayArray = @[@"8:10-9:20", @"9:25-10:15", @"10:15-10:35", @"10:40-11:30", @"11:35-12:10", @"12:15-1:05", @"1:10-2:00", @"2:05-3:15"];
        fridayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:45", @"10:50-11:40", @"11:45-12:25", @"12:30-1:20", @"1:25-2:15", @"2:20-3:10"];
    } else if (grade >= 10 && grade <= 12) {
        mondayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:20-10:40", @"10:45-11:35", @"11:40-12:30", @"12:35-1:15", @"1:20-2:10", @"2:15-3:05"];
        tuesdayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:10", @"10:15-11:25", @"11:30-12:20", @"12:25-1:00", @"1:05-1:55", @"2:00-3:10"];
        thursdayArray = @[@"8:10-9:20", @"9:25-10:15", @"10:20-10:35", @"10:40-11:30", @"11:35-12:25", @"12:30-1:05", @"1:10-2:00", @"2:05-3:15"];
        fridayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:45", @"10:50-11:40", @"11:45-12:35", @"12:40-1:20", @"1:25-2:15", @"2:20-3:10"];
    }
    
    if (grade >= 9 && grade <= 12) {
        wednesdayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:20-10:55", @"11:00-12:10", @"12:15-12:50", @"12:55-1:45"];
    }
    
    return [NSDictionary dictionaryWithObjects:@[mondayArray, tuesdayArray, wednesdayArray, thursdayArray, fridayArray]
                                       forKeys:@[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday"]];
}


- (void)configureScheduleWithClasses:(NSArray *)classes
{
    // Create a new empty dictionary
    [self createNewClassScheduleDictionary];
    
    BOOL isFreshman = [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretUserGradeKey] == 9;
    
    // Loop through and add class info for each day
    for (NSString * day in [self classScheduleDictionary]) {
        
        NSArray *classSchedule = [[self classScheduleDictionary] objectForKey:day];
        
        if ([day isEqualToString:@"Monday"]) {
            
            [classSchedule[0] setClassName:classes[0]];
            [classSchedule[1] setClassName:classes[1]];
            [classSchedule[2] setClassName:@"Convocation"];
            [classSchedule[3] setClassName:classes[2]];
            [classSchedule[4] setClassName:(isFreshman) ? @"Lunch" : classes[3]];
            [classSchedule[5] setClassName:(isFreshman) ? classes[3] : @"Lunch"];
            [classSchedule[6] setClassName:classes[4]];
            [classSchedule[7] setClassName:classes[5]];
            
        } else if ([day isEqualToString:@"Tuesday"]) {
            
            [classSchedule[0] setClassName:classes[0]];
            [classSchedule[1] setClassName:classes[1]];
            [classSchedule[2] setClassName:@"Break"];
            [classSchedule[3] setClassName:classes[2]];
            [classSchedule[4] setClassName:(isFreshman) ? @"Lunch" : classes[4]];
            [classSchedule[5] setClassName:(isFreshman) ? classes[4] : @"Lunch"];
            [classSchedule[6] setClassName:classes[5]];
            [classSchedule[7] setClassName:classes[6]];
            
        } else if ([day isEqualToString:@"Wednesday"]) {
            
            [classSchedule[0] setClassName:classes[0]];
            [classSchedule[1] setClassName:classes[4]];
            [classSchedule[2] setClassName:@"Assembly"];
            [classSchedule[3] setClassName:classes[3]];
            [classSchedule[4] setClassName:@"Lunch"];
            [classSchedule[5] setClassName:classes[6]];
            
        } else if ([day isEqualToString:@"Thursday"]) {
            
            [classSchedule[0] setClassName:classes[0]];
            [classSchedule[1] setClassName:classes[1]];
            [classSchedule[2] setClassName:@"Break"];
            [classSchedule[3] setClassName:classes[2]];
            [classSchedule[4] setClassName:(isFreshman) ? @"Lunch" : classes[3]];
            [classSchedule[5] setClassName:(isFreshman) ? classes[3] : @"Lunch"];
            [classSchedule[6] setClassName:classes[6]];
            [classSchedule[7] setClassName:classes[5]];
            
        } else if ([day isEqualToString:@"Friday"]) {
            
            [classSchedule[0] setClassName:classes[5]];
            [classSchedule[1] setClassName:classes[6]];
            [classSchedule[2] setClassName:@"Assembly"];
            [classSchedule[3] setClassName:classes[3]];
            [classSchedule[4] setClassName:(isFreshman) ? @"Lunch" : classes[4]];
            [classSchedule[5] setClassName:(isFreshman) ? classes[4] : @"Lunch"];
            [classSchedule[6] setClassName:classes[1]];
            [classSchedule[7] setClassName:classes[2]];
            
        }
    }
}



// Save changes to our schedule dictionary
- (BOOL)saveChanges
{
    // save our schedule dictionary
    BOOL classScheduleSuccess = [NSKeyedArchiver archiveRootObject:[self classScheduleDictionary]
                                               toFile:[self classScheduleArchivePath]];
    
    
    // save our array of all classes
    BOOL classListSuccess = [NSKeyedArchiver archiveRootObject:[self classList]
                                                        toFile:[self classListArchivePath]];
    
    if (!classScheduleSuccess) {
        NSLog(@"Could not save class schedule.");
    }
    
    if (!classListSuccess) {
        NSLog(@"Could not save class list.");
    }
    
    return classListSuccess && classScheduleSuccess;
}



#pragma mark Public APIs


- (NSArray *)allClasses
{
    return self.classList;
}


- (NSUInteger)numberOfClasses
{
    return self.classList.count;
}



- (BOOL)isClassNamed:(NSString *)className onDayWithIndex:(NSUInteger)dayIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    NSString *dayName = [self dayNameForIndex:dayIndex];
    if ([dayName isEqualToString:@"Weekend"]) return NO;
    
    // Get the whole day's schedule
    NSArray *allPeriods = [[self classScheduleDictionary] objectForKey:dayName];
    
    // See if the class appears in the array
    for (SchoolClass *class in allPeriods) {
        if ([[class className] isEqualToString:className]) {
            return true;
        }
    }
    
    return false;
}


- (NSString *)startTimeForClassNamed:(NSString *)className onDayWithIndex:(NSUInteger)dayIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    // If we're looking for a class that's on the weekend (aka no class), return 00:00
    if ([dayName isEqualToString:@"Weekend"]) return @"00:00";
    
    // Get the whole day's schedule
    NSArray *allPeriods = [[self classScheduleDictionary] objectForKey:dayName];
    
    // Find the class we want and return its start time
    for (SchoolClass *class in allPeriods) {
        if ([[class className] isEqualToString:className]) {
            return [class classStartTime];
        }
    }
    
    return @"8:10";
}



- (NSString *)dayNameForIndex:(NSUInteger)dayIndex
{
    switch (dayIndex) {
        case 0:
            return @"Monday";
        case 1:
            return @"Tuesday";
        case 2:
            return @"Wednesday";
        case 3:
            return @"Thursday";
        case 4:
            return @"Friday";
        default:
            return @"Weekend";
    }
}



// Only called if the user is a student
- (void)fetchClassScheduleWithCompletionBlock:(void (^) (NSError *error))completionBlock
{
    // If we're not connected to the internet, send an error back
    if (![UIApplication hasNetworkConnection]) {
        
        // Make the error info dictionary
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"Looks like you're not connected to the Internet.  Check your WiFi or Cellular connection and try refreshing again."
                                                         forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:@"NSConnectionErrorDomain"
                                             code:2012
                                         userInfo:dict];
        
        completionBlock(error);
        return;
    }
    
    // Query for announcements posted after we last checked for announcements
    PFQuery *query = [PFQuery queryWithClassName:@"ClassSchedule"];
    [query whereKey:@"emailAddress" equalTo:[[NSUserDefaults standardUserDefaults] stringForKey:MyMaretUserEmailKey]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            NSArray *classes = @[[object objectForKey:@"firstPeriod"],
                                 [object objectForKey:@"secondPeriod"],
                                 [object objectForKey:@"thirdPeriod"],
                                 [object objectForKey:@"fourthPeriod"],
                                 [object objectForKey:@"fifthPeriod"],
                                 [object objectForKey:@"sixthPeriod"],
                                 [object objectForKey:@"seventhPeriod"]];
            
            // If there are any NSNulls in classes, replace them with empty strings
            NSMutableArray *filteredClasses = [NSMutableArray array];
            
            self.classList = [NSMutableArray array];
            
            for (NSObject *object in classes) {
                
                // Filter out NSNulls and build our class list
                if ([object isKindOfClass:[NSString class]]) {
                    [filteredClasses addObject:object];
                    [self.classList addObject:object];
                } else [filteredClasses addObject:@"Free"];
            }
            
            [self configureScheduleWithClasses:filteredClasses];
            [self saveChanges];
        }
        
        if (completionBlock) completionBlock(error);
    }];
}


- (SchoolClass *)classWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    // Convert the day index to a string
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    return [[[self classScheduleDictionary] objectForKey:dayName] objectAtIndex:classIndex];
}


- (NSUInteger)numberOfPeriodsInDayWithIndex:(NSUInteger)dayIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    // Convert the day index to a string
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    return [[[self classScheduleDictionary] objectForKey:dayName] count];
}


- (NSUInteger)numberOfDays
{
    return [[self classScheduleDictionary] count];
}


- (void)deleteClassWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex {
    
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    // Make sure we're not deleting a class on a weekend
    if ([dayName isEqualToString:@"Weekend"]) return;
    
    NSString *classNameToDelete = [[self classWithDayIndex:dayIndex classIndex:classIndex] className];
    
    // Remove the object from the dictionary
    [[[self classScheduleDictionary] objectForKey:dayName] removeObjectAtIndex:classIndex];
    
    [self removeClassFromClassListIfNoneLeft:classNameToDelete];
    
    [self saveChanges];
}


- (void)moveClassOnDayIndex:(NSUInteger)dayIndex
             fromClassIndex:(NSUInteger)fromClassIndex
               toClassIndex:(NSUInteger)toClassIndex
{
    if (fromClassIndex == toClassIndex) return;
    
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    // Make sure we're not trying to move a class that isn't in the schedule
    if ([dayName isEqualToString:@"Weekend"]) return;
    
    // Take the class out of its array
    SchoolClass *classToMove = [[[self classScheduleDictionary] objectForKey:dayName] objectAtIndex:fromClassIndex];
    
    [self deleteClassWithDayIndex:dayIndex
                       classIndex:fromClassIndex];
    
    // Reinsert it
    [[[self classScheduleDictionary] objectForKey:dayName] insertObject:classToMove atIndex:toClassIndex];
    
    [self saveChanges];
}


- (void)setClassName:(NSString *)className classTime:(NSString *)classTime forClassWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    SchoolClass *classToEdit = [self classWithDayIndex:dayIndex
                                            classIndex:classIndex];
    
    // If the caller is trying to set a class "today" when today is a weekend, do nothing
    if (!classToEdit) return;
    
    NSString *oldClassName = classToEdit.className;
    
    // Only change the class name if the class is academic
    if ([self isClassAcademicWithDayIndex:dayIndex classIndex:classIndex]) {
        
        // Possibly add this new class to our class list
        [self addClassToClassListIfNew:className];
        
        [classToEdit setClassName:className];
        
        // Possibly remove the old class from our class list
        [self removeClassFromClassListIfNoneLeft:oldClassName];
    }
    
    [classToEdit setClassTime:classTime];
    
    [self saveChanges];
}


- (void)addClassWithName:(NSString *)className time:(NSString *)classTime toEndOfDayWithIndex:(NSUInteger)dayIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    // If the user is trying to add a class to "today" when today is a weekend, do nothing
    if ([dayName isEqualToString:@"Weekend"]) return;
    
    // Create the new class
    SchoolClass *newClass = [[SchoolClass alloc] initWithName:className
                                                    classTime:classTime];
    
    
    // Add it to the end of the right day in our dictionary
    [[[self classScheduleDictionary] objectForKey:dayName] addObject:newClass];
    
    // Possibly add it to our classlist
    if ([self isClassAcademicWithDayIndex:dayIndex classIndex:[[[self classScheduleDictionary] objectForKey:dayName] count] - 1]) {
        
        [self addClassToClassListIfNew:className];
    }
    
    [self saveChanges];
}


- (BOOL)isClassAcademicWithDayIndex:(NSUInteger)dayIndex classIndex:(NSUInteger)classIndex
{
    // If the user wants info about today, change todayIndex to a real day index
    if (dayIndex == todayIndexKey) dayIndex = [self todayDayIndex];
    
    SchoolClass *class = [self classWithDayIndex:dayIndex
                                      classIndex:classIndex];
    
    // If the class is nil, then we're trying to access a class "today" when today is a weekend.
    if (!class) return NO;
    
    return !([[class className] isEqualToString:@"Break"] || [[class className] isEqualToString:@"Lunch"] || [[class className] isEqualToString:@"Assembly"] || [[class className] isEqualToString:@"Convocation"]);
}


// For the rest of the day, will override the today index
// with the given index
- (void)overrideTodayIndexWithIndex:(NSUInteger)tempDayIndex
{
    [self setTodayDayIndex:tempDayIndex];
}


// Deletes all store data
- (BOOL)clearStore {
    [self createNewClassScheduleDictionary];
    [self setClassList:nil];
    return [self saveChanges];
}


@end
