//
//  AssignmentCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/27/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AssignmentCell.h"
#import "Assignment.h"

@implementation AssignmentCell

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



- (void)bindAssignment:(Assignment *)assignment
  shouldDisplayDueTime:(BOOL)shouldDisplayDueTime
{
    [[self assignmentLabel] setText:[assignment assignmentName]];
    [[self subtitleLabel] setText:[assignment className]];
    
    // Set the image of the button to not completed
    [[self markCompletedButton] setImage:[UIImage imageNamed:@"assignmentNotCompletedIcon"] forState:UIControlStateNormal];
    
    // Display the appropriate due time/date
    if (shouldDisplayDueTime) {
        [[self dueLabel] setText:[assignment dueTimeAsString]];
    } else [[self dueLabel] setText:[assignment dueDateAsString]];
}


- (IBAction)markAssignmentAsCompleted:(UIButton *)sender
{
    [sender setImage:[UIImage imageNamed:@"assignmentCompletedIcon"]
            forState:UIControlStateNormal];
    
    [self.delegate assignmentCellwasMarkedAsCompleted:self];
}

@end
