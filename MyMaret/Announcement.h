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

@property (nonatomic, retain) NSString * announcementTitle;
@property (nonatomic, retain) NSString * announcementBody;
@property (nonatomic, retain) NSString * announcementAuthor;
@property (nonatomic) NSTimeInterval announcementPostDate;
@property (nonatomic, retain) NSDateComponents * announcementPostDateComps;
@property (nonatomic) BOOL isUnreadAnnouncement;
@property (nonatomic) double announcementOrderingValue;

+ (id)announcementWithTitle:(NSString *)aTitle
                       body:(NSString *)aBody
                     author:(NSString *)author
                   postDate:(NSDate *)datePosted
     inManagedObjectContext:(NSManagedObjectContext *)context;


- (NSString *)description;

- (NSString *)postDateAsString;

@end
