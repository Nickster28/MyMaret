//
//  UIColor+SchoolColor.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/12/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "UIColor+SchoolColor.h"

@implementation UIColor (SchoolColor)
+ (UIColor *)schoolColor
{
    return [UIColor colorWithRed:16.0/255.0 // 16
                           green:140.0/255.0 // 105
                            blue:58.0/255.0 // 53
                           alpha:1.0];
}


+ (UIColor *)schoolComplementaryColor
{
    return [UIColor colorWithRed:200.0/255.0
                           green:129.0/255.0
                            blue:13.0/255.0
                           alpha:1.0];
}


+ (UIColor *)schoolBarColor
{
    return [UIColor colorWithRed:16.0/255.0 // 16
                           green:140.0/255.0 // 140
                            blue:58.0/255.0 // 53
                           alpha:1.0];
}

@end
