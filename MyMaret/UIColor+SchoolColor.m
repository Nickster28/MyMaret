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
    return [UIColor colorWithRed:16.0/255.0
                           green:105.0/255.0
                            blue:53.0/255.0
                           alpha:1.0];
}


+ (UIColor *)schoolLightColor
{
    return [UIColor colorWithRed:16.0/255.0
                           green:170.0/255.0
                            blue:53.0/255.0
                           alpha:1.0];
}


+ (UIColor *)schoolComplementaryColor
{
    return [UIColor colorWithRed:181.0/255.0
                           green:129.0/255.0
                            blue:13.0/255.0
                           alpha:1.0];
}
@end
