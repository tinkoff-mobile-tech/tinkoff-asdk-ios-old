//
//  ASDKNavigationController.m
//  ASDKUI
//
// Copyright (c) 2016 TCS Bank
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ASDKNavigationController.h"
#import "ASDKPaymentFormStarter.h"

@interface ASDKNavigationController ()

@end

@implementation ASDKNavigationController

- (instancetype)initWithNavigationBarClass:(nullable Class)navigationBarClass toolbarClass:(nullable Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
    ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
    self.navigationBar.barStyle = [designConfiguration navigationBarStyle];
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
    ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
    self.navigationBar.barStyle = [designConfiguration navigationBarStyle];
    
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
