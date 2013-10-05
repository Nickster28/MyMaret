//
//  Assignment.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Assignment : NSObject <NSCoding>

// The name of the class the assignment is for
@property (nonatomic, strong) NSString *className;

// The full due date of the assignment
@property (nonatomic, strong) NSDate *dueDate;

// The date comps for the day the assignment is due (used for sorting by day due)
@property (nonatomic, strong) NSDateComponents *dueDateDayDateComps;

// The string containing the time the assignment is due (ex. "2:15")
@property (nonatomic, strong) NSString *dueTimeString;

// The name of the assignment
@property (nonatomic, strong) NSString *assignmentName;


/*! Creates an assignment with the given info.
 * @param assignmentName the name/description of the assignment.
 * @param dueDate the date and time the assignment is due.
 * @param className the name of the class the assignment is for.
 * @param isNormalDay a boolean indicating whether the schedule is normal
 * on the given due day or if the schedule is wierd (ex. Friday schedule
 * on a Wednesday).
 */
- (id)initWithAssignmentName:(NSString *)assignmentName
                     dueDate:(NSDate *)dueDate
            forClassWithName:(NSString *)className
               isOnNormalDay:(BOOL)isNormalDay;




// Returns either a string representation of the day,
// or a name of a weekday if the assignment is due within the next week
- (NSString *)dueDateAsString;

@end
