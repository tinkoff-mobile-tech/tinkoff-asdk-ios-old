//
//  ASDKDesignConfiguration.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASDKDesignConfiguration : NSObject
/*!
 *  @discussion Настройка цветов в навигейшн баре
 *
 *  @param navigationBarColor          цвет фона
 *  @param navigationBarItemsTextColor цвет текста
 *  @param navigationBarStyle          бар стайл
 */
- (void)setNavigationBarColor:(UIColor *)navigationBarColor
  navigationBarItemsTextColor:(UIColor *)navigationBarItemsTextColor
           navigationBarStyle:(UIBarStyle)navigationBarStyle;

- (UIColor *)navigationBarColor;
- (UIColor *)navigationBarItemsTextColor;
- (UIBarStyle)navigationBarStyle;


- (void)setPayButtonColor:(UIColor *)payButtonColor payButtonPressedColor:(UIColor *)payButtonPressedColor payButtonTextColor:(UIColor *)payButtonTextColor;

- (UIColor *)payButtonColor;
- (UIColor *)payButtonPressedColor;
- (UIColor *)payButtonTextColor;


@end
