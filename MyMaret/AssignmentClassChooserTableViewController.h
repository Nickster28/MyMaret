//
//  AssignmentClassChooserTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/16/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClassChooserDelegate;

@interface AssignmentClassChooserTableViewController : UITableViewController
@property (nonatomic, strong) NSString *selectedClassName;
@property (nonatomic, weak) id <ClassChooserDelegate> delegate;
@end
