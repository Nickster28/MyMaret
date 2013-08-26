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

@interface LoginViewController () <NSURLConnectionDataDelegate>

// The data returned from Google with the user info
@property (nonatomic, strong) NSMutableData *JSONData;

@end

// The school domain to compare with logged in user's domains
NSString * const schoolDomain = @"maret.org";


@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Generic method to show an alert view with a given title and message
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}


- (IBAction)showLoginScreen:(id)sender
{
    if (![UIApplication hasNetworkConnection]) {
        [self showAlertWithTitle:@"Heads Up!" message:@"Looks like you're not connected to the Internet.  You'll need an Internet connection to log in.  Make sure your WiFi or Cellular connection is on and try again."];
        return;
    }
    
    NSString *kMyClientID = @"410380053411.apps.googleusercontent.com";     // pre-assigned by service
    NSString *kMyClientSecret = @"TAe_CZfuirnBZgK71bssoOca"; // pre-assigned by service
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.email"; // scope for Google user info API
    
    // Thanks to http://stackoverflow.com/questions/13859068/calling-arc-method-from-non-arc-code
    // for reminding me that ARC simply fills in retains/releases - so if I want to use non-ARC
    // code here I should just get rid of the autorelese on viewController.
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:kMyClientID
                                                            clientSecret:kMyClientSecret
                                                        keychainItemName:nil
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    
    // If the user completed login and there is an error
    if (error != nil && [error code] != -1000) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"Hold up!  Looks like Google couldn't verify your login info.  Try logging in again.  Error: %@", [error localizedDescription]];
        
        [self showAlertWithTitle:@"Whoops!" message:errorMessage];
        
    // If the user didn't complete login
    } else if (error != nil) {
        
        NSString *errorMessage = @"In order to use MyMaret, you need to log in with your Maret username and password.  That way we can identify you and only give you access to Maret information if you are a Maret student or teacher.";
        
        [self showAlertWithTitle:@"Please Log In" message:errorMessage];
        
    } else {
        // Authentication succeeded, so get the user's info
        [self getUserInfoWithAuth:auth];
    }
}


- (void)getUserInfoWithAuth:(GTMOAuth2Authentication *)auth
{
    // Authorize a request to Google to get the logged in user's info
    NSURL *googleUserInfoURL = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v3/userinfo"];
    NSMutableURLRequest *urlReq = [[NSMutableURLRequest alloc] initWithURL:googleUserInfoURL];
    
    [auth authorizeRequest:urlReq completionHandler:^(NSError *error) {
        if (!error) {
            
            // Clear our data object
            self.JSONData = [[NSMutableData alloc] init];
            
            // Connect to Google to get the user's info
            // Thanks to http://stackoverflow.com/questions/10080216/request-with-nsurlrequest
            // for reminding me to put the NSURLRequest in an NSURLConnection!
            __unused NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlReq
                                                                             delegate:self
                                                                     startImmediately:YES];
            
        } else {
            
            NSString *errorMessage = [NSString stringWithFormat:@"Hold up!  Looks like Google couldn't verify your login info.  Try logging in again.  Error: %@", [error localizedDescription]];
            
            [self showAlertWithTitle:@"Whoops!" message:errorMessage];
        }
    }];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Add the incoming data to our JSONData object
    [self.JSONData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Convert the JSON data to a dictionary
    NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:
                              [self JSONData] options:0 error:nil];
    
    [self setUserInfo:JSONDict];
    
    // Clear our data object
    self.JSONData = [[NSMutableData alloc] init];
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setJSONData:nil];
    
    [self showAlertWithTitle:@"Whoops!" message:@"Looks like we couldn't authenticate with Google.  Try logging in again."];
}


- (void)setUserInfo:(NSDictionary *)userInfoDictionary
{
    // JSON KEYS:
    // email_verified -> boolean
    // email -> string
    // sub -> string
    // hd -> string
    NSString *domain = [userInfoDictionary objectForKey:@"hd"];
    if (![domain isEqualToString:schoolDomain]) {
        
        // Only allow Maret students and teachers to log in
        [self showAlertWithTitle:@"Sorry"
                         message:@"In order to use MyMaret you have to log in with a Maret username and password.  Please try again."];
    } else {
        // Store the user's info and mark them as logged in
        NSString *userEmail = [userInfoDictionary objectForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:userEmail
                                                  forKey:MyMaretUserEmailKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:MyMaretIsLoggedInKey];
        
        [[self presentingViewController] dismissViewControllerAnimated:YES
                                                            completion:nil];
    }
}

@end
