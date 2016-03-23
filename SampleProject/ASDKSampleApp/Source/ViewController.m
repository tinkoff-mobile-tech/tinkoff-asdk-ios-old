//
//  ViewController.m
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 05.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ViewController.h"
#import <ASDKCore/ASDKCore.h>
#import <ASDKUI/ASDKUI.h>

#import "ASDKCardIOScanner.h"

#import "ASDKTestKeys.h"


@interface ViewController ()

@property (nonatomic, strong) ASDKCardIOScanner *scannerObject;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
