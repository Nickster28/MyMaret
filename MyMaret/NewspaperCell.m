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

@implementation NewspaperCell

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

    // Configure the view for the selected state
    
    // Change the border around the popular string to orange
    if (!selected) {
        if (self.popularLabel.layer.borderColor) {
            [self.popularLabel.layer setBorderColor:[[UIColor schoolComplementaryColor] CGColor]];
        }
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    // Change the border around the popular string to white
    if (highlighted) {
        if (self.popularLabel.layer.borderColor) {
            [self.popularLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        }
    }
}


- (void)bindArticle:(NewspaperArticle *)article
{
    // Set the labels with the article's info
    [[self authorLabel] setText:[NSString stringWithFormat:@"By: %@", article.articleAuthor]];
    [[self bodyLabel] setText:[article articleBody]];
    
    // If the article is unread, make the title bolder
    if (article.isUnreadArticle) {
        [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];
    } else {
        [[self titleLabel] setFont:[UIFont systemFontOfSize:17.0]];
    }
    
    [[self titleLabel] setNumberOfLines:2];
    
    // If the article is a digital exclusive, set the title to be
    // "Digital Exclusive: TITLE"
    if (article.isDigitalExclusive) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Digital Exclusive: %@", [article articleTitle]]];
        
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor schoolComplementaryColor]
                           range:NSMakeRange(0, 19)];
        
        [[self titleLabel] setAttributedText:attrString];
    } else {
        [[self titleLabel] setText:[article articleTitle]];
    }
    
    // If the article is popular, add the popular label with a border
    if (article.isPopularArticle) {
        [[self popularLabel] setText:@"Popular Article"];
        [[self popularLabel].layer setBorderWidth:2.0];
        [[self popularLabel].layer setBorderColor:[[UIColor schoolComplementaryColor] CGColor]];
    } else {
        [[self popularLabel] setText:@""];
        [[self popularLabel].layer setBorderColor:nil];
        [[self popularLabel].layer setBorderWidth:0.0];
    }
}

@end
