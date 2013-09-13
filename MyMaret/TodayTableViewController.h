//
//  TodayTableViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/8/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMaretFrontTableViewController.h"

@class TodaySettingsTableViewController;

@interface TodayTableViewController : MyMaretFrontTableViewController

@end


@protocol TodayIndexSetterDelegate

- (void)todaySettingsTableViewControllerDidOverrideTodayDayIndex:(TodaySettingsTableViewController *)settingsTVC;

@end