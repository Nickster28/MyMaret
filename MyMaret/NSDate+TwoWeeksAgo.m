//
//  NSDate+TwoWeeksAgo.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NSDate+TwoWeeksAgo.h"

@implementation NSDate (TwoWeeksAgo)
+ (NSDate *)dateTwoWeeksAgo
{
    NSTimeInterval referenceInterval = [NSDate timeIntervalSinceReferenceDate];
    referenceInterval -= 1209600;
    
    return [NSDate dateWithTimeIntervalSinceReferenceDate:referenceInterval];
}

- (NSDate *)dateTwoWeeksAgo
{
    NSTimeInterval referenceInterval = [self timeIntervalSinceReferenceDate];
    referenceInterval -= 1209600;
    
    return [NSDate dateWithTimeIntervalSinceReferenceDate:referenceInterval];
}
@end
