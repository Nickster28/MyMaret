//
//  AnnouncementCreationTitleViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnouncementCreationTitleViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

- (IBAction)cancelAnnouncement:(id)sender;
- (IBAction)nextAnnouncementCreationScreen:(id)sender;


@end
