/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
// GTMOAuth2ViewControllerTouch.m
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES

#if TARGET_OS_IPHONE

#import "GTMOAuth2ViewControllerTouch.h"

#import "GTMOAuth2SignIn.h"
#import "GTMOAuth2Authentication.h"
#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import <Parse/Parse.h>
#import "ClassScheduleStore.h"
#import "AnnouncementsStore.h"
#import "NewspaperStore.h"
#import "AssignmentBookStore.h"
#import "LoginViewController.h"


NSString *const kGTMOAuth2KeychainErrorDomain = @"com.google.GTMOAuthKeychain";

// The school domain to compare with logged in user's domains
NSString * const schoolDomain = @"maret.org";

static NSString * const kGTMOAuth2AccountName = @"OAuth";
static GTMOAuth2Keychain* sDefaultKeychain = nil;

@interface GTMOAuth2ViewControllerTouch() <NSURLConnectionDataDelegate>

@property (nonatomic, copy) NSURLRequest *request;

// The data returned from Google with the user info
@property (nonatomic, strong) NSMutableData *JSONData;

- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request;
- (void)signIn:(GTMOAuth2SignIn *)signIn
finishedWithAuth:(GTMOAuth2Authentication *)auth
         error:(NSError *)error;
- (BOOL)isNavigationBarTranslucent;
- (void)moveWebViewFromUnderNavigationBar;
- (void)popView;
- (void)clearBrowserCookies;
@end

@implementation GTMOAuth2ViewControllerTouch

// IBOutlets
@synthesize request = request_,
            backButton = backButton_,
            forwardButton = forwardButton_,
            navButtonsView = navButtonsView_,
            rightBarButtonItem = rightBarButtonItem_,
            webView = webView_,
            initialActivityIndicator = initialActivityIndicator_,
            JSONData = JSONData_;

@synthesize keychainItemName = keychainItemName_,
            keychainItemAccessibility = keychainItemAccessibility_,
            initialHTMLString = initialHTMLString_,
            browserCookiesURL = browserCookiesURL_,
            signIn = signIn_,
            userData = userData_,
            properties = properties_;

#if NS_BLOCKS_AVAILABLE
@synthesize popViewBlock = popViewBlock_;
#endif

#if !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT
+ (id)controllerWithScope:(NSString *)scope
                 clientID:(NSString *)clientID
             clientSecret:(NSString *)clientSecret
         keychainItemName:(NSString *)keychainItemName
                 delegate:(id)delegate
         finishedSelector:(SEL)finishedSelector {
  return [[[self alloc] initWithScope:scope
                             clientID:clientID
                         clientSecret:clientSecret
                     keychainItemName:keychainItemName
                             delegate:delegate
                     finishedSelector:finishedSelector] autorelease];
}

- (id)initWithScope:(NSString *)scope
           clientID:(NSString *)clientID
       clientSecret:(NSString *)clientSecret
   keychainItemName:(NSString *)keychainItemName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector {
  // convenient entry point for Google authentication

  Class signInClass = [[self class] signInClass];

  GTMOAuth2Authentication *auth;
  auth = [signInClass standardGoogleAuthenticationForScope:scope
                                                  clientID:clientID
                                              clientSecret:clientSecret];
  NSURL *authorizationURL = [signInClass googleAuthorizationURL];
  return [self initWithAuthentication:auth
                     authorizationURL:authorizationURL
                     keychainItemName:keychainItemName
                             delegate:delegate
                     finishedSelector:finishedSelector];
}

#if NS_BLOCKS_AVAILABLE

+ (id)controllerWithScope:(NSString *)scope
                 clientID:(NSString *)clientID
             clientSecret:(NSString *)clientSecret
         keychainItemName:(NSString *)keychainItemName
        completionHandler:(GTMOAuth2ViewControllerCompletionHandler)handler {
  return [[[self alloc] initWithScope:scope
                             clientID:clientID
                         clientSecret:clientSecret
                     keychainItemName:keychainItemName
                    completionHandler:handler] autorelease];
}

- (id)initWithScope:(NSString *)scope
           clientID:(NSString *)clientID
       clientSecret:(NSString *)clientSecret
   keychainItemName:(NSString *)keychainItemName
  completionHandler:(GTMOAuth2ViewControllerCompletionHandler)handler {
  // convenient entry point for Google authentication

  Class signInClass = [[self class] signInClass];

  GTMOAuth2Authentication *auth;
  auth = [signInClass standardGoogleAuthenticationForScope:scope
                                                  clientID:clientID
                                              clientSecret:clientSecret];
  NSURL *authorizationURL = [signInClass googleAuthorizationURL];
  self = [self initWithAuthentication:auth
                     authorizationURL:authorizationURL
                     keychainItemName:keychainItemName
                             delegate:nil
                     finishedSelector:NULL];
  if (self) {
    completionBlock_ = [handler copy];
  }
  return self;
}

