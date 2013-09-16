//
//  DateTimeDisplayCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "DateTimeDisplayCell.h"

@interface DateTimeDisplayCell()

// The 2 labels
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@end

@implementation DateTimeDisplayCell

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


- (void)setTitleText:(NSString *)title
{
    [[self titleLabel] setText:title];
}


- (void)setDate:(NSDate *)date
{
    _date = date;
    
    // Change our date/time label to display the new date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    [[self dateTimeLabel] setText:[formatter stringFromDate:date]];
}


- (NSString *)timeText
{
    return self.dateTimeLabel.text;
}


- (void)setTimeText:(NSString *)text
{
    [self.dateTimeLabel setText:text];
}





- (void)datePickerDidDisplayDate:(NSDate *)date
               forDatePickerMode:(UIDatePickerMode)mode
{
    NSAssert(mode == UIDatePickerModeDateAndTime || mode == UIDatePickerModeTime, @"Only date/time and time are currently supported for reading into a date time display cell.");
    
    // Make a date formatter to make a string out of the given date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // If the picker is only displaying time, we only want to display time
    if (mode == UIDatePickerModeTime) {
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    } else {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    [self.dateTimeLabel setText:[dateFormatter stringFromDate:date]];
}


@end
