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

@implementation AnnouncementCell

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
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0]];
        [self.titleLabel setTextColor:[UIColor schoolLightColor]];
        [self.bodyLabel setTextColor:[UIColor blackColor]];
        [self.unreadImageView setImage:[UIImage imageNamed:@"UnreadAnnouncementIcon"]];
    } else {
        [self.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.bodyLabel setTextColor:[UIColor darkGrayColor]];
        [self.unreadImageView setImage:nil];
    }
    
    [self.bodyLabel setText:[announcement announcementBody]];
    [self.dateLabel setText:[announcement postDateAsString]];

}

@end
