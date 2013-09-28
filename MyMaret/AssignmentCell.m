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
  shouldDisplayDueTime:(BOOL)shouldDisplayDueTime shouldDisplayClass:(BOOL)shouldDisplayClass
{
    [[self assignmentLabel] setText:[assignment assignmentName]];
    
    // Only display the class if we're supposed to
    if (shouldDisplayClass) {
        [[self subtitleLabel] setText:[assignment className]];
    } else [[self subtitleLabel] setText:@""];
    
    // Set the image of the button to not completed
    [[self markCompletedButton] setImage:[UIImage imageNamed:@"assignmentNotCompletedIcon"] forState:UIControlStateNormal];
    
    // Display the appropriate due time/date
    if (shouldDisplayDueTime) {
        [[self dueLabel] setText:[NSString stringWithFormat:@"Due: %@", [assignment dueTimeAsString]]];
    } else [[self dueLabel] setText:[NSString stringWithFormat:@"Due: %@", [assignment dueDateAsString]]];
}


- (IBAction)markAssignmentAsCompleted:(UIButton *)sender
{
    [sender setImage:[UIImage imageNamed:@"assignmentCompletedIcon"]
            forState:UIControlStateNormal];
    
    [self.delegate assignmentCellwasMarkedAsCompleted:self];
}

@end
