//
//  SchoolClassTimeEditCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolClassTimeEditCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIDatePicker *classTimePicker;

// Sets the time to be initially displayed on the picker
- (void)setDisplayedClassTime:(NSString *)classTime;


@end