#endif // NS_BLOCKS_AVAILABLE
#endif // !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT

+ (id)controllerWithAuthentication:(GTMOAuth2Authentication *)auth
                  authorizationURL:(NSURL *)authorizationURL
                  keychainItemName:(NSString *)keychainItemName
                          delegate:(id)delegate
                  finishedSelector:(SEL)finishedSelector {
  return [[[self alloc] initWithAuthentication:auth
                              authorizationURL:authorizationURL
                              keychainItemName:keychainItemName
                                      delegate:delegate
                              finishedSelector:finishedSelector] autorelease];
}

- (id)initWithAuthentication:(GTMOAuth2Authentication *)auth
            authorizationURL:(NSURL *)authorizationURL
            keychainItemName:(NSString *)keychainItemName
                    delegate:(id)delegate
            finishedSelector:(SEL)finishedSelector {

  NSString *nibName = [[self class] authNibName];
  NSBundle *nibBundle = [[self class] authNibBundle];

  self = [super initWithNibName:nibName bundle:nibBundle];
  if (self != nil) {
    delegate_ = [delegate retain];
    finishedSelector_ = finishedSelector;

    Class signInClass = [[self class] signInClass];

    // use the supplied auth and OAuth endpoint URLs
    signIn_ = [[signInClass alloc] initWithAuthentication:auth
                                         authorizationURL:authorizationURL
                                                 delegate:self
                                       webRequestSelector:@selector(signIn:displayRequest:)
                                         finishedSelector:@selector(signIn:finishedWithAuth:error:)];

    // if the user is signing in to a Google service, we'll delete the
    // Google authentication browser cookies upon completion
    //
    // for other service domains, or to disable clearing of the cookies,
    // set the browserCookiesURL property explicitly
    NSString *authorizationHost = [signIn_.authorizationURL host];
    if ([authorizationHost hasSuffix:@".google.com"]) {
      NSString *urlStr = [NSString stringWithFormat:@"https://%@/",
                          authorizationHost];
      NSURL *cookiesURL = [NSURL URLWithString:urlStr];
      [self setBrowserCookiesURL:cookiesURL];
    }

    [self setKeychainItemName:keychainItemName];
  }
  return self;
}

#if NS_BLOCKS_AVAILABLE
+ (id)controllerWithAuthentication:(GTMOAuth2Authentication *)auth
                  authorizationURL:(NSURL *)authorizationURL
                  keychainItemName:(NSString *)keychainItemName
                 completionHandler:(GTMOAuth2ViewControllerCompletionHandler)handler {
  return [[[self alloc] initWithAuthentication:auth
                              authorizationURL:authorizationURL
                              keychainItemName:keychainItemName
                             completionHandler:handler] autorelease];
}

- (id)initWithAuthentication:(GTMOAuth2Authentication *)auth
            authorizationURL:(NSURL *)authorizationURL
            keychainItemName:(NSString *)keychainItemName
           completionHandler:(GTMOAuth2ViewControllerCompletionHandler)handler {
  // fall back to the non-blocks init
  self = [self initWithAuthentication:auth
                     authorizationURL:authorizationURL
                     keychainItemName:keychainItemName
                             delegate:nil
                     finishedSelector:NULL];
  if (self) {
    completionBlock_ = [handler copy];
  }
  return self;
}
#endif

- (void)dealloc {
  [webView_ setDelegate:nil];

  [backButton_ release];
  [forwardButton_ release];
  [initialActivityIndicator_ release];
  [navButtonsView_ release];
  [rightBarButtonItem_ release];
  [webView_ release];
  [signIn_ release];
  [request_ release];
  [delegate_ release];
#if NS_BLOCKS_AVAILABLE
  [completionBlock_ release];
  [popViewBlock_ release];
#endif
  [keychainItemName_ release];
  [initialHTMLString_ release];
  [browserCookiesURL_ release];
  [userData_ release];
  [properties_ release];

  [super dealloc];
}

+ (NSString *)authNibName {
  // subclasses may override this to specify a custom nib name
  return @"GTMOAuth2ViewTouch";
}

+ (NSBundle *)authNibBundle {
  // subclasses may override this to specify a custom nib bundle
  return nil;
}

#if !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT
+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret {
  return [self authForGoogleFromKeychainForName:keychainItemName
                                       clientID:clientID
                                   clientSecret:clientSecret
                                          error:NULL];
}

