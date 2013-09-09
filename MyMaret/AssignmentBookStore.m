//
//  AssignmentBookStore.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentBookStore.h"
#import <CoreData/CoreData.h>

@interface AssignmentBookStore() {
    // Core Data
    NSManagedObjectModel *model;
    NSManagedObjectContext *context;
}

// 2 Dictionaries to manage filtering by date and by class
@property (nonatomic, strong) NSMutableDictionary *assignmentsDateDictionary;
@property (nonatomic, strong) NSDictionary *assignmentsClassDictionary;

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


- (id)init {
    self = [super init];
    
    if (self) {
        // Read in AssignmentBookCDModel.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Where does the SQLite file go?
        NSString *path = [self assignmentBookArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"AssignmentBookStore: Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = psc;
        
        // The managed object context can manage undo, but we don't need it
        context.undoManager = nil;
    }
    
    return self;
}


- (NSString *)assignmentBookArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"mymaretstore.data"];
}



- (NSMutableDictionary *)assignmentsDateDictionary
{
    // If needed, read in assignments from Core Data
    if (!_assignmentsDateDictionary) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        // Get all assignments, sorted by due date
        NSEntityDescription *description = [[model entitiesByName] objectForKey:@"Assignment"];
        [request setEntity:description];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dueDate"
                                                                         ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request
                                                 error:&error];
        
        if (!result) {
            [NSException raise:@"Assignment fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        
        // Divide assignments into different keys depending on due date
        _assignmentsDateDictionary = [[NSMutableDictionary alloc] init];
        
        
    }
    
    return _assignmentsDateDictionary;
}



@end
