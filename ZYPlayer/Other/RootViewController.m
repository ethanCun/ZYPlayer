//
//  RootViewController.m
//  CzyLocalPlayer
//
//  Created by macOfEthan on 17/11/15.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "RootViewController.h"
#import "ZYPlayViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (IBAction)play:(id)sender {
    
//    [self presentViewController:[ViewController new] animated:YES completion:nil];
    [self.navigationController pushViewController:[ZYPlayViewController new] animated:YES];
}

// default is UIInterfaceOrientationPortrait while presentation
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
