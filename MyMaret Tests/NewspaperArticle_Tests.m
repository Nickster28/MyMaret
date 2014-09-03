//
//  NewspaperArticle_Tests.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/16/14.
//  Copyright (c) 2014 Nick. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "NewspaperArticle.h"
#import "UIColor+SchoolColor.h"

@interface NewspaperArticle_Tests : XCTestCase

@end

@implementation NewspaperArticle_Tests


- (void)testArticleCreation
{
    NSDate *publishDate = [NSDate date];
    NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                                   body:@"Test Body"
                                                                 author:@"Nick Troccoli"
                                                                section:@"Sports"
                                                            publishDate:publishDate
                                                              isPopular:true
                                                     isDigitalExclusive:true];
    
    XCTAssertNotNil(article, @"Article is nil!");
    XCTAssertEqualObjects(article.articleTitle, @"Test Title", @"Incorrect title - %@", article.articleTitle);
    XCTAssertEqualObjects(article.articleBody, @"Test Body", @"Incorrect body - %@", article.articleBody);
    XCTAssertEqualObjects(article.articleAuthor, @"Nick Troccoli", @"Incorrect author - %@", article.articleAuthor);
    XCTAssertTrue(article.isPopularArticle, @"Not popular!");
    XCTAssertTrue(article.isDigitalExclusive, @"Not digital exclusive!");
    XCTAssertEqualObjects(article.articleSection, @"Sports", @"Incorrect section - %@", article.articleSection);
    XCTAssertNotNil(article.titleAttrString, @"Title Attr. String is nil!"); // Will test title separately later
}


- (void)testArticleDescription
{
    NSDate *publishDate = [NSDate date];
    NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                                   body:@"Test Body"
                                                                 author:@"Nick Troccoli"
                                                                section:@"Sports"
                                                            publishDate:publishDate
                                                              isPopular:true
                                                     isDigitalExclusive:true];
    
    XCTAssertEqualObjects([article description], @"Test Title\nBy: Nick Troccoli\n\n\nTest Body", @"Incorrect description - %@", [article description]);
}


- (void)testArticleEdition
{
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    // September
    [dateComps setMonth:9];
    NSDate *publishDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                                   body:@"Test Body"
                                                                 author:@"Nick Troccoli"
                                                                section:@"Sports"
                                                            publishDate:publishDate
                                                              isPopular:true
                                                     isDigitalExclusive:true];
    
    XCTAssertEqualObjects([article articleEdition], @"September", @"Wrong edition - %@", [article articleEdition]);
    
    // April
    [dateComps setMonth:4];
    publishDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                                   body:@"Test Body"
                                                                 author:@"Nick Troccoli"
                                                                section:@"Sports"
                                                            publishDate:publishDate
                                                              isPopular:true
                                                     isDigitalExclusive:true];
    
    XCTAssertEqualObjects([article articleEdition], @"April", @"Wrong edition - %@", [article articleEdition]);
    
    // January
    [dateComps setMonth:1];
    publishDate = [[NSCalendar currentCalendar] dateFromComponents:dateComps];
    article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                 body:@"Test Body"
                                               author:@"Nick Troccoli"
                                              section:@"Sports"
                                          publishDate:publishDate
                                            isPopular:true
                                   isDigitalExclusive:true];
    
    XCTAssertEqualObjects([article articleEdition], @"January", @"Wrong edition - %@", [article articleEdition]);
}


- (void)testDigitalExclusiveTitle
{
    // Make sure there is no attributed string title
    NSDate *publishDate = [NSDate date];
    NewspaperArticle *article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                 body:@"Test Body"
                                               author:@"Nick Troccoli"
                                              section:@"Sports"
                                          publishDate:publishDate
                                            isPopular:true
                                   isDigitalExclusive:false];
    
    XCTAssertNil(article.titleAttrString, @"Title attr. string is not nil!");
    
    // Make sure there is an attributed string title
    article = [[NewspaperArticle alloc] initWithTitle:@"Test Title"
                                                 body:@"Test Body"
                                               author:@"Nick Troccoli"
                                              section:@"Sports"
                                          publishDate:publishDate
                                            isPopular:true
                                   isDigitalExclusive:true];
    
    XCTAssertNotNil(article.titleAttrString, @"Title attr. string is nil!");
    
    // Check content of title
    XCTAssertEqualObjects(@"Digital Exclusive: Test Title", [article.titleAttrString string], @"Title string incorrect - %@", [article.titleAttrString string]);
    
    // Make sure "Digital Exclusive: " is correct color
    for (int i = 0; i < [@"Digital Exclusive: " length]; i++) {
        NSDictionary *attrs = [article.titleAttrString attributesAtIndex:i effectiveRange:NULL];
        
        XCTAssertEqual(attrs.count, 1, @"Too many attributes! - %lu", (unsigned long)[attrs count]);
        XCTAssertEqualObjects([[attrs allKeys] objectAtIndex:0], NSForegroundColorAttributeName, @"Incorrect attribute name - %@", [[attrs allKeys] objectAtIndex:0]);
        XCTAssertEqualObjects([attrs objectForKey:NSForegroundColorAttributeName], [UIColor schoolComplementaryColor], @"Incorrect color - %@", [attrs objectForKey:NSForegroundColorAttributeName]);
    }
    
    // Make sure the rest of the title is black
    for (NSUInteger i = [@"Digital Exclusive: " length]; i < article.titleAttrString.length; i++) {
        NSDictionary *attrs = [article.titleAttrString attributesAtIndex:i effectiveRange:NULL];
        
        XCTAssertEqual(attrs.count, 1, @"Too many attributes! - %lu", (unsigned long)[attrs count]);
        XCTAssertEqualObjects([[attrs allKeys] objectAtIndex:0], NSForegroundColorAttributeName, @"Incorrect attribute name - %@", [[attrs allKeys] objectAtIndex:0]);
        XCTAssertEqualObjects([attrs objectForKey:NSForegroundColorAttributeName], [UIColor blackColor], @"Incorrect color - %@", [attrs objectForKey:NSForegroundColorAttributeName]);
    }
}


@end
