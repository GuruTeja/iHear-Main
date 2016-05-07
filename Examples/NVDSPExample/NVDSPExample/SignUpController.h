//
//  SignUpController.h
//  NVDSPExample
//
//  Created by Mayanka  on 11/13/15.
//  Copyright © 2015 Bart Olsthoorn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *imageView2;

@property (retain, nonatomic) IBOutlet UIButton *signUpbutton;
@property (retain, nonatomic) IBOutlet UITextField *firstName;
@property (retain, nonatomic) IBOutlet UITextField *lastName;
@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;


- (IBAction)signUp:(id)sender;
@end
