//
//  DateTimePickerCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "DateTimePickerCell.h"
#import "DateTimeDisplayCell.h"

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


- (void)setMinimumDate:(NSDate *)minDate
{
    [self.datePicker setMinimumDate:minDate];
}


- (void)setDisplayedTime:(NSString *)timeString
{
    NSAssert([self.datePicker datePickerMode] == UIDatePickerModeTime, @"Must be in Time Mode to set only the time on the date picker.");
    
    // Make a date from the given string and set our picker to display it
    // Thanks to http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns and
    // http://stackoverflow.com/questions/5638416/datefromstring-always-returns-null-with-dateformatter
    // for help with converting strings to dates with an NSDateFormatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    NSDate *displayedDate = [formatter dateFromString:timeString];
    
    [[self datePicker] setDate:displayedDate animated:NO];
}


- (void)setDisplayedDate:(NSDate *)date
{
    NSAssert([self.datePicker datePickerMode] == UIDatePickerModeDate, @"Must be in date mode to set the date on the picker.");
    
    [[self datePicker] setDate:date animated:NO];
}



@end
