//
//  AnnouncementsTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnouncementsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawerButton;
- (IBAction)toggleMainMenu:(id)sender;

@end
