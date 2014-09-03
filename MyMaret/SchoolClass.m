//
//  SchoolClass.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/7/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClass.h"

NSString * const SchoolClassClassNameEncodingKey = @"className";
NSString * const SchoolClassClassTimeEncodingKey = @"classTime";
NSString * const SchoolClassClassStartTimeEncodingKey = @"classStartTime";
NSString * const SchoolClassClassEndTimeEncodingKey = @"classEndTime";

@implementation SchoolClass


- (id)initWithName:(NSString *)name classTime:(NSString *)timeSlot
{
    self = [super init];
    if (self) {
        [self setClassName:name];
        [self setClassTime:timeSlot];
    }
    
    return self;
}


- (void)setClassTime:(NSString *)classTime
{
    NSArray *times = @[@"", @""];
    
    // If the class time string is invalid, don't try to split it
    if ([classTime rangeOfString:@"-"].location != NSNotFound) {
        times = [classTime componentsSeparatedByString:@"-"];
    }
    
    // Set the individual times as well
    [self setClassStartTime:times[0]];
    [self setClassEndTime:times[1]];
    
    _classTime = classTime;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self className] forKey:SchoolClassClassNameEncodingKey];
    [aCoder encodeObject:[self classTime] forKey:SchoolClassClassTimeEncodingKey];
    [aCoder encodeObject:[self classStartTime] forKey:SchoolClassClassStartTimeEncodingKey];
    [aCoder encodeObject:[self classEndTime] forKey:SchoolClassClassEndTimeEncodingKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setClassName:[aDecoder decodeObjectForKey:SchoolClassClassNameEncodingKey]];
        [self setClassTime:[aDecoder decodeObjectForKey:SchoolClassClassTimeEncodingKey]];
        [self setClassStartTime:[aDecoder decodeObjectForKey:SchoolClassClassStartTimeEncodingKey]];
        [self setClassEndTime:[aDecoder decodeObjectForKey:SchoolClassClassEndTimeEncodingKey]];
    }
    
    return self;
}

@end
