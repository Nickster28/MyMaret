//
//  AppDelegate.h
//  MyMaret
//
//  Created by Nick Troccoli on 7/28/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const MyMaretIsLoggedInKey;
extern NSString * const MyMaretUserEmailKey;
extern NSString * const MyMaretUserNameKey;
extern NSString * const MyMaretNewAnnouncementNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
