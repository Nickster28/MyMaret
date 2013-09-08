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


@implementation SchoolClass


- (id)initWithName:(NSString *)name classTime:(NSString *)timeSlot
{
    self = [super init];
    if (self) {
        [self setClassName:name];
        [self setClassName:timeSlot];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self className] forKey:SchoolClassClassNameEncodingKey];
    [aCoder encodeObject:[self classTime] forKey:SchoolClassClassTimeEncodingKey];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setClassName:[aDecoder decodeObjectForKey:SchoolClassClassNameEncodingKey]];
        [self setClassTime:[aDecoder decodeObjectForKey:SchoolClassClassTimeEncodingKey]];
    }
    
    return self;
}

@end
