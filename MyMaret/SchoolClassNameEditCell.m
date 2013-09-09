//
//  SchoolClassNameEditCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "SchoolClassNameEditCell.h"

@interface SchoolClassNameEditCell() <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, weak) IBOutlet UITextField *classNameTextField;
@end

@implementation SchoolClassNameEditCell

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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // If the user hits "Done", hide the keyboard
    [textField resignFirstResponder];
    return YES;
}


- (void)dismissKeyboard
{
    [self.classNameTextField resignFirstResponder];
}


- (void)setDisplayedClassName:(NSString *)className
{
    [[self classNameTextField] setText:className];
}


- (NSString *)enteredClassName
{
    return [[self classNameTextField] text];
}

@end
