//
//  TextEditCell.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "TextEditCell.h"

@interface TextEditCell() <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end

@implementation TextEditCell

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
    [self.textField resignFirstResponder];
}


- (void)showKeyboard
{
    [self.textField becomeFirstResponder];
}


- (void)setDisplayedText:(NSString *)text
{
    [[self textField] setText:text];
}


- (NSString *)enteredText
{
    return [[self textField] text];
}

@end
