//
//  ViewController.m
//  SuspendedBall_StaticLib
//
//  Created by MountainX on 2018/1/31.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import "SuspendedBall.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    CGFloat layerWidth = fmax(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    layer.frame = CGRectMake(0, 0, layerWidth, layerWidth);
    layer.colors = @[(__bridge id)[UIColor orangeColor].CGColor,
                     (__bridge id)[UIColor yellowColor].CGColor];
    [self.view.layer insertSublayer:layer below:0];
    
    SuspendedBall *ball = [SuspendedBall sharedInstance];
    [ball showInView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
