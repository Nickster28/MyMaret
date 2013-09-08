//
//  SchoolClassTimeCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClassTimeCell.h"

@interface SchoolClassTimeCell()
@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@implementation SchoolClassTimeCell

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


- (NSString *)enteredClassTime
{
    return [[self timeLabel] text];
}


- (void)setDisplayedClassTime:(NSString *)classTime
{
    [[self timeLabel] setText:classTime];
}


- (void)setIsStartTimeCell:(BOOL)isStartTime
{
    [[self cellTitleLabel] setText:(isStartTime) ? @"Start Time" : @"End Time"];
}


@end
