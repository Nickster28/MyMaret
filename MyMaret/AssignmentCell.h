//
//  AssignmentCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/27/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Assignment;
@protocol AssignmentCompletionProtocol;

@interface AssignmentCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *assignmentLabel;
@property (nonatomic, strong) IBOutlet UILabel *dueLabel;
@property (nonatomic, strong) IBOutlet UIButton *markCompletedButton;

// We tell the delegate when we've been marked as completed
@property (nonatomic, weak) id<AssignmentCompletionProtocol> delegate;



// Binds the given assignment to our cell.  If shouldDisplayDueTime is true,
// the time the assignment is due is put on the right.  Otherwise, the due date
// is displayed there.  If shouldDisplayClass is true, the class name is included
- (void)bindAssignment:(Assignment *)assignment shouldDisplayDueTime:(BOOL)shouldDisplayDueTime shouldDisplayClass:(BOOL)shouldDisplayClass;

- (IBAction)markAssignmentAsCompleted:(UIButton *)sender;

@end


@protocol AssignmentCompletionProtocol

// Called by the cell to tell its delegate that the assignment is completed
- (void)assignmentCellwasMarkedAsCompleted:(AssignmentCell *)cell;

@end