+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret
                                                        error:(NSError **)error {
  Class signInClass = [self signInClass];
  NSURL *tokenURL = [signInClass googleTokenURL];
  NSString *redirectURI = [signInClass nativeClientRedirectURI];

  GTMOAuth2Authentication *auth;
  auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kGTMOAuth2ServiceProviderGoogle
                                                           tokenURL:tokenURL
                                                        redirectURI:redirectURI
                                                           clientID:clientID
                                                       clientSecret:clientSecret];
  [[self class] authorizeFromKeychainForName:keychainItemName
                              authentication:auth
                                       error:error];
  return auth;
}

#endif

+ (BOOL)authorizeFromKeychainForName:(NSString *)keychainItemName
                      authentication:(GTMOAuth2Authentication *)newAuth
                               error:(NSError **)error {
  newAuth.accessToken = nil;

  BOOL didGetTokens = NO;
  GTMOAuth2Keychain *keychain = [GTMOAuth2Keychain defaultKeychain];
  NSString *password = [keychain passwordForService:keychainItemName
                                            account:kGTMOAuth2AccountName
                                              error:error];
  if (password != nil) {
    [newAuth setKeysForResponseString:password];
    didGetTokens = YES;
  }
  return didGetTokens;
}

+ (BOOL)removeAuthFromKeychainForName:(NSString *)keychainItemName {
  GTMOAuth2Keychain *keychain = [GTMOAuth2Keychain defaultKeychain];
  return [keychain removePasswordForService:keychainItemName
                                    account:kGTMOAuth2AccountName
                                      error:nil];
}

+ (BOOL)saveParamsToKeychainForName:(NSString *)keychainItemName
                     authentication:(GTMOAuth2Authentication *)auth {
  return [self saveParamsToKeychainForName:keychainItemName
                             accessibility:NULL
                            authentication:auth
                                     error:NULL];
}

+ (BOOL)saveParamsToKeychainForName:(NSString *)keychainItemName
                      accessibility:(CFTypeRef)accessibility
                     authentication:(GTMOAuth2Authentication *)auth
                              error:(NSError **)error {
  [self removeAuthFromKeychainForName:keychainItemName];
  // don't save unless we have a token that can really authorize requests
  if (![auth canAuthorize]) {
    if (error) {
      *error = [NSError errorWithDomain:kGTMOAuth2ErrorDomain
                                   code:kGTMOAuth2ErrorTokenUnavailable
                               userInfo:nil];
    }
    return NO;
  }

  if (accessibility == NULL
      && &kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly != NULL) {
    accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
  }

  // make a response string containing the values we want to save
  NSString *password = [auth persistenceResponseString];
  GTMOAuth2Keychain *keychain = [GTMOAuth2Keychain defaultKeychain];
  return [keychain setPassword:password
                    forService:keychainItemName
                 accessibility:accessibility
                       account:kGTMOAuth2AccountName
                         error:error];
}

- (void)loadView {
  NSString *nibPath = nil;
  NSBundle *nibBundle = [self nibBundle];
  if (nibBundle == nil) {
    nibBundle = [NSBundle mainBundle];
  }
  NSString *nibName = self.nibName;
  if (nibName != nil) {
    nibPath = [nibBundle pathForResource:nibName ofType:@"nib"];
  }
  if (nibPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:nibPath]) {
    [super loadView];
  } else {
    // One of the requirements of loadView is that a valid view object is set to
    // self.view upon completion. Otherwise, subclasses that attempt to
    // access self.view after calling [super loadView] will enter an infinite
    // loop due to the fact that UIViewController's -view accessor calls
    // loadView when self.view is nil.
    self.view = [[[UIView alloc] init] autorelease];

#if DEBUG
    NSLog(@"missing %@.nib", nibName);
#endif
  }
}


- (void)viewDidLoad {
  [self setUpNavigation];
}

- (void)setUpNavigation {
    /* NICK COMMENTED THIS OUT */
    //rightBarButtonItem_.customView = navButtonsView_;
    //self.navigationItem.rightBarButtonItem = rightBarButtonItem_;
}

- (void)popView {
#if NS_BLOCKS_AVAILABLE
  void (^popViewBlock)() = self.popViewBlock;
#else
  id popViewBlock = nil;
#endif

  if (popViewBlock || self.navigationController.topViewController == self) {
    if (!self.view.hidden) {
      // Set the flag to our viewWillDisappear method so it knows
      // this is a disappearance initiated by the sign-in object,
      // not the user cancelling via the navigation controller
      didDismissSelf_ = YES;

      if (popViewBlock) {
#if NS_BLOCKS_AVAILABLE
        popViewBlock();
        self.popViewBlock = nil;
#endif
      } else {
        [self.navigationController popViewControllerAnimated:YES];
      }
      self.view.hidden = YES;
    }
  }
}

