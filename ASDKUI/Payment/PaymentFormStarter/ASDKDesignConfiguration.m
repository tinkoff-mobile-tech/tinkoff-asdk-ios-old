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

@property (nonatomic, strong) UIColor *_navigationBarColor;
@property (nonatomic, strong) UIColor *_navigationBarItemsTextColor;
@property (nonatomic) UIBarStyle _navigationBarStyle;

@property (nonatomic, strong) UIColor *_payButtonColor;
@property (nonatomic, strong) UIColor *_payButtonPressedColor;
@property (nonatomic, strong) UIColor *_payButtonTextColor;

@property (nonatomic, strong) NSString *_payButtonTitle;
@property (nonatomic, strong) NSAttributedString *_payButtonAttributedTitle;

@property (nonatomic, strong) UIBarButtonItem *_backButton;
@property (nonatomic, strong) NSArray *_payFormItems;
@property (nonatomic, strong) UIView *_paymentsSecureLogosView;
@property (nonatomic, strong) UIButton *_customPayButton;

@property (nonatomic, strong) NSArray *_attachCardItems;
@property (nonatomic, strong) UIButton *_attachCardCustomButton;
@property (nonatomic, strong) NSString *_attachCardButtonTitle;
@property (nonatomic, assign) UIModalPresentationStyle _presentStyleModal;

@property (nonatomic, strong) NSString *payViewControllerTitle;

@end

@implementation ASDKDesignConfiguration

- (id)init
{
    if (self = [super init])
	{
    	__navigationBarStyle = UIBarStyleDefault;
		if (@available(iOS 13.0, *)) {
            __navigationBarColor = UIColor.systemBackgroundColor;
            __navigationBarItemsTextColor = UIColor.labelColor;
        } else {
            __navigationBarColor = UIColor.whiteColor;
            __navigationBarItemsTextColor = UIColor.blackColor;
        }
		__presentStyleModal = UIModalPresentationFullScreen;
	}

    return self;
}

- (void)setNavigationBarColor:(UIColor *)navigationBarColor
  navigationBarItemsTextColor:(UIColor *)navigationBarItemsTextColor
           navigationBarStyle:(UIBarStyle)navigationBarStyle
{
    __navigationBarColor = navigationBarColor;
    __navigationBarItemsTextColor = navigationBarItemsTextColor;
    __navigationBarStyle = navigationBarStyle;
}

- (UIColor *)navigationBarColor
{
    if (self._navigationBarColor)
    {
        return self._navigationBarColor;
    }
    
    return [ASDKDesign colorNavigationBar];
}

- (UIColor *)navigationBarItemsTextColor
{
    if (self._navigationBarItemsTextColor)
    {
        return self._navigationBarItemsTextColor;
    }
    
    if (@available(iOS 13.0, *)) {
        return [UIColor systemBackgroundColor];
    }
    
    return [UIColor whiteColor];
}

- (UIBarStyle)navigationBarStyle
{
    return self._navigationBarStyle;
}

- (void)setPayButtonColor:(UIColor *)payButtonColor payButtonPressedColor:(UIColor *)payButtonPressedColor payButtonTextColor:(UIColor *)payButtonTextColor
{
    self._payButtonColor = payButtonColor;
    self._payButtonPressedColor = payButtonPressedColor;
    self._payButtonTextColor = payButtonTextColor;
}

- (void)setCustomBackButton:(UIBarButtonItem *)backButton
{
	self._backButton = backButton;
}

- (UIBarButtonItem *)customBackButton
{
	return self._backButton;
}

- (UIColor *)payButtonColor
{
    if (self._payButtonColor)
    {
        return self._payButtonColor;
    }
    
    return [ASDKDesign colorPayButton];
}

- (UIColor *)payButtonPressedColor
{
    if (self._payButtonPressedColor)
    {
        return self._payButtonPressedColor;
    }
    
    return [ASDKDesign colorPayButtonPressed];
}

- (UIColor *)payButtonTextColor
{
    if (self._payButtonTextColor)
    {
        return self._payButtonTextColor;
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
			switch ([obj unsignedIntegerValue]) {
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

	NSAssert([items indexOfObjectIdenticalTo:@(CellSecureLogos)] != NSNotFound, @"CellSecureLogos is required field");
	NSAssert([items indexOfObjectIdenticalTo:@(CellPaymentCardRequisites)] != NSNotFound, @"CellPaymentCardRequisites is required field");

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

- (UIModalPresentationStyle)modalPresentationStyle
{
	return self._presentStyleModal;
}

- (void)setModalPresentationStyle:(UIModalPresentationStyle)value
{
	self._presentStyleModal = value;
}

- (void)setPayViewTitle:(NSString *)title
{
	self.payViewControllerTitle = title;
}

- (NSString *)payViewTitle
{
	return self.payViewControllerTitle;
}

@end
