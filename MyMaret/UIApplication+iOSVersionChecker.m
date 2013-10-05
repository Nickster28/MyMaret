//
//  UIApplication+iOSVersionChecker.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/29/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "UIApplication+iOSVersionChecker.h"
#define CURRENT_IOS_MAJOR_VERSION 7

@implementation UIApplication (iOSVersionChecker)

+ (BOOL)isPrevIOS {
    
    // Get the number of the iOS version before the "."
    NSUInteger majorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    
    return majorVersion < CURRENT_IOS_MAJOR_VERSION;
}

@end
