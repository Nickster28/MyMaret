//
//  UIViewController+NavigationBarColor.m
//  MyMaret
//
//  Created by Nick Troccoli on 9/20/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "UIViewController+NavigationBarColor.h"
#import "UIApplication+iOSVersionChecker.h"
#import "UIColor+SchoolColor.h"


@implementation UIViewController (NavigationBarColor)


- (void)configureNavigationBarColor
{
    NSAssert(self.navigationController, @"Must have a navigation controller to set the NavigationBar color!");
    
    // If we're on iOS 7, make the bar translucent green and white
    // for iOS 6, make the bar green
    if ([UIApplication isPrevIOS]) {
        [self.navigationController.navigationBar setTintColor:[UIColor schoolDarkColor]];
    } else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor schoolColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTranslucent:NO];
        
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
}


@end
