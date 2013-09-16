//
//  TextEditCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextEditCell : UITableViewCell

// Returns the current entered text in the text field
- (NSString *)enteredText;

// Sets the text in the text field to the given string
- (void)setDisplayedText:(NSString *)text;


// Dismiss the keyboard if it's visible for our text field
- (void)dismissKeyboard;

@end