- (void)notifyWithName:(NSString *)name
               webView:(UIWebView *)webView
                  kind:(NSString *)kind {
  BOOL isStarting = [name isEqual:kGTMOAuth2WebViewStartedLoading];
  if (hasNotifiedWebViewStartedLoading_ == isStarting) {
    // Duplicate notification
    //
    // UIWebView's delegate methods are so unbalanced that there's little
    // point trying to keep a count, as it could easily end up stuck greater
    // than zero.
    //
    // We don't really have a way to track the starts and stops of
    // subframe loads, too, as the webView in the notification is always
    // for the topmost request.
    return;
  }
  hasNotifiedWebViewStartedLoading_ = isStarting;

  // Notification for webview load starting and stopping
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        webView, kGTMOAuth2WebViewKey,
                        kind, kGTMOAuth2WebViewStopKindKey, // kind may be nil
                        nil];
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:name
                    object:self
                  userInfo:dict];
}

- (void)cancelSigningIn {
  // The application has explicitly asked us to cancel signing in
  // (so no further callback is required)
  hasCalledFinished_ = YES;

  [delegate_ autorelease];
  delegate_ = nil;

#if NS_BLOCKS_AVAILABLE
  [completionBlock_ autorelease];
  completionBlock_ = nil;
#endif

  // The sign-in object's cancel method will close the window
  [signIn_ cancelSigningIn];
  hasDoneFinalRedirect_ = YES;
}

static Class gSignInClass = Nil;

+ (Class)signInClass {
  if (gSignInClass == Nil) {
    gSignInClass = [GTMOAuth2SignIn class];
  }
  return gSignInClass;
}

+ (void)setSignInClass:(Class)theClass {
  gSignInClass = theClass;
}

#pragma mark Token Revocation

#if !GTM_OAUTH2_SKIP_GOOGLE_SUPPORT
+ (void)revokeTokenForGoogleAuthentication:(GTMOAuth2Authentication *)auth {
  [[self signInClass] revokeTokenForGoogleAuthentication:auth];
}
#endif

#pragma mark Browser Cookies

- (GTMOAuth2Authentication *)authentication {
  return self.signIn.authentication;
}

- (void)clearBrowserCookies {
  // if browserCookiesURL is non-nil, then get cookies for that URL
  // and delete them from the common application cookie storage
  NSURL *cookiesURL = [self browserCookiesURL];
  if (cookiesURL) {
    NSHTTPCookieStorage *cookieStorage;

    cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies =  [cookieStorage cookiesForURL:cookiesURL];

    for (NSHTTPCookie *cookie in cookies) {
      [cookieStorage deleteCookie:cookie];
    }
  }
}

#pragma mark Accessors

- (void)setNetworkLossTimeoutInterval:(NSTimeInterval)val {
  signIn_.networkLossTimeoutInterval = val;
}

- (NSTimeInterval)networkLossTimeoutInterval {
  return signIn_.networkLossTimeoutInterval;
}

- (BOOL)shouldUseKeychain {
  NSString *name = self.keychainItemName;
  return ([name length] > 0);
}

- (BOOL)showsInitialActivityIndicator {
  return (mustShowActivityIndicator_ == 1 || initialHTMLString_ == nil);
}

- (void)setShowsInitialActivityIndicator:(BOOL)flag {
  mustShowActivityIndicator_ = (flag ? 1 : -1);
}

#pragma mark User Properties

- (void)setProperty:(id)obj forKey:(NSString *)key {
  if (obj == nil) {
    // User passed in nil, so delete the property
    [properties_ removeObjectForKey:key];
  } else {
    // Be sure the property dictionary exists
    if (properties_ == nil) {
      [self setProperties:[NSMutableDictionary dictionary]];
    }
    [properties_ setObject:obj forKey:key];
  }
}

