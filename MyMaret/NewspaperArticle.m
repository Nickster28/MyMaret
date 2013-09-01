//
//  NewspaperArticle.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperArticle.h"


@implementation NewspaperArticle

@dynamic title;
@dynamic author;
@dynamic body;
@dynamic isMostPopular;
@dynamic isUnread;
@dynamic section;
@dynamic edition;


+ (NewspaperArticle *)articleWithTitle:(NSString *)articleTitle
                                  body:(NSString *)articleBody
                                author:(NSString *)articleAuthor
                               section:(NSString *)articleSection
                           publishDate:(NSDate *)publishDate
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    NewspaperArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"NewspaperArticle"
                                                              inManagedObjectContext:context];
    
    article.title = articleTitle;
    article.body = articleBody;
    article.author = articleAuthor;
    article.section = articleSection;
    article.isMostPopular = FALSE;
    article.isUnread = TRUE;
    
    // Get the month the article was uploaded
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:publishDate];
    
    switch ([dateComps month]) {
        case 1:
            article.edition = @"January";
            break;
        case 2:
            article.edition = @"February";
            break;
        case 3:
            article.edition = @"March";
            break;
        case 4:
            article.edition = @"April";
            break;
        case 5:
            article.edition = @"May";
            break;
        case 6:
            article.edition = @"June";
            break;
        case 7:
            article.edition = @"July";
            break;
        case 8:
            article.edition = @"August";
            break;
        case 9:
            article.edition = @"September";
            break;
        case 10:
            article.edition = @"October";
            break;
        case 11:
            article.edition = @"November";
            break;
        case 12:
            article.edition = @"December";
            break;
        default: ;
    }
    
    return article;
}

@end
