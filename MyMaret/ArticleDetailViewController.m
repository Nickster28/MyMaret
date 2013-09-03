//
//  ArticleDetailViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/2/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "NewspaperArticle.h"
#import "UIColor+SchoolColor.h"

@interface ArticleDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *articleTextView;
@end

@implementation ArticleDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set up the attributed string containing all the article info
    NSAttributedString *attributedArticleString = [self makeAttributedStringFromArticle:self.article];
    
    [self.articleTextView setAttributedText:attributedArticleString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSAttributedString *)makeAttributedStringFromArticle:(NewspaperArticle *)article
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nBy: %@\n\n\n%@", article.articleTitle, article.articleAuthor, article.articleBody]];
    
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"TrebuchetMS-Italic"
                                             size:32.0]
                       range:NSMakeRange(0, article.articleTitle.length)];
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont italicSystemFontOfSize:20.0]
                       range:NSMakeRange(article.articleTitle.length + 1,
                                         article.articleAuthor.length + 4)];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor schoolColor]
                       range:NSMakeRange(article.articleTitle.length + 1,
                                         article.articleAuthor.length + 4)];
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:17.0]
                       range:NSMakeRange(article.articleTitle.length + 5 + article.articleAuthor.length + 3, article.articleBody.length)];
    
    return attrString;
}

@end
