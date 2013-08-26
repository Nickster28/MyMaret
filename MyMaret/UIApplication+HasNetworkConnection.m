//
//  UIApplication+hasNetworkConnection.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/25/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "UIApplication+HasNetworkConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation UIApplication (HasNetworkConnection)


+ (BOOL)hasNetworkConnection
{
    // Thanks to http://shoe.bocks.com/net/#socket for help with the hostname
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "google.com");
    
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) return false;
    
    // Make sure the flags indicate we have a working connection
    return (flags & kSCNetworkReachabilityFlagsReachable);
}

@end
