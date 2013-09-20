//
//  UIViewController+NavigationBarColor.h
//  MyMaret
//
//  Created by Nick Troccoli on 9/20/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationBarColor)

// Sets the caller's navigation bar to the appropriate
// color (depending on what version of iOS the user has)
- (void)configureNavigationBarColor;

@end
