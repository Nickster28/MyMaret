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
#import "DateTimePickerCell.h"

@interface DateTimeDisplayCell : UITableViewCell <DatePickerDisplayDelegate>


// Sets the text displayed in the title label on the left
- (void)setTitleText:(NSString *)title;


/********* DISPLAYING A TIME **********/

// Get the current text displayed in the detail label for time
- (NSString *)timeText;

// Set the current text displayed in the detail label
// Must be in the format "HH:MMam" or "HH:MMpm"
- (void)setTimeText:(NSString *)text;



/********* DISPLAYING A DATE AND TIME ************/

@property (nonatomic, strong) NSDate *date;


@end
