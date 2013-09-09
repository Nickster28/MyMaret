//
//  TodayAnnouncementCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "TodayAnnouncementCell.h"
#import "Announcement.h"
#import "UIColor+SchoolColor.h"


@implementation TodayAnnouncementCell

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


// Set the cell to display all of the given announcement's info
- (void)bindAnnouncement:(Announcement *)announcement
{
    [self.titleLabel setText:[announcement announcementTitle]];
    
    if ([announcement isUnreadAnnouncement]) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0]];
        [self.titleLabel setTextColor:[UIColor schoolColor]];
        [self.unreadImageView setImage:[UIImage imageNamed:@"UnreadAnnouncementIcon"]];
    } else {
        [self.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.unreadImageView setImage:nil];
    }
    
    [self.authorLabel setText:[NSString stringWithFormat:@"Posted by %@", announcement.announcementAuthor]];
    
    [self.titleLabel sizeToFit];
    [self.authorLabel sizeToFit];
}

@end
