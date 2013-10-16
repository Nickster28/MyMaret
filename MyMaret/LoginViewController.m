//
//  LoginViewController.m
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import "LoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "UIApplication+HasNetworkConnection.h"
#import "AppDelegate.h"
#import "UIApplication+iOSVersionChecker.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+NavigationBarColor.h"


@interface LoginViewController ()
@end

NSString * const LoginStatusLaunch = @"LoginStatusLaunch";
NSString * const LoginStatusCancel = @"LoginStatusCancel";
NSString * const LoginStatusLogout = @"LoginStatusLogout";
NSString * const LoginStatusInvalidAccount = @"LoginStatusInvalidAccount";
NSString * const LoginStatusLoginError = @"LoginStatusLoginError";


@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Configure the nav bar color (UIViewController category)
    [self configureNavigationBarColor];
    
    CGFloat height = [(UIWindow *)[UIApplication sharedApplication].windows[0] bounds].size.height;
    
    // Set the images depending on the device and OS
    if ([UIApplication isPrevIOS] && height > 480.0) {
        
        [self.splashBackgroundImageView setImage:[UIImage imageNamed:@"SplashBackground4-6"]];
        
        [self.splashLogoImageView setImage:[UIImage imageNamed:@"SplashLogo4-6"]];
        
    } else if ([UIApplication isPrevIOS]) {
        
        [self.splashBackgroundImageView setImage:[UIImage imageNamed:@"SplashBackground35-6"]];
        
        [self.splashLogoImageView setImage:[UIImage imageNamed:@"SplashLogo35-6"]];
        
    } else if (height > 480.0) {
        
        [self.splashBackgroundImageView setImage:[UIImage imageNamed:@"SplashBackground4-7"]];
        
        [self.splashLogoImageView setImage:[UIImage imageNamed:@"SplashLogo4-7"]];
        
    } else {
        
        [self.splashBackgroundImageView setImage:[UIImage imageNamed:@"SplashBackground35-7"]];
        
        [self.splashLogoImageView setImage:[UIImage imageNamed:@"SplashLogo35-7"]];
    }
    
    // We only manipulate the splash logo on launch
    if ([self.loginStatus isEqualToString:LoginStatusLaunch])
        self.splashLogoImageView.layer.opacity = 1.0;
    else self.splashLogoImageView.layer.opacity = 0.0;
    
    
    // If they didn't cancel or run into any errors,
    // prep for animation of the title and login button
    // Otherwise, don't animate
    if ([self.loginStatus isEqualToString:LoginStatusLaunch] ||
        [self.loginStatus isEqualToString:LoginStatusLogout]) {
        
        [self setInitialViewSettings];
        
    } else {
        [self.loginTitleImageView.layer setPosition:CGPointMake(160.0, 100.0)];
        [self.loginButton.layer setPosition:CGPointMake(160.0, 389)];
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the nav bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // For launching, we want to fade the splash logo
    // and animate in the title and login button
    if ([self.loginStatus isEqualToString:LoginStatusLaunch]) {
        [self fadeSplashLogo];
        
    // For logging out, we want to only animate in the title
    // and login button
    } else if ([self.loginStatus isEqualToString:LoginStatusLogout]) {
        [self animateInTitleAndLoginButton];
    }
}



- (void)setInitialViewSettings
{
    //Set the title and button's initial position and opacity
    [self.loginTitleImageView.layer setPosition:CGPointMake(160.0, 50.0)];
    [self.loginButton.layer setPosition:CGPointMake(160.0, 439)];
    
    [self.loginTitleImageView.layer setOpacity:0.0];
    [self.loginButton.layer setOpacity:0.0];
}


- (void)fadeSplashLogo
{
    // Fade away
    CABasicAnimation *fader = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fader setDuration:1.0];
    [fader setFromValue:[NSNumber numberWithFloat:1.0]];
    [fader setToValue:[NSNumber numberWithFloat:0.0]];
    [fader setDelegate:self];
    
    [self.splashLogoImageView.layer setOpacity:0.0];
    
    [self.splashLogoImageView.layer addAnimation:fader
                                          forKey:@"fade"];
}


// Called when the splash logo's fade is done
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // Now animate in the title and login button
    [self animateInTitleAndLoginButton];
}


- (void)animateInTitleAndLoginButton
{
    // Fade away
    CABasicAnimation *fader = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fader setDuration:1.0];
    [fader setFromValue:[NSNumber numberWithFloat:0.0]];
    [fader setToValue:[NSNumber numberWithFloat:1.0]];
    
    
    // Move the title down
    CABasicAnimation *titleMover = [CABasicAnimation animationWithKeyPath:@"position"];
    [titleMover setDuration:1.0];
    [titleMover setFromValue:[NSValue valueWithCGPoint:CGPointMake(160.0, 50.0)]];
    [titleMover setToValue:[NSValue valueWithCGPoint:CGPointMake(160.0, 100.0)]];
    [titleMover setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    
    // Move the login button up
    CABasicAnimation *loginButtonMover = [CABasicAnimation animationWithKeyPath:@"position"];
    [loginButtonMover setDuration:1.0];
    [loginButtonMover setFromValue:[NSValue valueWithCGPoint:CGPointMake(160.0, 439.0)]];
    [loginButtonMover setToValue:[NSValue valueWithCGPoint:CGPointMake(160.0, 389.0)]];
    [loginButtonMover setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    
    // Combine the two animations for the title
    CAAnimationGroup *titleGroup = [[CAAnimationGroup alloc] init];
    [titleGroup setAnimations:@[fader, titleMover]];
    [titleGroup setDuration:1.0];
    
    // Combine the two animations for the button
    CAAnimationGroup *loginButtonGroup = [[CAAnimationGroup alloc] init];
    [loginButtonGroup setAnimations:@[fader, loginButtonMover]];
    [loginButtonGroup setDuration:1.0];
    
    
    // Wait 1/2 second after the splash logo is done animating
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // Set the model layers' position and opacity
        [self.loginTitleImageView.layer setPosition:CGPointMake(160.0, 100.0)];
        [self.loginTitleImageView.layer setOpacity:1.0];
        
        [self.loginButton.layer setPosition:CGPointMake(160.0, 389.0)];
        [self.loginButton.layer setOpacity:1.0];
        
        
        // Perform the animations!
        [self.loginTitleImageView.layer addAnimation:titleGroup
                                              forKey:@"titleAnimations"];
        [self.loginButton.layer addAnimation:loginButtonGroup
                                      forKey:@"loginButtonAnimations"];
    });

}



#pragma mark Google Login and Authentication

- (IBAction)showLoginScreen:(id)sender
{
    if (![UIApplication hasNetworkConnection]) {
        NSString *errorMsg = @"Looks like you're not connected to the Internet.  You'll need an Internet connection to log in.  Make sure your WiFi or Cellular connection is on and try again.";
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                     message:errorMsg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    NSString *kMyClientID = @"41307471062.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"pCkySyz5CPUH-rsMvygfXC5K"; // pre-assigned by service
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.email"; // scope for Google user info API
    
    // Thanks to http://stackoverflow.com/questions/13859068/calling-arc-method-from-non-arc-code
    // for reminding me that ARC simply fills in retains/releases - so if I want to use non-ARC
    // code here I should just get rid of the autorelese on viewController.
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:kMyClientID
                                                            clientSecret:kMyClientSecret
                                                        keychainItemName:nil
                                                                delegate:nil
                                                        finishedSelector:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}






@end
