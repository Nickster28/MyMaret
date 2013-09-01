//
//  NewspaperArticle.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/1/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewspaperArticle : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSNumber *isMostPopular;
@property (nonatomic, strong) NSNumber *isUnread;
@property (nonatomic, strong) NSString * section;
@property (nonatomic, strong) NSString * edition;


+ (NewspaperArticle *)initWithTitle:(NSString *)articleTitle
                               body:(NSString *)articleBody
                             author:(NSString *)articleAuthor
                            section:(NSString *)articleSection
                        publishDate:(NSDate *)publishDate;

@end
