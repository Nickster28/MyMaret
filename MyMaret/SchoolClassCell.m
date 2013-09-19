//
//  SchoolClassCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClassCell.h"
#import "SchoolClass.h"
#import "UIColor+SchoolColor.h"

@implementation SchoolClassCell

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


- (void)bindSchoolClass:(SchoolClass *)class isAcademicClass:(BOOL)isClass
{
    [[self classNameLabel] setText:[class className]];
    [[self classTimeLabel] setText:[class classTime]];
    
    if (!isClass) {
        [[self classNameLabel] setTextColor:[UIColor schoolColor]];
    } else [[self classNameLabel] setTextColor:[UIColor blackColor]];
}

@end
