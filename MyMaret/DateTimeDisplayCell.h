//
//  DateTimeDisplayCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//
//  Class for a right detail UITableViewCell that
//  is meant to be paired as the delegate of a DateTimePickerCell
//  to display the date or time chosen with its date picker.

#import <UIKit/UIKit.h>


@protocol DatePickerDisplayDelegate <NSObject>

// Notifies the delegate when our picker was changed
// to display the given date object, and tells
// the delegate what kind of info the user set (date/time, time, etc.)
- (void)datePickerDidDisplayDate:(NSDate *)date
               forDatePickerMode:(UIDatePickerMode)mode;

@end


@interface DateTimeDisplayCell : UITableViewCell <DatePickerDisplayDelegate>


// Sets the text displayed in the title label on the left
- (void)setTitleText:(NSString *)title;


/********* DISPLAYING A TIME **********/

// Get the current text displayed in the detail label for time
- (NSString *)timeText;

// Set the current text displayed in the detail label
// Must be in the format "HH:MMam" or "HH:MMpm"
- (void)setTimeText:(NSString *)text;



/********* DISPLAYING A DATE ************/

@property (nonatomic, strong) NSDate *date;


@end