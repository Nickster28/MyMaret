//
//  Announcement_Tests.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/16/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Announcement.h"

@interface Announcement_Tests : XCTestCase
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}
@end


@implementation Announcement_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self initializeManagedObjectContext];
}

- (void)initializeManagedObjectContext
{
    // Read in AnnouncementsCDModel.xcdatamodeld
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // Where does the SQLite file go?
    NSString *path = [self announcementsArchivePath];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    NSError *error;
    
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                           configuration:nil
                                     URL:storeURL
                                 options:nil
                                   error:&error]) {
        [NSException raise:@"AnnouncementsStore: Open failed"
                    format:@"Reason: %@", [error localizedDescription]];
    }
    
    // Create the managed object context
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc;
    
    // The managed object context can manage undo, but we don't need it
    context.undoManager = nil;
}


- (NSString *)announcementsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"mymaretunitteststore.data"];
}


- (Announcement *)createAnnouncementWithPostDate:(NSDate *)postDate
{
    return [Announcement announcementWithTitle:@"Test Title"
                                          body:@"Test Body"
                                        author:@"Nick Troccoli"
                                      postDate:postDate
                        inManagedObjectContext:context];
}


- (void)testAnnouncementCreation
{
    NSDate *postDate = [NSDate date];
    Announcement *a = [self createAnnouncementWithPostDate:postDate];
    
    XCTAssertNotNil(a, @"Announcement is nil!");
    XCTAssertEqualObjects(a.announcementTitle, @"Test Title", @"Incorrect title - title is %@", a.announcementTitle);
    XCTAssertEqualObjects(a.announcementBody, @"Test Body", @"Incorrect body - body is %@", a.announcementBody);
    XCTAssertEqualObjects(a.announcementAuthor, @"Nick Troccoli", @"Incorrect author - author is %@", a.announcementAuthor);
    XCTAssertEqual(a.announcementPostDate, [postDate timeIntervalSinceReferenceDate], @"Incorrect post date - date is %f", a.announcementPostDate);
    XCTAssertEqual(a.isUnreadAnnouncement, true, @"Announcement is read!");
    XCTAssertEqual(a.announcementOrderingValue, 0.0, @"Ordering value isn't 0 - it's %f", a.announcementOrderingValue);
    XCTAssertNotNil(a.announcementPostDateComps, @"Date comps nil!"); // Will test date comps correctness in other test
}


- (void)testAnnouncementDescription
{
    NSDate *postDate = [NSDate date];
    Announcement *a = [self createAnnouncementWithPostDate:postDate];
    NSString *desc = [NSString stringWithFormat:@"Test Body\n\nPosted Today by Nick Troccoli"]; // Will test postDateAsString later
    XCTAssertEqualObjects(a.description, desc, @"Incorrect description - %@", a.description);
}


@end
