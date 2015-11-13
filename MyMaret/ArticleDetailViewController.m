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
#import <MessageUI/MessageUI.h>


@interface ArticleDetailViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextView *articleTextView;

// The button to email the contents of the article
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@end

@implementation ArticleDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set up the attributed string containing all the article info
    NSAttributedString *attributedArticleString = [self makeAttributedStringFromArticle:self.article];
    
    [self.articleTextView setAttributedText:attributedArticleString];
    
    
    // Set the email button image
    [self.emailButton setImage:[UIImage imageNamed:@"EmailIcon7"]];
    
    // Can we send email?
    if (![MFMailComposeViewController canSendMail]) {
        self.emailButton.enabled = NO;
    }
}


- (NSAttributedString *)makeAttributedStringFromArticle:(NewspaperArticle *)article
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:article.description];
    
    
    // The title will be italic trebuchet ms 32
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"TrebuchetMS-Italic"
                                             size:32.0]
                       range:NSMakeRange(0, article.articleTitle.length)];
    
    // The author will be italic system font 20
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont italicSystemFontOfSize:20.0]
                       range:NSMakeRange(article.articleTitle.length + 1,
                                         article.articleAuthor.length + 4)];
    
    // The author will be in green
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor schoolColor]
                       range:NSMakeRange(article.articleTitle.length + 1,
                                         article.articleAuthor.length + 4)];
    
    // The rest of the text will be system 17 font
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:17.0]
                       range:NSMakeRange(article.articleTitle.length + 5 + article.articleAuthor.length + 3, article.articleBody.length)];
    
    return attrString;
}


// Triggered when the user taps on the "Email" button - sends an email from one of the user's mail
// accounts with the contents of the article (title, body, author)
- (IBAction)emailArticle:(id)sender
{
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    mailView.mailComposeDelegate = self;
    
    [mailView setSubject:[NSString stringWithFormat:@"Check out \"%@\" in The Woodley Leaves", [self.article articleTitle]]];
    
    [mailView setMessageBody:self.article.description
                      isHTML:NO];
    
    
    [self.navigationController presentViewController:mailView
                                            animated:YES
                                          completion:nil];
}



// Show the email compose window
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
    
    if (error) {
        UIAlertView *mailErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
        
        [mailErrorAlertView show];
    }
}

@end
