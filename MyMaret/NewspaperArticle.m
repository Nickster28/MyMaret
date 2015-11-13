//
//  Newspaperself.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperArticle.h"
#import "UIColor+SchoolColor.h"


NSString * const NewspaperArticleTitleEncodingKey = @"articleTitle";
NSString * const NewspaperArticleBodyEncodingKey = @"articlBody";
NSString * const NewspaperArticleAuthorEncodingKey = @"articleAuthor";
NSString * const NewspaperArticleSectionEncodingKey = @"articleSection";
NSString * const NewspaperArticleEditionEncodingKey = @"articleEdition";
NSString * const NewspaperArticleIsPopularEncodingKey = @"isPopularArticle";
NSString * const NewspaperArticleIsUnreadEncodingKey = @"isUnreadArticle";
NSString * const NewspaperArticleIsDigitalExclusiveEncodingKey = @"isDigitalExclusive";
NSString * const NewspaperArticleTitleAttrStringEncodingKey = @"titleAttrString";



@implementation NewspaperArticle

- (id)initWithTitle:(NSString *)articleTitle
               body:(NSString *)articleBody
             author:(NSString *)articleAuthor
            section:(NSString *)articleSection
        publishDate:(NSDate *)articlePublishDate
          isPopular:(BOOL)isPopular
 isDigitalExclusive:(BOOL)isDigitalExclusive
{
    self = [super init];
    if (self) {
        
        [self setArticleTitle:articleTitle];
        [self setArticleBody:articleBody];
        [self setArticleAuthor:articleAuthor];
        [self setArticleSection:articleSection];
        [self setIsPopularArticle:isPopular];
        [self setIsUnreadArticle:YES];
        [self setIsDigitalExclusive:isDigitalExclusive];
    
        // Get the month the self was uploaded
        NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:articlePublishDate];
    
        // Figure out which month the edition was published in
        switch ([dateComps month]) {
            case 1:
                [self setArticleEdition: @"January"];
                break;
            case 2:
                [self setArticleEdition: @"February"];
                break;
            case 3:
                [self setArticleEdition: @"March"];
                break;
            case 4:
                [self setArticleEdition: @"April"];
                break;
            case 5:
                [self setArticleEdition: @"May"];
                break;
            case 6:
                [self setArticleEdition: @"June"];
                break;
            case 7:
                [self setArticleEdition: @"July"];
                break;
            case 8:
                [self setArticleEdition: @"August"];
                break;
            case 9:
                [self setArticleEdition: @"September"];
                break;
            case 10:
                [self setArticleEdition: @"October"];
                break;
            case 11:
                [self setArticleEdition: @"November"];
                break;
            case 12:
                [self setArticleEdition: @"December"];
                break;
            default: ;
        }
        
        
        if (isDigitalExclusive) {
            // Make the attributed string
            self.titleAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Digital Exclusive: %@", self.articleTitle]];
            
            [self.titleAttrString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor schoolComplementaryColor]
                               range:NSMakeRange(0, 19)];
            
            [self.titleAttrString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor blackColor]
                               range:NSMakeRange(19, self.titleAttrString.length - 19)];
        }
    }
    
    return self;
}


// Encode all of our instance variables
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self articleTitle] forKey:NewspaperArticleTitleEncodingKey];
    [aCoder encodeObject:[self articleBody] forKey:NewspaperArticleBodyEncodingKey];
    [aCoder encodeObject:[self articleAuthor] forKey:NewspaperArticleAuthorEncodingKey];
    [aCoder encodeObject:[self articleSection] forKey:NewspaperArticleSectionEncodingKey];
    [aCoder encodeObject:[self articleEdition] forKey:NewspaperArticleEditionEncodingKey];
    
    [aCoder encodeBool:[self isPopularArticle] forKey:NewspaperArticleIsPopularEncodingKey];
    [aCoder encodeBool:[self isUnreadArticle] forKey:NewspaperArticleIsUnreadEncodingKey];
    [aCoder encodeBool:[self isDigitalExclusive] forKey:NewspaperArticleIsDigitalExclusiveEncodingKey];
    [aCoder encodeObject:[self titleAttrString] forKey:NewspaperArticleTitleAttrStringEncodingKey];
}


// Decode all of our instance variables
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setArticleTitle:[aDecoder decodeObjectForKey:NewspaperArticleTitleEncodingKey]];
        [self setArticleBody:[aDecoder decodeObjectForKey:NewspaperArticleBodyEncodingKey]];
        [self setArticleAuthor:[aDecoder decodeObjectForKey:NewspaperArticleAuthorEncodingKey]];
        [self setArticleSection:[aDecoder decodeObjectForKey:NewspaperArticleSectionEncodingKey]];
        [self setArticleEdition:[aDecoder decodeObjectForKey:NewspaperArticleEditionEncodingKey]];
        
        [self setIsPopularArticle:[aDecoder decodeBoolForKey:NewspaperArticleIsPopularEncodingKey]];
        [self setIsUnreadArticle:[aDecoder decodeBoolForKey:NewspaperArticleIsUnreadEncodingKey]];
        [self setIsDigitalExclusive:[aDecoder decodeBoolForKey:NewspaperArticleIsDigitalExclusiveEncodingKey]];
        [self setTitleAttrString:[aDecoder decodeObjectForKey:NewspaperArticleTitleAttrStringEncodingKey]];
    }
    
    return self;
}


// Returns "Title
//          By: Nick Troccoli
//
//
//          Body here
//
//
//"
- (NSString *)description {
    
    NSString *description = [NSString stringWithFormat:@"%@\nBy: %@\n\n\n%@",self.articleTitle, self.articleAuthor, self.articleBody];
    
    return description;
}

@end
