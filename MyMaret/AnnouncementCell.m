//
//  AnnouncementCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/13/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AnnouncementCell.h"
#import "Announcement.h"
#import "UIColor+SchoolColor.h"

static UIFont *boldTitleFont;
static UIFont *normalTitleFont;
static UIImage *unreadIcon;

@implementation AnnouncementCell


+ (void)initialize
{
    // Make the fonts and unread icon once here
    // so we don't have to do it every time in the bind method
    boldTitleFont = [UIFont boldSystemFontOfSize:19.0];
    normalTitleFont = [UIFont systemFontOfSize:17.0];
    unreadIcon = [UIImage imageNamed:@"UnreadAnnouncementIcon"];
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

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
}


// Set the cell to display all of the given announcement's info
- (void)bindAnnouncement:(Announcement *)announcement
{
    [self.titleLabel setText:[announcement announcementTitle]];
    
    if ([announcement isUnreadAnnouncement]) {
        [self.titleLabel setFont:boldTitleFont];
        [self.titleLabel setTextColor:[UIColor schoolColor]];
        [self.bodyLabel setTextColor:[UIColor blackColor]];
        [self.unreadImageView setImage:unreadIcon];
    } else {
        [self.titleLabel setFont:normalTitleFont];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.bodyLabel setTextColor:[UIColor darkGrayColor]];
        [self.unreadImageView setImage:nil];
    }
    
    [self.bodyLabel setText:[announcement announcementBody]];
    [self.dateLabel setText:[announcement postDateAsString]];

}

@end
