//
//  SchoolClassTimeEditCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClassTimeEditCell.h"


@implementation SchoolClassTimeEditCell

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



- (void)setDisplayedClassTime:(NSString *)classTime
{
    // The hour is at index 0, the minutes at index 1
    NSMutableArray *timeInfo = [NSMutableArray arrayWithArray:[classTime componentsSeparatedByString:@":"]];
    
    // Make sure afternoon times are marked as PM! (military time)
    if ([timeInfo[0] integerValue] < 7) {
        timeInfo[0] = [NSString stringWithFormat:@"%d", [timeInfo[0] integerValue] + 12];
    }
    
    // Make a date with the given hour and minute
    NSDateComponents *classTimeDateComps = [[NSDateComponents alloc] init];
    [classTimeDateComps setHour:[timeInfo[0] integerValue]];
    [classTimeDateComps setMinute:[timeInfo[1] integerValue]];
    
    NSDate *displayedDate = [[NSCalendar currentCalendar] dateFromComponents:classTimeDateComps];
    
    [[self classTimePicker] setDate:displayedDate animated:NO];
}



@end
