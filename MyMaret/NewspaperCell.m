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
            [self.popularLabel.layer setBorderColor:[[UIColor orangeColor] CGColor]];
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
    [[self titleLabel] setText:[article articleTitle]];
    [[self bodyLabel] setText:[article articleBody]];
    [[self authorLabel] setText:[NSString stringWithFormat:@"By: %@", article.articleAuthor]];
    
    // Display the popular label if the article is popular
    // and draw an orange border around the cell
    if (article.isPopularArticle) {
        [[self popularLabel] setText:@"Popular Article"];
        [self.popularLabel.layer setBorderWidth:2.0];
        [self.popularLabel.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    } else {
        [[self popularLabel] setText:@""];
        [self.popularLabel.layer setBorderWidth:0.0];
        [self.popularLabel.layer setBorderColor:nil];
    }
    
    // If the article is popular, make the title and body darker
    if (article.isUnreadArticle) {
        [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];
        [[self titleLabel] setTextColor:[UIColor schoolColor]];
    } else {
        [[self titleLabel] setFont:[UIFont systemFontOfSize:17.0]];
        [[self titleLabel] setTextColor:[UIColor blackColor]];
    }
}

@end
