//
//  Assignment.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Assignment : NSManagedObject

@property (nonatomic) NSTimeInterval dueDate;
@property (nonatomic, retain) NSString * assignmentTitle;
@property (nonatomic, retain) NSString * schoolClassName;


- (NSDate *)dueDateAsDate;

@end
