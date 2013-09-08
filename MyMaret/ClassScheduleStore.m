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
@end


const NSUInteger todayIndexKey = -1;


@implementation ClassScheduleStore


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


- (NSUInteger)todayDayIndex
{
    if (!_todayDayIndex) {
        
        // Figure out what the name of today is
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
    }
    
    return _todayDayIndex;
}


- (NSDictionary *)classScheduleDictionary
{
    if (!_classScheduleDictionary) {
        
        // Unarchive the schedule from disk
        _classScheduleDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self classScheduleArchivePath]];
        
        // If we haven't saved one yet, download it from Parse (if the user is a student)
        if (!_classScheduleDictionary &&
            [[NSUserDefaults standardUserDefaults] integerForKey:MyMaretUserGradeKey] <= 12) {
            
            [self fetchClassScheduleWithCompletionBlock:nil];
        } else if (!_classScheduleDictionary) {
            [self createNewClassScheduleDictionary];
        }
    }
    
    return _classScheduleDictionary;
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
        for (int i = 0; i < dayClassTimes.count; i++) {
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
    NSArray *mondayArray, *tuesdayArray, *wednesdayArray, *thursdayArray, *fridayArray;
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:MyMaretUserGradeKey] == 9) {
        mondayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:15-10:40", @"10:45-11:35", @"11:40-12:20", @"12:25-1:15", @"1:20-2:10", @"2:15-3:05"];
        tuesdayArray = @[@"8:10-9:00", @"9:05-9:55", @"9:55-10:10", @"10:15-11:25", @"11:30-12:05", @"12:10-1:00", @"1:05-1:55", @"2:00-3:10"];
        thursdayArray = @[@"8:10-9:20", @"9:25-10:15", @"10:15-10:35", @"10:40-11:30", @"11:35-12:10", @"12:15-1:05", @"1:10-2:00", @"2:05-3:15"];
        fridayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:45", @"10:50-11:40", @"11:45-12:25", @"12:30-1:20", @"1:25-2:15", @"2:20-3:10"];
    } else {
        mondayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:20-10:40", @"10:45-11:35", @"11:40-12:30", @"12:35-1:15", @"1:20-2:10", @"2:15-3:05"];
        tuesdayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:10", @"10:15-11:25", @"11:30-12:20", @"12:25-1:00", @"1:05-1:55", @"2:00-3:10"];
        thursdayArray = @[@"8:10-9:20", @"9:25-10:15", @"10:20-10:35", @"10:40-11:30", @"11:35-12:25", @"12:30-1:05", @"1:10-2:00", @"2:05-3:15"];
        fridayArray = @[@"8:10-9:00", @"9:05-9:55", @"10:00-10:45", @"10:50-11:40", @"11:45-12:35", @"12:40-1:20", @"1:25-2:15", @"2:20-3:10"];
    }
    
    wednesdayArray = @[@"8:10-9:00", @"9:05-10:15", @"10:20-10:55", @"11:00-12:10", @"12:15-12:50", @"12:55-1:45"];
    
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
            
            [classSchedule[0] setClassName:classes[1]];
            [classSchedule[1] setClassName:classes[2]];
            [classSchedule[2] setClassName:@"Assembly"];
            [classSchedule[3] setClassName:classes[3]];
            [classSchedule[4] setClassName:(isFreshman) ? @"Lunch" : classes[4]];
            [classSchedule[5] setClassName:(isFreshman) ? classes[4] : @"Lunch"];
            [classSchedule[6] setClassName:classes[5]];
            [classSchedule[7] setClassName:classes[6]];
            
        }
    }
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
            return @"Houston, we have a problem."; // should not get here!
    }
}


// Save changes to our schedule dictionary
- (void)saveChanges
{
    // save our schedule dictionary
    BOOL success = [NSKeyedArchiver archiveRootObject:[self classScheduleDictionary]
                                               toFile:[self classScheduleArchivePath]];
    
    if (!success) {
        NSLog(@"Could not save class schedule.");
    }
}


#pragma mark Public APIs


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
                                 [object objectForKey:@"seventhPeriod"],
                                 [object objectForKey:@"eighthPeriod"]];
            
            [self configureScheduleWithClasses:classes];
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
    NSString *dayName = [self dayNameForIndex:dayIndex];
    
    [[[self classScheduleDictionary] objectForKey:dayName] removeObjectAtIndex:classIndex];
}


@end
