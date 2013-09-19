//
//  SchoolClass.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/7/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SchoolClass : NSObject <NSCoding>

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *classTime;
@property (nonatomic, strong) NSString *classStartTime;
@property (nonatomic, strong) NSString *classEndTime;

- (id)initWithName:(NSString *)name
         classTime:(NSString *)timeSlot;


@end
