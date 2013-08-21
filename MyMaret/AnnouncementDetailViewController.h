//
//  AnnouncementDetailViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/19/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Announcement;

@interface AnnouncementDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

// The selected announcement to show
@property (nonatomic, strong) Announcement *announcement;


- (IBAction)emailAnnouncement:(id)sender;

@end
