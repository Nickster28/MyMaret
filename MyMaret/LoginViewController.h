//
//  LoginViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *splashBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *splashLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *loginTitleImageView;

- (IBAction)showLoginScreen:(id)sender;

@end
