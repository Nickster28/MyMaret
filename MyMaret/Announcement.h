//
//  Announcement.h
//  MyMaret
//
//  Created by Nick Troccoli on 7/30/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Announcement : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * author;
@property (nonatomic) NSTimeInterval postDate;
@property (nonatomic) BOOL isUnread;
@property (nonatomic) double orderingValue;

+ (Announcement *)announcementWithTitle:(NSString *)announcementTitle
                                   body:(NSString *)announcementBody
                                 author:(NSString *)announcementAuthor
                               postDate:(NSDate *)datePosted
                 inManagedObjectContext:(NSManagedObjectContext *)context;


- (NSString *)postDateAsString;
- (NSString *)description;

@end