- (id)propertyForKey:(NSString *)key {
  id obj = [properties_ objectForKey:key];

  // Be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

#pragma mark SignIn callbacks

- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request {
  // This is the signIn object's webRequest method, telling the controller
  // to either display the request in the webview, or if the request is nil,
  // to close the window.
  //
  // All web requests and all window closing goes through this routine

#if DEBUG
  if (self.navigationController) {
    if (self.navigationController.topViewController != self && request != nil) {
      NSLog(@"Unexpected: Request to show, when already on top. request %@", [request URL]);
    } else if(self.navigationController.topViewController != self && request == nil) {
      NSLog(@"Unexpected: Request to pop, when not on top. request nil");
    }
  }
#endif

  if (request != nil) {
    const NSTimeInterval kJanuary2011 = 1293840000;
    BOOL isDateValid = ([[NSDate date] timeIntervalSince1970] > kJanuary2011);
    if (isDateValid) {
      // Display the request.
      self.request = request;
      // The app may prefer some html other than blank white to be displayed
      // before the sign-in web page loads.
      // The first fetch might be slow, so the client programmer may want
      // to show a local "loading" message.
      // On iOS 5+, UIWebView will ignore loadHTMLString: if it's followed by
      // a loadRequest: call, so if there is a "loading" message we defer
      // the loadRequest: until after after we've drawn the "loading" message.
      //
      // If there is no initial html string, we show the activity indicator
      // unless the user set showsInitialActivityIndicator to NO; if there
      // is an initial html string, we hide the indicator unless the user set
      // showsInitialActivityIndicator to YES.
      NSString *html = self.initialHTMLString;
      if ([html length] > 0) {
        [initialActivityIndicator_ setHidden:(mustShowActivityIndicator_ < 1)];
        [self.webView loadHTMLString:html baseURL:nil];
      } else {
        [initialActivityIndicator_ setHidden:(mustShowActivityIndicator_ < 0)];
        [self.webView loadRequest:request];
      }
    } else {
      // clock date is invalid, so signing in would fail with an unhelpful error
      // from the server. Warn the user in an html string showing a watch icon,
      // question mark, and the system date and time. Hopefully this will clue
      // in brighter users, or at least give them a clue when they report the
      // problem to developers.
      //
      // Even better is for apps to check the system clock and show some more
      // helpful, localized instructions for users; this is really a fallback.
      NSString *const html = @"<html><body><div align=center><font size='7'>"
        @"&#x231A; ?<br><i>System Clock Incorrect</i><br>%@"
        @"</font></div></body></html>";
      NSString *errHTML = [NSString stringWithFormat:html, [NSDate date]];

      [[self webView] loadHTMLString:errHTML baseURL:nil];
    }
  } else {
    // request was nil.
    //[self popView];
  }
}

- (void)signIn:(GTMOAuth2SignIn *)signIn
  finishedWithAuth:(GTMOAuth2Authentication *)auth
             error:(NSError *)error {
  if (!hasCalledFinished_) {
    hasCalledFinished_ = YES;

    if (error == nil) {
      if (self.shouldUseKeychain) {
        NSString *keychainItemName = self.keychainItemName;
        if (auth.canAuthorize) {
          // save the auth params in the keychain
          CFTypeRef accessibility = self.keychainItemAccessibility;
          [[self class] saveParamsToKeychainForName:keychainItemName
                                      accessibility:accessibility
                                     authentication:auth
                                              error:NULL];
        } else {
          // remove the auth params from the keychain
          [[self class] removeAuthFromKeychainForName:keychainItemName];
        }
      }
    }

    /*if (delegate_ && finishedSelector_) {
      SEL sel = finishedSelector_;
      NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation setSelector:sel];
      [invocation setTarget:delegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&auth atIndex:3];
      [invocation setArgument:&error atIndex:4];
      [invocation invoke];
    }*/
      
      
    // If the user completed login and there is an error
    if (error != nil && [error code] != -1000) {
        
        [self popView];
        
        NSString *errorMessage = [NSString stringWithFormat:@"Hold up!  Looks like Google couldn't verify your login info.  Try logging in again.  Error: %@", [error localizedDescription]];
          
        [self showAlertWithTitle:@"Whoops!" message:errorMessage];
          
    // If the user didn't complete login
    } else if (error != nil) {
        
        NSString *errorMessage = @"In order to use MyMaret, you need to log in with your Maret username and password.  That way we can identify you and only give you access to Maret information if you are a Maret student or teacher.";
        
        [self showAlertWithTitle:@"Please Log In"
                         message:errorMessage];
          
    } else {
        // Now set the user's info
        [self setUserInfo:auth.userEmail];
    }
      

    [delegate_ autorelease];
    delegate_ = nil;

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(self, auth, error);

      // release the block here to avoid a retain loop on the controller
      [completionBlock_ autorelease];
      completionBlock_ = nil;
    }
#endif
  }
}



#pragma mark Nick's added methods
/********* NICK'S ADDED CODE START **************/

// Generic method to show an alert view with a given title and message
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:title
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] autorelease];
    [av show];
}


