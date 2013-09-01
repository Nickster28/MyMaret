//
//  PushNotificationUpdateable.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/31/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

// A protocol for view controllers displaying content that may be
// notified of updates by push notifications
@protocol PushNotificationUpdateable <NSObject>

// Tells the view controller it should refresh its contents after appearing
- (void)reloadWhenShown;

@end
