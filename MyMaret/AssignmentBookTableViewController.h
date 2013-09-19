//
//  AssignmentBookTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/9/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "MyMaretFrontTableViewController.h"

@class AssignmentCreationTableViewController;

@interface AssignmentBookTableViewController : MyMaretFrontTableViewController
@end



@protocol AssignmentCreationDismisserDelegate

// If the view controller cancelled their creation
- (void)assignmentCreationTableViewControllerDidCancelAssignmentCreation:(AssignmentCreationTableViewController *)creationTVC;

// If the view controller successfully created an assignment
- (void)assignmentCreationTableViewControllerDidCreateAssignment:(AssignmentCreationTableViewController *)creationTVC;

@end
