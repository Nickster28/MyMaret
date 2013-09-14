//
//  AssignmentBookStore.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssignmentBookStore : NSObject


// Get the singleton instance of AssignmentBookStore
+ (AssignmentBookStore *)sharedStore;

// Clears all store data
- (BOOL)clearStore;

@end
