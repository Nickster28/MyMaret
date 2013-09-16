//
//  AssignmentBookStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentBookStore.h"
#import "Assignment.h"
#import "ClassScheduleStore.h"

@interface AssignmentBookStore()

// 3 Dictionaries to manage filtering by date and by class
@property (nonatomic, strong) NSMutableDictionary *assignmentsByDateDictionary;
@property (nonatomic, strong) NSMutableDictionary *assignmentsByClassDictionary;
@property (nonatomic, strong) NSDictionary *todayDictionary;

// Since the dates won't be sorted inside the dictionary,
// we need to keep a separate sorted list of dates so we know
// what order we should read them out by
@property (nonatomic, strong) NSArray *sortedDueDatesDateComponents;

@end


@implementation AssignmentBookStore


// Singleton instance
+ (AssignmentBookStore *)sharedStore
{
    static AssignmentBookStore *sharedStore;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[AssignmentBookStore alloc] init];
    });
    
    return sharedStore;
}


- (NSString *)assignmentsByDateDictionaryArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"assignmentsByDate.archive"];
}


- (NSString *)assignmentsByClassDictionaryArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get only entry from the list
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"assignmentsByClass.archive"];
}



- (NSMutableDictionary *)assignmentsByDateDictionary
{
    if (!_assignmentsByDateDictionary) {
        _assignmentsByDateDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self assignmentsByDateDictionaryArchivePath]];
        
        // If we haven't saved one yet, make a new one
        if (!_assignmentsByDateDictionary) {
            _assignmentsByDateDictionary = [NSMutableDictionary dictionary];
            
            [self saveChanges];
        }
    }
    
    return _assignmentsByDateDictionary;
}


- (NSMutableDictionary *)assignmentsByClassDictionary
{
    if (!_assignmentsByClassDictionary) {
        _assignmentsByClassDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self assignmentsByClassDictionaryArchivePath]];
        
        // If we haven't saved one yet, make a new one
        if (!_assignmentsByClassDictionary) {
            
            // Get the user's classes (an array of classnames as strings)
            NSArray *classList = [[ClassScheduleStore sharedStore] allClasses];
            
            // Make an array for each class's assignments
            NSMutableArray *objects = [NSMutableArray array];
            NSUInteger numClasses = [classList count];
            
            for (int i = 0; i < numClasses; i++) {
                [objects addObject:[NSMutableArray array]];
            }
            
            _assignmentsByClassDictionary = [NSMutableDictionary dictionaryWithObjects:objects
                                                                               forKeys:classList];
            
            [self saveChanges];
        }
    }
    
    return _assignmentsByClassDictionary;
}



- (NSArray *)sortedDueDatesDateComponents
{
    if (!_sortedDueDatesDateComponents) {
        _sortedDueDatesDateComponents = [[[self assignmentsByDateDictionary] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return [[(Assignment *)obj1 dueDate] compare:[(Assignment *)obj2 dueDate]];
        }];
    }
    
    return _sortedDueDatesDateComponents;
}


- (BOOL)saveChanges
{
    // save our schedule dictionary
    BOOL dateDictionarySuccess = [NSKeyedArchiver archiveRootObject:[self assignmentsByDateDictionary]
                                                            toFile:[self assignmentsByDateDictionaryArchivePath]];
    
    
    // save our array of all classes
    BOOL classDictionarySuccess = [NSKeyedArchiver archiveRootObject:[self assignmentsByClassDictionary]
                                                        toFile:[self assignmentsByClassDictionaryArchivePath]];
    
    if (!dateDictionarySuccess) {
        NSLog(@"Could not save by-date assignment dictionary.");
    }
    
    if (!classDictionarySuccess) {
        NSLog(@"Could not save by-class assignment dictionary.");
    }
    
    return dateDictionarySuccess && classDictionarySuccess;
}


// Date components are the keys in the by-date assignments dictionary
- (NSDateComponents *)dateComponentsForDayWithIndex:(NSUInteger)index
{
    return [[self sortedDueDatesDateComponents] objectAtIndex:index];
}


