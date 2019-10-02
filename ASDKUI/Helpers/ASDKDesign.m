//
//  ASDKDesign.m
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

#import "ASDKDesign.h"
#import "ASDKUtils.h"

@implementation ASDKDesign

+ (UIColor *)colorN2
{
    return [ASDKUtils colorWithInteger:0x3e4757];
}

+ (UIColor *)colorN4Separator
{
    return [ASDKUtils colorWithInteger:0xc7c9cc];
}

+ (UIColor *)colorTableViewBackground
{
    if (@available(iOS 13.0, *)) {
        return [UIColor systemBackgroundColor];
    } else {
        return [ASDKUtils colorWithInteger:0xf6f7f8];
    }
}

+ (UIColor *)colorTextLight
{
    if (@available(iOS 13.0, *)) {
        return [UIColor tertiaryLabelColor];
    } else {
        return [ASDKUtils colorWithInteger:0x9299a2];
    }
}

+ (UIColor *)colorTextDark
{
    if (@available(iOS 13.0, *)) {
        return [UIColor labelColor];
    } else {
        return [ASDKUtils colorWithInteger:0x333333];
    }
}

+ (UIColor *)colorTextPlaceholder
{
    if (@available(iOS 13.0, *)) {
        return [UIColor placeholderTextColor];
    } else {
        return [ASDKUtils colorWithInteger:0xc7c9cc];
    }
}

+ (UIColor *)colorMainBlue
{
    if (@available(iOS 13.0, *)) {
        return [UIColor systemTealColor];
    } else {
        return [ASDKUtils colorWithInteger:0x009ecf];
    }
}

+ (UIColor *)colorNavigationBar
{
    return [ASDKUtils colorWithInteger:0x3e4757];
}

+ (UIColor *)colorPayButton
{
    return [ASDKUtils colorWithInteger:0xffdd2d];
}

+ (UIColor *)colorPayButtonPressed
{
    return [ASDKUtils colorWithInteger:0xffcd33];
}

@end
