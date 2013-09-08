//
//  SchoolClassTimeCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolClassTimeCell : UITableViewCell

// Get the current chosen class time
- (NSString *)enteredClassTime;

// Sets the initial class time that appears in the label to the right
- (void)setDisplayedClassTime:(NSString *)classTime;

@end
