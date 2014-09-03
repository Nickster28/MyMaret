//
//  MyMaret_Tests.m
//  MyMaret Tests
//
//  Created by Nick Troccoli on 8/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "AnnouncementsStore.h"

@interface AnnouncementStore_Tests : XCTestCase
@property (nonatomic, strong) AnnouncementsStore *aStore;
@end

@implementation AnnouncementStore_Tests

- (void)setUp
{
    [super setUp];
    
    self.aStore = [AnnouncementsStore alloc];
    id partialMock = OCMPartialMock(self.aStore);
    OCMStub([partialMock performSelector:NSSelectorFromString(@"announcementsArchivePath")]).andReturn([self announcementsArchivePath]);
    self.aStore = [self.aStore init];
}

- (NSString *)announcementsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [documentDirectories objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"mymaretunitteststore.data"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWorks
{
    XCTAssertTrue([self.aStore numberOfAnnouncements] == 0, @"Not 0!");
}

@end
