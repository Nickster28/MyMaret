//
//  DateTimePickerCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "DateTimePickerCell.h"

@interface DateTimePickerCell()
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@end


@implementation DateTimePickerCell

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


- (IBAction)datePickerValueDidChange:(UIDatePicker *)sender
{
    [self.delegate datePickerDidDisplayDate:[sender date]
                          forDatePickerMode:[sender datePickerMode]];
}


- (void)setDisplayedTime:(NSString *)timeString
{
    NSAssert([self.datePicker datePickerMode] == UIDatePickerModeTime, @"Must be in Time Mode to set only the time on the date picker.");
    
    // Make a date from the given string and set our picker to display it
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    NSDate *displayedDate = [formatter dateFromString:timeString];
    
    [[self datePicker] setDate:displayedDate animated:NO];
}


- (void)setDisplayedDate:(NSDate *)date
{
    NSAssert([self.datePicker datePickerMode] == UIDatePickerModeDateAndTime, @"Must be in date and time mode to set the date and time on the picker.");
    
    [[self datePicker] setDate:date animated:NO];
}



@end
