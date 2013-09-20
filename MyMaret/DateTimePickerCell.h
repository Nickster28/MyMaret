//
//  DateTimePickerCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDisplayDelegate;

@interface DateTimePickerCell : UITableViewCell

// The delegate that we notify whenever the user makes a new
// selection in the picker
@property (nonatomic, weak) id <DatePickerDisplayDelegate> delegate;

// Given a string of format "HH:MM PM" or "HH:MM AM", will set
// our picker to display that time
- (void)setDisplayedTime:(NSString *)timeString;

// Sets the picker to display the given date
- (void)setDisplayedDate:(NSDate *)date;


// Sets the minimum date of the date picker
- (void)setMinimumDate:(NSDate *)minDate;

@end
