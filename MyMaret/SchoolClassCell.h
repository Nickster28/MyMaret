//
//  SchoolClassCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SchoolClass;

@interface SchoolClassCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *classNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *classTimeLabel;


- (void)bindSchoolClass:(SchoolClass *)class isAcademicClass:(BOOL)isAcademicClass;

@end
