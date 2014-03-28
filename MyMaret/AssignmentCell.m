//
//  AssignmentCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/27/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentCell.h"
#import "Assignment.h"
#import "UIColor+SchoolColor.h"

@implementation AssignmentCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)bindAssignment:(Assignment *)assignment
  shouldDisplayDueTime:(BOOL)shouldDisplayDueTime shouldDisplayClass:(BOOL)shouldDisplayClass
{
    
    [[self assignmentLabel] setText:[assignment assignmentName]];
    
    // Only display the class if we're supposed to
    [[self subtitleLabel] setText:[assignment className]];

    
    // Set the image of the button to completed or not completed
    if ([assignment isCompleted]) {
        [[self markCompletedButton] setImage:[UIImage imageNamed:@"assignmentCompletedIcon"] forState:UIControlStateNormal];
        [self setIsChecked:true];
    } else {
        [[self markCompletedButton] setImage:[UIImage imageNamed:@"assignmentNotCompletedIcon"] forState:UIControlStateNormal];
        [self setIsChecked:false];
    }
    
    // Display the appropriate due time/date by making "Due:" in black, and the due date/time in green
    NSMutableAttributedString *attrString;
    if (shouldDisplayDueTime) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Due: %@", [assignment dueTimeString]]];
    } else {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Due: %@", [assignment dueDateAsString]]];
    }
    

    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, 4)];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor schoolBarColor]
                       range:NSMakeRange(4, attrString.length - 4)];
    
    [[self dueLabel] setAttributedText:attrString];
    
    
    
    // Configure the swipe right action
    // Thanks to alikaragoz and his MCSwipeTableViewCell demo code for help implementing this
    
    // Set the view appearance
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        self.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self setDefaultColor:[UIColor lightSchoolColor]];
    
    
    UIImage *turnInImage = [UIImage imageNamed:@"TurnInLogo"];
    UIImageView *turnInImageView = [[UIImageView alloc] initWithImage:turnInImage];
    [turnInImageView setContentMode:UIViewContentModeCenter];
    
    // Make a weak pointer to self so we don't have a retain cycle
    AssignmentCell * __weak weakSelf = self;
    
    // Notify our assignment state delegate when the user swipes the assignment to the right
    [self setSwipeGestureWithView:turnInImageView
                            color:[UIColor lightSchoolColor]
                             mode:MCSwipeTableViewCellModeExit
                            state:MCSwipeTableViewCellState1
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
                      [weakSelf.assignmentStateDelegate deleteAssignmentCell:weakSelf];
        
    }];
    
}


- (IBAction)changeAssignmentCompletion:(UIButton *)sender
{
    if (![self isChecked]) {
        [sender setImage:[UIImage imageNamed:@"assignmentCompletedIcon"]
                forState:UIControlStateNormal];
        
        [self.assignmentStateDelegate setAssignmentCell:self asCompleted:true];
        [self setIsChecked:true];
    } else {
        [sender setImage:[UIImage imageNamed:@"assignmentNotCompletedIcon"]
                forState:UIControlStateNormal];
        
        [self.assignmentStateDelegate setAssignmentCell:self asCompleted:false];
        [self setIsChecked:false];
    }
}

@end
