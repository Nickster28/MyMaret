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
    [[self subtitleLabel] setText:[assignment className]];

    
    // Set the image of the button to not completed
    [[self markCompletedButton] setImage:[UIImage imageNamed:@"assignmentNotCompletedIcon"] forState:UIControlStateNormal];
    
    // Display the appropriate due time/date
    NSMutableAttributedString *attrString;
    if (shouldDisplayDueTime) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Due: %@", [assignment dueTimeAsString]]];
    } else {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Due: %@", [assignment dueDateAsString]]];
    }
    

    self.titleAttrString addAttribute:NSForegroundColorAttributeName
value:[UIColor schoolComplementaryColor]
range:NSMakeRange(0, 19)];
    
    [self.titleAttrString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor blackColor]
                                 range:NSMakeRange(19, self.titleAttrString.length - 19)];
    
}


- (IBAction)markAssignmentAsCompleted:(UIButton *)sender
{
    [sender setImage:[UIImage imageNamed:@"assignmentCompletedIcon"]
            forState:UIControlStateNormal];
    
    [self.delegate assignmentCellwasMarkedAsCompleted:self];
}

@end