#pragma mark Public APIs


- (BOOL)clearStore
{
    self.assignmentsByClassDictionary = nil;
    self.assignmentsByDateDictionary = nil;
    self.todayDictionary = nil;
    
    return [self saveChanges];
}



- (void)addAssignmentWithName:(NSString *)name dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className
{
    Assignment *newAssignment = [[Assignment alloc] initWithAssignmentName:name
                                                                   dueDate:dueDate
                                                          forClassWithName:className];
    
    // If there are no other entries for this due date,
    // add a new key/value pair
    if (![[self assignmentsByDateDictionary] objectForKey:[newAssignment dueDateDateComps]]) {
        [[self assignmentsByDateDictionary] setObject:[NSMutableArray array]
                                               forKey:[newAssignment dueDateDateComps]];
        
        
        // Tell the sorted due dates array that it's out of date,
        // so the next time we access it it'll re-read in all the due dates
        [self setSortedDueDatesDateComponents:nil];
    }
    
    // Add the assignment to our by-date dictionary
    NSMutableArray *dateArray = [[self assignmentsByDateDictionary] objectForKey:[newAssignment dueDateDateComps]];
    [dateArray addObject:newAssignment];
    
    // Sort the by-date array so the assignments are in the right order
    [dateArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(Assignment *)obj1 dueDate] compare:[(Assignment *)obj2 dueDate]];
    }];
    
    
    
    // Add the assignment to our by-class dictionary
    NSMutableArray *classArray = [[self assignmentsByClassDictionary] objectForKey:className];
    [classArray addObject:newAssignment];
    
    // Sort the by-class array so the assignments are in the right order
    [classArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(Assignment *)obj1 dueDate] compare:[(Assignment *)obj2 dueDate]];
    }];
    
    [self saveChanges];
}




/***************** Assignments by Class *******************/

- (NSUInteger)numberOfClasses
{
    return [[self assignmentsByClassDictionary] count];
}


- (NSString *)nameOfClassWithIndex:(NSUInteger)index
{
    return [[[self assignmentsByClassDictionary] allKeys] objectAtIndex:index];
}


- (NSUInteger)numberOfAssignmentsForClassWithIndex:(NSUInteger)classIndex
{
    NSString *className = [self nameOfClassWithIndex:classIndex];
    return [[[self assignmentsByClassDictionary] objectForKey:className] count];
}


- (Assignment *)assignmentWithClassIndex:(NSUInteger)classIndex assignmentIndex:(NSUInteger)assignmentIndex
{
    // Get the name of the class
    NSString *className = [self nameOfClassWithIndex:classIndex];
    
    // Return the assignment at the given index in the class's array
    return [[[self assignmentsByClassDictionary] objectForKey:className] objectAtIndex:assignmentIndex];
}



/*************** Assignments by Due Date ****************/


- (NSUInteger)numberOfDaysWithAssignments
{
    return [[self assignmentsByDateDictionary] count];
}


- (NSString *)nameOfDayWithIndex:(NSUInteger)dayIndex
{
    NSDateComponents *dateComps = [self dateComponentsForDayWithIndex:dayIndex];
    return [(Assignment *)[[[self assignmentsByDateDictionary] objectForKey:dateComps] objectAtIndex:0] dueDateAsString];
}



- (NSUInteger)numberOfAssignmentsForDayWithIndex:(NSUInteger)dayIndex
{
    NSDateComponents *dateComps = [self dateComponentsForDayWithIndex:dayIndex];
    return [[[self assignmentsByDateDictionary] objectForKey:dateComps] count];
}


- (Assignment *)assignmentWithDayIndex:(NSUInteger)dayIndex assignmentIndex:(NSUInteger)assignmentIndex
{
    
    // Get the date components for the given day
    NSDateComponents *dateComps = [self dateComponentsForDayWithIndex:dayIndex];
    return [[[self assignmentsByDateDictionary] objectForKey:dateComps] objectAtIndex:assignmentIndex];
}


@end
