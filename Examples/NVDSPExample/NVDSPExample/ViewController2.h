//
//  ViewController2.h
//  NVDSPExample
//
//  Created by Mayanka  on 10/16/15.
//  Copyright © 2015 Bart Olsthoorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ViewController2 : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *userPassword;

//@property (strong, nonatomic) ViewController *secondViewController;
//@property (strong, nonatomic) ViewController2 *firstViewController;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;


- (IBAction)login:(id)sender;
@end
