//
//  NewspaperCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/2/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperCell.h"
#import "NewspaperArticle.h"
#import "UIColor+SchoolColor.h"


static UIFont *boldTitleFont;
static UIFont *normalTitleFont;


@implementation NewspaperCell


+ (void)initialize
{
    boldTitleFont = [UIFont boldSystemFontOfSize:17.0];
    normalTitleFont = [UIFont systemFontOfSize:17.0];
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // If it's selected, change the border to white
    if (selected) {
        [self.popularLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.titleLabel setTextColor:self.titleLabel.highlightedTextColor];
    } else {
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.popularLabel.layer setBorderColor:[[UIColor schoolComplementaryColor] CGColor]];
        if (self.titleAttrString) [self.titleLabel setAttributedText:[self titleAttrString]];
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // If it's highlighted, change the border to white
    if (highlighted) {
        [self.popularLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.titleLabel setTextColor:self.titleLabel.highlightedTextColor];
    } else {
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.popularLabel.layer setBorderColor:[[UIColor schoolComplementaryColor] CGColor]];
        if (self.titleAttrString) [self.titleLabel setAttributedText:[self titleAttrString]];
    }
}


- (void)bindArticle:(NewspaperArticle *)article
{
    // Set the labels with the article's info
    [[self authorLabel] setText:[NSString stringWithFormat:@"By: %@", article.articleAuthor]];
    [[self bodyLabel] setText:[article articleBody]];
    
    
    // Bold the title if the article is unread
    if (article.isUnreadArticle) {
        [[self titleLabel] setFont:boldTitleFont];
    } else [[self titleLabel] setFont:normalTitleFont];
    
    
    // If the article is a digital exclusive, set the title to be
    // "Digital Exclusive: TITLE" (an attributed string)
    if (article.isDigitalExclusive) {
        [self setTitleAttrString:[article titleAttrString]];
        [[self titleLabel] setAttributedText:[self titleAttrString]];
    } else {
        
        // Just make it basic black text
        [[self titleLabel] setText:[article articleTitle]];
        [[self titleLabel] setTextColor:[UIColor blackColor]];
        [self setTitleAttrString:nil];
    }
    
    // If the article is popular, add the popular label with a border
    if (article.isPopularArticle) {
        [[self popularLabel] setText:@"Popular Article"];
        [[self popularLabel].layer setBorderWidth:2.0];
        [[self popularLabel].layer setBorderColor:[[UIColor schoolComplementaryColor] CGColor]];
        
    } else {
        [[self popularLabel] setText:@""];
        [[self popularLabel].layer setBorderWidth:0.0];
    }
}

@end