- (void)setUserInfo:(NSString *)emailAddr
{
    // Make sure the user logged in with a school email address
    NSUInteger domainStart = [emailAddr rangeOfString:@"@"].location + 1;
    NSString *domain = [emailAddr substringFromIndex:domainStart];
    if (![domain isEqualToString:schoolDomain]) {
        
        [self popView];
        
        // Only allow Maret students and teachers to log in
        [self showAlertWithTitle:@"Sorry!"
                         message:@"In order to use MyMaret you have to log in with a Maret username and password.  Please try again."];
    } else {
        // Black out the view
        self.view.hidden = YES;
        
        // Mark them as logged in
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:MyMaretIsLoggedInKey];
        
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
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        // Track app usage
        [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
        
        // Make sure the badge is in line with the number of unread announcements
        [[PFInstallation currentInstallation] setBadge:[[AnnouncementsStore sharedStore] numberOfUnreadAnnouncements]];
        [[PFInstallation currentInstallation] saveInBackground];
        
        
        // Download announcements and the newspaper
        [[AnnouncementsStore sharedStore] fetchAnnouncementsWithCompletionBlock:^(NSUInteger numAdded, NSError *err) {
            
        }];
        
        [[NewspaperStore sharedStore] fetchNewspaperWithCompletionBlock:^(BOOL didAddArticles, NSError *err) {
#if DEBUG
            NSLog(@"Added articles?");
            (didAddArticles) ? NSLog(@"Yes") : NSLog(@"No");
#endif
        }];
        
        // Query for the "Person" object for this user
        PFQuery *query = [PFQuery queryWithClassName:@"Person"];
        [query whereKey:@"emailAddress" equalTo:emailAddr];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            
            // Save their name in NSUserDefaults and update their Person object in Parse
            if (!error) {
                
                [[NSUserDefaults standardUserDefaults] setObject:emailAddr
                                                          forKey:MyMaretUserEmailKey];
                
                NSString *userFullName = [NSString stringWithFormat:@"%@ %@",
                                          [object objectForKey:@"firstName"],
                                          [object objectForKey:@"lastName"]];
                
                [[NSUserDefaults standardUserDefaults] setObject:userFullName
                                                          forKey:MyMaretUserNameKey];
                
                [[NSUserDefaults standardUserDefaults] setInteger:[[object objectForKey:@"grade"] integerValue]
                                                           forKey:MyMaretUserGradeKey];
                
                // We don't support downloading faculty class schedules
                if ([[object objectForKey:@"grade"] integerValue] > 12) {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                 message:@"Unfortunately, MyMaret only supports downloading student class schedules at this time.  If you enter your schedule information, however, you can still take advantage of the schedule section.  Just tap the Edit button in the top right of the Schedule Section, or tap on an individual class in your schedule to change it."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK!"
                                                       otherButtonTitles:nil];
                    
                    [av show];
                } else {
                    [[ClassScheduleStore sharedStore] fetchClassScheduleWithCompletionBlock:nil];
                }
                
                // Update the object so the user won't receive email (since they have the app)
                [object setObject:[NSNumber numberWithBool:NO] forKey:@"shouldReceiveEmails"];
                [object saveInBackground];
            } else if ([error code] == kPFErrorObjectNotFound) {
                [[ClassScheduleStore sharedStore] createEmptySchedule];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                             message:@"Sorry, but we weren't able to identify you as a member of the Upper School.  You're still able to use all of the features of MyMaret, but you'll be unable to send announcements from within the app or have your schedule downloaded automatically.  If you need to send an announcement, please send it via email.  If you think this is an error, drop us a line by tapping on the \"Contact Us\" button in Settings."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Got it!"
                                                   otherButtonTitles:nil];
                [av show];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:emailAddr
                                                          forKey:MyMaretUserEmailKey];
            }
        }];
        
        // Go to the welcome screen
        WelcomeViewController *welcomeVC = [[[WelcomeViewController alloc] init] autorelease];
        [self.navigationController pushViewController:welcomeVC animated:YES];
    }
}



/**************** NICK'S ADDED CODE END ******************/



#pragma mark Rest of Code
- (void)moveWebViewFromUnderNavigationBar {
  CGRect dontCare;
  CGRect webFrame = self.view.bounds;
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  CGRectDivide(webFrame, &dontCare, &webFrame,
    navigationBar.frame.size.height, CGRectMinYEdge);
  [self.webView setFrame:webFrame];
}

// isTranslucent is defined in iPhoneOS 3.0 on.
- (BOOL)isNavigationBarTranslucent {
  UINavigationBar *navigationBar = [[self navigationController] navigationBar];
  BOOL isTranslucent =
    ([navigationBar respondsToSelector:@selector(isTranslucent)] &&
     [navigationBar isTranslucent]);
  return isTranslucent;
}

#pragma mark -
#pragma mark Protocol implementations

