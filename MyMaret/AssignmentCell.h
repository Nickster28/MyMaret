//
//  AssignmentCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/27/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@class Assignment;
@protocol AssignmentStateProtocol;

@interface AssignmentCell : MCSwipeTableViewCell;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *assignmentLabel;
@property (nonatomic, strong) IBOutlet UILabel *dueLabel;
@property (nonatomic, strong) IBOutlet UIButton *markCompletedButton;

// Keep track of whether or not the checkbox is already filled
@property (nonatomic) BOOL isChecked;

// We tell the delegate when the state (completed, deleted) of this assignment changes
@property (nonatomic, weak) id<AssignmentStateProtocol> assignmentStateDelegate;



// Binds the given assignment to our cell.  If shouldDisplayDueTime is true,
// the time the assignment is due is put on the right.  Otherwise, the due date
// is displayed there.  If shouldDisplayClass is true, the class name is included.
- (void)bindAssignment:(Assignment *)assignment
  shouldDisplayDueTime:(BOOL)shouldDisplayDueTime
    shouldDisplayClass:(BOOL)shouldDisplayClass;

- (IBAction)changeAssignmentCompletion:(UIButton *)sender;

@end


@protocol AssignmentStateProtocol

// Called by the cell to tell its delegate that the assignment is completed
- (void)setAssignmentCell:(AssignmentCell *)cell asCompleted:(BOOL)isCompleted;

// Called by the cell to tell its delegate that the assignment has been deleted
- (void)deleteAssignmentCell:(AssignmentCell *)cell;

@end