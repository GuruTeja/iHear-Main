//
//  ViewController2.m
//  NVDSPExample
//
//  Created by Mayanka  on 10/16/15.
//  Copyright © 2015 Bart Olsthoorn. All rights reserved.
//

#import "ViewController2.h"
//#import "ViewController.mm"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for setting background color
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main1.png"]];
    //background image
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main1.png"]];
//    [self.view addSubview:backgroundView];
//    // Do any additional setup after loading the view.
//    
//    // create effect
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    
//    // add effect to an effect view
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
//    effectView.frame = self.view.frame;
//    [self.imageView addSubview:effectView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
//    [_userName release];
//    [_userPassword release];
//    [_imageView release];
//    [super dealloc];
}
- (IBAction)login:(id)sender {
    
    NSString *name = _userName.text;
    NSString *password = _userPassword.text;
    NSLog(@"user name and pass word is %@, %@", name,password);
    
    NSURL *url = [NSURL URLWithString:@"http://ihearrestservice.mybluemix.net/api/login/guru"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,
                                                                                                            NSData *data, NSError *connectionError)
    {
        if(data.length > 0 && connectionError == nil){
            NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data in url is %@", strData);
            //NSDictionary *greeting
        }
        
    }];
    
    
    if([name isEqualToString:@"ihear"] &&  [password isEqualToString:@"ihear"]){
        
        NSLog(@"success");
        
        [self performSegueWithIdentifier:@"conditionSegue" sender:nil];
        
        
        
    }
    
}
@end