- (void)viewWillAppear:(BOOL)animated {
  // See the comment on clearBrowserCookies in viewWillDisappear.
  [self clearBrowserCookies];

  if (!isViewShown_) {
    isViewShown_ = YES;
    if ([self isNavigationBarTranslucent]) {
      [self moveWebViewFromUnderNavigationBar];
    }
    if (![signIn_ startSigningIn]) {
      // Can't start signing in. We must pop our view.
      // UIWebview needs time to stabilize. Animations need time to complete.
      // We remove ourself from the view stack after that.
      [self performSelector:@selector(popView)
                 withObject:nil
                 afterDelay:0.5
                    inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
  }
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  didViewAppear_ = YES;
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (!didDismissSelf_) {
    // We won't receive further webview delegate messages, so be sure the
    // started loading notification is balanced, if necessary
    [self notifyWithName:kGTMOAuth2WebViewStoppedLoading
                 webView:self.webView
                    kind:kGTMOAuth2WebViewCancelled];

    // We are not popping ourselves, so presumably we are being popped by the
    // navigation controller; tell the sign-in object to close up shop
    //
    // this will indirectly call our signIn:finishedWithAuth:error: method
    // for us
    [signIn_ windowWasClosed];

#if NS_BLOCKS_AVAILABLE
    self.popViewBlock = nil;
#endif
  }

  // prevent the next sign-in from showing in the WebView that the user is
  // already signed in.  It's possible for the WebView to set the cookies even
  // after this, so we also clear them when the view first appears.
  [self clearBrowserCookies];

  [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
  // We don't call super's version of this method because
  // -[UIViewController viewDidLayoutSubviews] is documented as a no-op, that
  // didn't exist before iOS 5.
  [initialActivityIndicator_ setCenter:[webView_ center]];
}

- (BOOL)webView:(UIWebView *)webView
  shouldStartLoadWithRequest:(NSURLRequest *)request
              navigationType:(UIWebViewNavigationType)navigationType {

  if (!hasDoneFinalRedirect_) {
    hasDoneFinalRedirect_ = [signIn_ requestRedirectedToRequest:request];
    if (hasDoneFinalRedirect_) {
      // signIn has told the view to close
      return NO;
    }
  }
  return YES;
}

- (void)updateUI {
  //[backButton_ setEnabled:[[self webView] canGoBack]];
  //[forwardButton_ setEnabled:[[self webView] canGoForward]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  [self notifyWithName:kGTMOAuth2WebViewStartedLoading
               webView:webView
                  kind:nil];
  [self updateUI];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self notifyWithName:kGTMOAuth2WebViewStoppedLoading
               webView:webView
                  kind:kGTMOAuth2WebViewFinished];

  NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if ([title length] > 0) {
    [signIn_ titleChanged:title];
  } else {
#if DEBUG
    // Verify that Javascript is enabled
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"1+1"];
    NSAssert([result integerValue] == 2, @"GTMOAuth2: Javascript is required");
#endif
  }

  if (self.request && [self.initialHTMLString length] > 0) {
    // The request was pending.
    [self setInitialHTMLString:nil];
    [self.webView loadRequest:self.request];
  } else {
    [initialActivityIndicator_ setHidden:YES];
    [signIn_ cookiesChanged:[NSHTTPCookieStorage sharedHTTPCookieStorage]];

    [self updateUI];
  }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [self notifyWithName:kGTMOAuth2WebViewStoppedLoading
               webView:webView
                  kind:kGTMOAuth2WebViewFailed];

  // Tell the sign-in object that a load failed; if it was the authorization
  // URL, it will pop the view and return an error to the delegate.
  if (didViewAppear_) {
    BOOL isUserInterruption = ([error code] == NSURLErrorCancelled
                               && [[error domain] isEqual:NSURLErrorDomain]);
    if (isUserInterruption) {
      // Ignore this error:
      // Users report that this error occurs when clicking too quickly on the
      // accept button, before the page has completely loaded.  Ignoring
      // this error seems to provide a better experience than does immediately
      // cancelling sign-in.
      //
      // This error also occurs whenever UIWebView is sent the stopLoading
      // message, so if we ever send that message intentionally, we need to
      // revisit this bypass.
      return;
    }

    [signIn_ loadFailedWithError:error];
  } else {
    // UIWebview needs time to stabilize. Animations need time to complete.
    [signIn_ performSelector:@selector(loadFailedWithError:)
                  withObject:error
                  afterDelay:0.5
                     inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
  }
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
// When running on a device with an OS version < 6, this gets called.
//
// Since it is never called in iOS 6 or greater, if your min deployment
// target is iOS6 or greater, then you don't need to have this method compiled
// into your app.
//
// When running on a device with an OS version 6 or greater, this code is
// not called. - (NSUInteger)supportedInterfaceOrientations; would be called,
// if it existed. Since it is absent,
// Allow the default orientations: All for iPad, all but upside down for iPhone.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  BOOL value = YES;
  if (!isInsideShouldAutorotateToInterfaceOrientation_) {
    isInsideShouldAutorotateToInterfaceOrientation_ = YES;
    UIViewController *navigationController = [self navigationController];
    if (navigationController != nil) {
      value = [navigationController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
      value = [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    isInsideShouldAutorotateToInterfaceOrientation_ = NO;
  }
  return value;
}
#endif


@end


#pragma mark Common Code

@implementation GTMOAuth2Keychain

+ (GTMOAuth2Keychain *)defaultKeychain {
  if (sDefaultKeychain == nil) {
    sDefaultKeychain = [[self alloc] init];
  }
  return sDefaultKeychain;
}


// For unit tests: allow setting a mock object
+ (void)setDefaultKeychain:(GTMOAuth2Keychain *)keychain {
  if (sDefaultKeychain != keychain) {
    [sDefaultKeychain release];
    sDefaultKeychain = [keychain retain];
  }
}

- (NSString *)keyForService:(NSString *)service account:(NSString *)account {
  return [NSString stringWithFormat:@"com.google.GTMOAuth.%@%@", service, account];
}

// The Keychain API isn't available on the iPhone simulator in SDKs before 3.0,
// so, on early simulators we use a fake API, that just writes, unencrypted, to
// NSUserDefaults.
#if TARGET_IPHONE_SIMULATOR && __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
#pragma mark Simulator

// Simulator - just simulated, not secure.
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  NSString *result = nil;
  if (0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    result = [defaults stringForKey:key];
    if (result == nil && error != NULL) {
      *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                   code:kGTMOAuth2KeychainErrorNoPassword
                               userInfo:nil];
    }
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:kGTMOAuth2KeychainErrorBadArguments
                             userInfo:nil];
  }
  return result;

}


// Simulator - just simulated, not secure.
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  BOOL didSucceed = NO;
  if (0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:kGTMOAuth2KeychainErrorBadArguments
                             userInfo:nil];
  }
  return didSucceed;
}

