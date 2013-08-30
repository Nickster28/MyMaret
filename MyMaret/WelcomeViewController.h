//
//  WelcomeViewController.h
//  MyMaret
//
//  Created by Nick Troccoli on 8/26/13.
//  Copyright (c) 2013 Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)dismissWelcomeScreen:(id)sender;
@end
