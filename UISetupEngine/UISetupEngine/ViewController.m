//
//  ViewController.m
//  UISetupEngine
//
//  Created by hncoder on 2017/3/16.
//  Copyright © 2017年 hncoder. All rights reserved.
//

#import "ViewController.h"
#import "UIView+SetupEngine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *testView = [UIView setupUIObjectWithFormat:@"v:{{100,100},{100,100}}:(255,0,0)"];
    [self.view addSubview:testView];
    
    UILabel *label = [UILabel setupUIObjectWithFormat:@"l:{{200,100},{100,100}}:(255,0,0):@@text:@30:-|-"];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