// Simulator - just simulated, not secure.
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
      accessibility:(CFTypeRef)accessibility
            account:(NSString *)account
              error:(NSError **)error {
  BOOL didSucceed = NO;
  if (0 < [password length] && 0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    [defaults setObject:password forKey:key];
    [defaults synchronize];
    didSucceed = YES;
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:kGTMOAuth2KeychainErrorBadArguments
                             userInfo:nil];
  }
  return didSucceed;
}

#else // ! TARGET_IPHONE_SIMULATOR
#pragma mark Device

+ (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
  NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         (id)kSecClassGenericPassword, (id)kSecClass,
                         @"OAuth", (id)kSecAttrGeneric,
                         account, (id)kSecAttrAccount,
                         service, (id)kSecAttrService,
                         nil];
  return query;
}

- (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
  return [[self class] keychainQueryForService:service account:account];
}



// iPhone
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  OSStatus status = kGTMOAuth2KeychainErrorBadArguments;
  NSString *result = nil;
  if (0 < [service length] && 0 < [account length]) {
    CFDataRef passwordData = NULL;
    NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];

    status = SecItemCopyMatching((CFDictionaryRef)keychainQuery,
                                       (CFTypeRef *)&passwordData);
    if (status == noErr && 0 < [(NSData *)passwordData length]) {
      result = [[[NSString alloc] initWithData:(NSData *)passwordData
                                      encoding:NSUTF8StringEncoding] autorelease];
    }
    if (passwordData != NULL) {
      CFRelease(passwordData);
    }
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return result;
}


// iPhone
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  OSStatus status = kGTMOAuth2KeychainErrorBadArguments;
  if (0 < [service length] && 0 < [account length]) {
    NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
    status = SecItemDelete((CFDictionaryRef)keychainQuery);
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

// iPhone
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
      accessibility:(CFTypeRef)accessibility
            account:(NSString *)account
              error:(NSError **)error {
  OSStatus status = kGTMOAuth2KeychainErrorBadArguments;
  if (0 < [service length] && 0 < [account length]) {
    [self removePasswordForService:service account:account error:nil];
    if (0 < [password length]) {
      NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
      NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
      [keychainQuery setObject:passwordData forKey:(id)kSecValueData];

      if (accessibility != NULL && &kSecAttrAccessible != NULL) {
        [keychainQuery setObject:(id)accessibility
                          forKey:(id)kSecAttrAccessible];
      }
      status = SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    }
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGTMOAuth2KeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

#endif // ! TARGET_IPHONE_SIMULATOR

@end

#endif // TARGET_OS_IPHONE

#endif // #if GTM_INCLUDE_OAUTH2 || !GDATA_REQUIRE_SERVICE_INCLUDES
