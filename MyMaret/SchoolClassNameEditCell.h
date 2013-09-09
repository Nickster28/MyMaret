//
//  SchoolClassNameEditCell.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolClassNameEditCell : UITableViewCell

// Returns the current class name in the text field
- (NSString *)enteredClassName;

// Sets the class name to display in the text field
- (void)setDisplayedClassName:(NSString *)className;


// Dismiss the keyboard if it's visible for our text field
- (void)dismissKeyboard;

@end
