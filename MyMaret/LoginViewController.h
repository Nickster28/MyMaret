//
//  LoginViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const LoginStatusLaunch;
extern NSString * const LoginStatusCancel;
extern NSString * const LoginStatusLogout;

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *splashBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *splashLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *loginTitleImageView;

// Tells us what animations to do
// (depending on where we are in the app)
@property (nonatomic, strong) NSString *loginStatus;

@end
