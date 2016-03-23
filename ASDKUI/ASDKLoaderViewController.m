//
//  ASDKLoaderViewController.m
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


#import "ASDKLoaderViewController.h"
//#import "ASDKPaymentFormStarter.h"

NSString *const ASDKNotificationShowLoader = @"ASDKNotificationShowLoader";
NSString *const ASDKNotificationHideLoader = @"ASDKNotificationHideLoader";

@interface ASDKLoaderViewController ()

@property (nonatomic, weak) IBOutlet UIView *backView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ASDKLoaderViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backView.layer.cornerRadius = 10;
    [self.activityIndicatorView startAnimating];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[UIApplication sharedApplication] statusBarStyle];
}

@end
