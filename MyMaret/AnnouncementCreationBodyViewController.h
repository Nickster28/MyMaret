//
//  AnnouncementCreationBodyViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnouncementCreationBodyViewController : UIViewController <UITextViewDelegate>

// Made bodyTextView instead of a UITextField because only text views are multi-line
// Thanks to http://stackoverflow.com/questions/1345561/how-to-create-a-multiline-uitextfield
// For suggesting a UITextView
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

// The title, which is set by another view controller
@property (nonatomic, strong) NSString *announcementTitle;

- (IBAction)postAnnouncement:(id)sender;

@end
