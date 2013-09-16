//
//  AssignmentCreationTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/15/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AssignmentClassChooserTableViewController;


// The delegate protocol used to communicate between the class chooser
// and the main creation screen
@protocol ClassChooserDelegate <NSObject>

- (void)assignmentClassChooserTableViewController:(AssignmentClassChooserTableViewController *)chooserTVC didSelectClassWithName:(NSString *)name;

@end


@interface AssignmentCreationTableViewController : UITableViewController <ClassChooserDelegate>
@end
