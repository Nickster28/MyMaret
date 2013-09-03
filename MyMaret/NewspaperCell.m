//
//  NewspaperCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/2/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "NewspaperCell.h"
#import "NewspaperArticle.h"

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
}


- (void)bindArticle:(NewspaperArticle *)article
{
    // Set the labels with the article's info
    [[self titleLabel] setText:[article articleTitle]];
    [[self bodyLabel] setText:[article articleBody]];
    [[self authorLabel] setText:[NSString stringWithFormat:@"By: %@", article.articleAuthor]];
    
    // Display the popular label if the article is popular
    if (article.isPopularArticle) [[self popularLabel] setText:@"Popular Article"];
    else [[self popularLabel] setText:@""];
    
    // If the article is popular, make the title and body darker
    if (article.isUnreadArticle) {
        [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:17.0]];
        //[[self bodyLabel] setTextColor:[UIColor blackColor]];
    } else {
        [[self titleLabel] setFont:[UIFont systemFontOfSize:17.0]];
        //[[self bodyLabel] setTextColor:[UIColor darkGrayColor]];
    }
}

@end
