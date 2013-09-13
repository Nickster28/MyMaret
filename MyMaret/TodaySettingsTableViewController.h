//
//  TodaySettingsTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TodayTableViewController.h"

@interface TodaySettingsTableViewController : UITableViewController
@property (nonatomic, weak) id <TodayIndexSetterDelegate> delegate;
@end
