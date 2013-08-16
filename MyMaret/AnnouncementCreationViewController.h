//
//  AnnouncementCreationViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/13/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnouncementCreationViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

// Made bodyTextView instead of a UITextField because only text views are multi-line
// Thanks to http://stackoverflow.com/questions/1345561/how-to-create-a-multiline-uitextfield
// For suggesting a UITextView and also "fake" placeholder text since UITextViews don't have it by default
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *bodyPlaceholderText;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

- (IBAction)postAnnouncement:(id)sender;
- (IBAction)cancelAnnouncement:(id)sender;
@end
