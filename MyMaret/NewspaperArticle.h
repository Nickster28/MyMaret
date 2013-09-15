//
//  NewspaperArticle.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewspaperArticle : NSObject <NSCoding>

@property (nonatomic, strong) NSString *articleTitle;
@property (nonatomic, strong) NSString *articleAuthor;
@property (nonatomic, strong) NSString *articleBody;
@property (nonatomic) BOOL isPopularArticle;
@property (nonatomic) BOOL isUnreadArticle;
@property (nonatomic) BOOL isDigitalExclusive;
@property (nonatomic, strong) NSString * articleSection;
@property (nonatomic, strong) NSString * articleEdition;
@property (nonatomic, strong) NSMutableAttributedString *titleAttrString;


- (id)initWithTitle:(NSString *)articleTitle
               body:(NSString *)articleBody
             author:(NSString *)articleAuthor
            section:(NSString *)articleSection
        publishDate:(NSDate *)publishDate
          isPopular:(BOOL)isPopular
 isDigitalExclusive:(BOOL)isDigitalExclusive;

@end
