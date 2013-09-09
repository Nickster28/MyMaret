//
//  Assignment.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "Assignment.h"


@implementation Assignment

@dynamic dueDate;
@dynamic assignmentTitle;
@dynamic schoolClassName;


- (NSDate *)dueDateAsDate
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:self.dueDate];
}

@end
