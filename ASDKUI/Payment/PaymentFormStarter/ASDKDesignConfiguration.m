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

@property (nonatomic, strong) NSString *_payButtonTitle;
@property (nonatomic, strong) NSAttributedString *_payButtonAttributedTitle;

@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) NSArray *_payFormItems;
@property (nonatomic, strong) UIView *_paymentsSecureLogosView;
@property (nonatomic, strong) UIButton *_customPayButton;

@property (nonatomic, strong) NSArray *_attachCardItems;
@property (nonatomic, strong) UIButton *_attachCardCustomButton;
@property (nonatomic, strong) NSString *_attachCardButtonTitle;

@end

@implementation ASDKDesignConfiguration

- (id)init
{
    self = [super init];
    
    self.navigationBarStyle = UIBarStyleDefault;
    
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

- (void)setCustomBackButton:(UIBarButtonItem *)backButton
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

- (NSString *)payButtonTitle
{
	return self._payButtonTitle;
}

- (void)setPayButtonTitle:(NSString *)title
{
	self._payButtonTitle = title;
}

- (NSAttributedString *)payButtonAttributedTitle
{
	return self._payButtonAttributedTitle;
}

- (void)setPayButtonAttributedTitle:(NSAttributedString *)title
{
	self._payButtonAttributedTitle = title;
}

- (void)setCustomPayButton:(UIButton *)button
{
	self._customPayButton = button;
}

- (UIButton *)customPayButton
{
	return self._customPayButton;
}

- (BOOL)checkCellItems:(NSArray *)items
{
	__block BOOL result = items.count > 0;
	[items enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if ([obj isKindOfClass:[NSNumber class]])
		{
			switch ([obj integerValue]) {
				case CellProductTitle:
				case CellProductDescription:
				case CellAmount:
				case CellPaymentCardRequisites:
				case CellEmail:
				case CellPayButton:
				case CellAttachButton:
				case CellSecureLogos:
				case CellEmpty20px:
				case CellEmpty5px:
				case CellEmptyFlexibleSpace:
					result &= YES;
					break;
					
				default:
					result = NO;
					*stop = YES;
					break;
			}
		}
		else
		{
			result = NO;
			*stop = YES;
		}
	}];
	
	return result;
}

- (void)setPayFormItems:(NSArray *)items
{
	if ([self checkCellItems:items] == YES)
	{
		self._payFormItems = items;
	}
}

- (NSArray*)payFormItems
{
	return self._payFormItems;
}

- (void)setPaymentsSecureLogosView:(UIView *)view
{
	self._paymentsSecureLogosView = view;
}

- (UIView *)paymentsSecureLogosView
{
	return self._paymentsSecureLogosView;
}

- (NSArray *)attachCardItems
{
	return self._attachCardItems;
}

- (void)setAttachCardItems:(NSArray *)items
{
	if ([self checkCellItems:items] == YES)
	{
		self._attachCardItems = items;
	}
}

- (UIButton *)attachCardCustomButton
{
	return self._attachCardCustomButton;
}

- (void)setAttachCardCustomButton:(UIButton *)button
{
	self._attachCardCustomButton = button;
}

- (NSString *)attachCardButtonTitle
{
	return self._attachCardButtonTitle;
}

- (void)setAttachCardButtonTitle:(NSString *)title
{
	self._attachCardButtonTitle = title;
}

@end
