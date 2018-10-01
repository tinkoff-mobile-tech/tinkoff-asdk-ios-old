//
//  ASDKBaseViewController.m
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


#import "ASDKBaseViewController.h"
#import "ASDKUtils.h"
#import "ASDKDesign.h"
#import "ASDKPaymentFormStarter.h"

@implementation ASDKBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
    ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
	if (designConfiguration)
	{
		NSLog(@"DESIGN!!! %@",designConfiguration);
		self.navigationController.navigationBar.barStyle = [designConfiguration navigationBarStyle];
		[self.navigationController.navigationBar setBackgroundImage:[ASDKUtils imageFromColor:[designConfiguration navigationBarColor]] forBarMetrics:UIBarMetricsDefault];

		self.navigationController.navigationBar.barTintColor = [designConfiguration navigationBarColor];
		self.navigationController.navigationBar.tintColor = [designConfiguration navigationBarItemsTextColor];
		self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [designConfiguration navigationBarItemsTextColor]};
	}
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
