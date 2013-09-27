//
//  Assignment.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Assignment : NSObject <NSCoding>
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDateComponents *dueDateDateComps;
@property (nonatomic, strong) NSString *assignmentName;


- (id)initWithAssignmentName:(NSString *)assignmentName dueDate:(NSDate *)dueDate forClassWithName:(NSString *)className;


// Returns either a string representation of the day,
// or a name of a weekday if the assignment is due within the next week
- (NSString *)dueDateAsString;

// Returns a string representation of the due time
- (NSString *)dueTimeAsString;

@end
