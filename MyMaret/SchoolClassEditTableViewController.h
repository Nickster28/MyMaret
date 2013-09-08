//
//  SchoolClassEditTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SchoolClass;

@interface SchoolClassEditTableViewController : UITableViewController
@property (nonatomic, strong) SchoolClass *selectedClass;
@end
