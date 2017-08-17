//
//  ASDKDesignConfiguration.m
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


#import "ASDKDesignConfiguration.h"
#import "ASDKDesign.h"

@interface ASDKDesignConfiguration ()

@property (nonatomic, strong) UIColor *navigationBarColor;
@property (nonatomic, strong) UIColor *navigationBarItemsTextColor;
@property (nonatomic) UIBarStyle navigationBarStyle;

@property (nonatomic, strong) UIColor *payButtonColor;
@property (nonatomic, strong) UIColor *payButtonPressedColor;
@property (nonatomic, strong) UIColor *payButtonTextColor;

@property (nonatomic, strong) UIBarButtonItem *backButton;

@end

@implementation ASDKDesignConfiguration

- (id)init
{
    self = [super init];
    
    self.navigationBarStyle = UIBarStyleBlack;
    
    return self;
}




- (void)setNavigationBarColor:(UIColor *)navigationBarColor
  navigationBarItemsTextColor:(UIColor *)navigationBarItemsTextColor
           navigationBarStyle:(UIBarStyle)navigationBarStyle
{
    _navigationBarColor = navigationBarColor;
    _navigationBarItemsTextColor = navigationBarItemsTextColor;
    _navigationBarStyle = navigationBarStyle;
}


- (UIColor *)navigationBarColor
{
    if (_navigationBarColor)
    {
        return _navigationBarColor;
    }
    
    return [ASDKDesign colorNavigationBar];
}

- (UIColor *)navigationBarItemsTextColor
{
    if (_navigationBarItemsTextColor)
    {
        return _navigationBarItemsTextColor;
    }
    
    return [UIColor whiteColor];
}

- (UIBarStyle)navigationBarStyle
{
    return _navigationBarStyle;
}




- (void)setPayButtonColor:(UIColor *)payButtonColor payButtonPressedColor:(UIColor *)payButtonPressedColor payButtonTextColor:(UIColor *)payButtonTextColor
{
    _payButtonColor = payButtonColor;
    _payButtonPressedColor = payButtonPressedColor;
    _payButtonTextColor = payButtonTextColor;
}

- (void)setCustomBackButton:(UITabBarItem *)backButton
{
	_backButton = backButton;
}

- (UIBarButtonItem *)customBackButton
{
	return _backButton;
}

- (UIColor *)payButtonColor
{
    if (_payButtonColor)
    {
        return _payButtonColor;
    }
    
    return [ASDKDesign colorPayButton];
}

- (UIColor *)payButtonPressedColor
{
    if (_payButtonPressedColor)
    {
        return _payButtonPressedColor;
    }
    
    return [ASDKDesign colorPayButtonPressed];
}

- (UIColor *)payButtonTextColor
{
    if (_payButtonTextColor)
    {
        return _payButtonTextColor;
    }
    
    return [ASDKDesign colorTextDark];
}

@end
