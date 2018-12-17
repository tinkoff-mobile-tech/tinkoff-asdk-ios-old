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

typedef NS_ENUM(NSUInteger, TableViewCellType)
{
	CellProductTitle = 1,
	CellProductDescription,
	CellAmount,
	CellPaymentCardRequisites, // required field
	CellEmail,
	CellPayButton,
	CellAttachButton,
	CellSecureLogos, // required field
	CellEmpty20px,
	CellEmpty5px,
	CellEmptyFlexibleSpace
};

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

/*!
 *  @discussion Установить на кнопку оплатить надпись
 *
 *  @param title - строка, выравнивается по центу
 */

- (void)setPayButtonTitle:(NSString *)title;
- (NSString *)payButtonTitle;

/*!
 *
 */
- (void)setCustomPayButton:(UIButton *)button;
- (UIButton *)customPayButton;

/*!
 *  @discussion Установить на кнопку оплатить надпись
 *
 *  @param title - строка с атрибутами, выравнивается по центу
 */

- (void)setPayButtonAttributedTitle:(NSAttributedString *)title;
- (NSAttributedString *)payButtonAttributedTitle;

- (void)setCustomBackButton:(UIBarButtonItem *)backButton;
- (UIBarButtonItem *)customBackButton;

/*!
 *  @discussion Настройка элементов экрана оплаты и их последовательности
 *
 *  @param items - массив из элементов PayFormItems, если в массиве будут элементы не из PayFormItems будет использоваться базова конфигурация:
 *  CellProductTitle, CellProductDescription, CellAmount, CellPyamentCardRequisites,
 *  CellEmail, CellPayButton, (CellSecureLogos)
 */

- (void)setPayFormItems:(NSArray *)items;
- (NSArray*)payFormItems;

/*!
 *  @discussion Установить свои логотипы платежных систем
 *
 *  @param view - любое uivew, элемент устанавливается вертикально по центру, значание высоты берется равной высоте контента.
 */

- (void)setPaymentsSecureLogosView:(UIView *)view;
- (UIView *)paymentsSecureLogosView;

/*!
 *
 */

- (NSArray *)attachCardItems;
- (void)setAttachCardItems:(NSArray *)items;

- (UIButton *)attachCardCustomButton;
- (void)setAttachCardCustomButton:(UIButton *)button;

- (NSString *)attachCardButtonTitle;
- (void)setAttachCardButtonTitle:(NSString *)title;

/*!
 *  @discussion В каком виде показыть экраны UIModalPresentationStyle, по умолчанию UIModalPresentationFullScreen
 *
 */

- (UIModalPresentationStyle)modalPresentationStyle;
/*!
 *  @discussion В каком виде показыть экраны
 *
 *  @param value - UIModalPresentationStyle, по умолчанию UIModalPresentationFullScreen
 */

- (void)setModalPresentationStyle:(UIModalPresentationStyle)value;

/*!
 *  @discussion Установить заголовок экрана оплатить
 *
 *  @param title - название экрана
 */

- (void)setPayViewTitle:(NSString *)title;
- (NSString *)payViewTitle;

@end
