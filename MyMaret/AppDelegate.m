//
//  AppDelegate.m
//  MyMaret
//
//  Created by Nick Troccoli on 7/28/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//
// Thanks to http://stackoverflow.com/questions/13780153/uicollectionview-animate-cell-size-change-on-selection for making sure I use __weak when I call cellForRowAtIndexPath (since the cells are already
// onscreen!)

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AnnouncementsStore.h"
#import "UIColor+SchoolColor.h"

// NSUserDefaults keys
NSString * const MyMaretIsLoggedInKey = @"MyMaretIsLoggedInKey";
NSString * const MyMaretUserEmailKey = @"MyMaretUserEmailKey";
NSString * const MyMaretUserNameKey = @"MyMaretUserNameKey";
NSString * const MyMaretUserGradeKey = @"MyMaretUserGradeKey";

// NSNotificationCenter keys
NSString * const MyMaretNewAnnouncementNotification = @"MyMaretNewAnnouncementNotification";
NSString * const MyMaretNewNewspaperNotification = @"MyMaretNewNewspaperNotification";

// Push Notification keys
NSString * const MyMaretPushNotificationTypeKey = @"MyMaretnotificationtype";
NSString * const MyMaretPushNotificationTypeAnnouncement = @"announcement";
NSString * const MyMaretPushNotificationTypeNewspaper = @"newspaper";



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set the initial values for the user info keys
    NSDictionary *defaults = @{MyMaretIsLoggedInKey: [NSNumber numberWithBool:NO],
                               MyMaretUserEmailKey: @"",
                               MyMaretUserNameKey: @"",
                               MyMaretUserGradeKey: [NSNumber numberWithInt:0]
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    // Only set up Parse if the user is logged in (otherwise we do this after the
    // user logs in)
    if ([[NSUserDefaults standardUserDefaults] boolForKey:MyMaretIsLoggedInKey]) {
        // Set up Parse
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"parseCredentials" ofType:@"plist"]];
        NSString *applicationId = [dictionary objectForKey:@"parseApplicationId"];
        NSString *clientKey = [dictionary objectForKey:@"parseClientKey"];
        
        [Parse setApplicationId:applicationId
                      clientKey:clientKey];
        
        // Register for push notifications
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
        // Track app usage
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
        // Make sure the badge is in line with the number of unread announcements
        [[PFInstallation currentInstallation] setBadge:[[AnnouncementsStore sharedStore] numberOfUnreadAnnouncements]];
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    return YES;
}



- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive) {
        // The app was already running, so let Parse present it
        [PFPush handlePush:userInfo];
    } else {
        // The app was brought to the foreground from the background
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    NSString *MyMaretNotificationType = [userInfo objectForKey:MyMaretPushNotificationTypeKey];
    
    
    // Post a new NSNotification so that we can route the user to the
    // correct app section depending on the notification
    if ([MyMaretNotificationType isEqualToString:MyMaretPushNotificationTypeAnnouncement]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MyMaretNewAnnouncementNotification object:nil userInfo:nil];
        
        // Decrement the badge count since the user opened the app via the
        // notification
        [[PFInstallation currentInstallation] setBadge:[[PFInstallation currentInstallation] badge] - 1];
        [[PFInstallation currentInstallation] saveInBackground];
        
    } else if ([MyMaretNotificationType isEqualToString:MyMaretPushNotificationTypeNewspaper]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MyMaretNewNewspaperNotification object:nil userInfo:nil];
    }
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
