//
//  ArticleDetailViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/2/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewspaperArticle;

@interface ArticleDetailViewController : UIViewController

@property (nonatomic, strong) NewspaperArticle *article;
@end
