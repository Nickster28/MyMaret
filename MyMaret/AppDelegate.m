//
//  AppDelegate.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/28/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AnnouncementsStore.h"

NSString * const MyMaretIsFirstOpenKey = @"MyMaretIsFirstOpenKey";
NSString * const MyMaretNewAnnouncementNotification = @"MyMaretNewAnnouncementNotification";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up Parse
    [Parse setApplicationId:@"9HFg8b0VNdu68bNj0XGW4zhQS2JJuJyeV8DlCFge"
                  clientKey:@"LsKBiPVVNUD8QxTWTr4QI4OJvIy92mWaknqYlsns"];
    
    // Track app usage
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    // Change the status bar on iOS 6 to not be tinted
    // Thanks to http://stackoverflow.com/questions/4456474/how-to-change-the-color-of-status-bar
    if ([UIApplication isPrevIOS]) [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE]
                                                         forKey:MyMaretIsFirstOpenKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    return YES;
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MyMaretNewAnnouncementNotification
                                                        object:nil];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
