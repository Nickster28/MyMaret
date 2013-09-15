//
//  AssignmentBookStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentBookStore.h"
#import "ClassScheduleStore.h"

@interface AssignmentBookStore()

// 3 Dictionaries to manage filtering by date and by class
@property (nonatomic, strong) NSDictionary *assignmentsByDateDictionary;
@property (nonatomic, strong) NSDictionary *assignmentsByClassDictionary;
@property (nonatomic, strong) NSDictionary *todayDictionary;

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



- (NSDictionary *)assignmentsByDateDictionary
{
    if (!_assignmentsByDateDictionary) {
        _assignmentsByDateDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self assignmentsByDateDictionaryArchivePath]];
        
        // If we haven't saved one yet, make a new one
        if (!_assignmentsByDateDictionary) {
            _assignmentsByDateDictionary = [NSDictionary dictionary];
            
            [self saveChanges];
        }
    }
    
    return _assignmentsByDateDictionary;
}


- (NSDictionary *)assignmentsByClassDictionary
{
    if (!_assignmentsByClassDictionary) {
        _assignmentsByClassDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:[self assignmentsByClassDictionaryArchivePath]];
        
        // If we haven't saved one yet, make a new one
        if (!_assignmentsByClassDictionary) {
            
            // Get the user's classes (an array of classnames as strings)
            NSArray *classList = [[ClassScheduleStore sharedStore] allClasses];
            
            // Make an array for each class's assignments
            NSMutableArray *keys;
            NSUInteger numClasses = [classList count];
            
            for (int i = 0; i < numClasses; i++) {
                [keys addObject:[NSMutableArray array]];
            }
            
            _assignmentsByClassDictionary = [NSDictionary dictionaryWithObjects:classList
                                                                      forKeys:keys];
            
            [self saveChanges];
        }
    }
    
    return _assignmentsByClassDictionary;
}


- (void)saveChanges
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
    
    //return dateDictionarySuccess && classDictionarySuccess;
}



#pragma mark Public APIs

- (NSString *)nameForClassAtIndex:(NSUInteger)index
{
    return [[[self assignmentsByClassDictionary] allKeys] objectAtIndex:index];
}


- (NSUInteger)numberOfAssignmentsForClass:(NSString *)className
{
    return [[[self assignmentsByClassDictionary] objectForKey:className] count];
}


- (NSUInteger)numberOfAssignmentsForDateWithDay:(NSUInteger)dayNum Month:(NSUInteger)monthNum
{
    return 0;
}



- (BOOL)clearStore
{
    return true;
}



@end
