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

// The article to display
@property (nonatomic, strong) NewspaperArticle *article;

- (IBAction)emailArticle:(id)sender;

@end
