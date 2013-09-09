//
//  ClassScheduleTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretFrontTableViewController.h"
#import <UIKit/UIKit.h>

@class SchoolClassEditTableViewController;

@interface ClassScheduleTableViewController : MyMaretFrontTableViewController
@end

@protocol ClassEditDismisserDelegate

// If the view controller cancelled their creation
- (void)schoolClassEditTableViewControllerDidCancelClassCreation:(SchoolClassEditTableViewController *)editTVC;

// If the view controller successfully created/updated a class
- (void)schoolClassEditTableViewController:(SchoolClassEditTableViewController *)editTVC
                 didUpdateClassAtIndexPath:(NSIndexPath *)updatedIP;
- (void)schoolClassEditTableViewController:(SchoolClassEditTableViewController *)editTVC didCreateNewClassForSection:(NSUInteger)section;

@end
