//
//  ASDKTextField.h
//  ASDK
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

#import "ASDKLabel.h"

@class ASDKTextField;
@protocol ASDKTextFieldKeyInputDelegate <NSObject>

@optional
- (void)textFieldDidDelete:(ASDKTextField *)textField;

@end

@interface ASDKTextField : UITextField
{
	ASDKLabel       *_labelInputMask;
	NSArray			*_showInputMaskCharacters;
}

@property (nonatomic, weak) id <ASDKTextFieldKeyInputDelegate> keyInputDelegate;

@property (nonatomic, readonly) NSRange selectedRange;

//!маска для ввода текста, вместо знака "_" цифра. Пример @"+_(___) ___-__-__"
@property (nonatomic, strong) NSString *inputMask;
//!показывать маску при вводе текста
@property (nonatomic) BOOL showInputMask;

//скрывать курсор при вводе
@property (nonatomic) BOOL hideCursor;

//достпуность копипаста
@property (nonatomic, assign) BOOL disablePaste;
@property (nonatomic, assign) BOOL disableCopy;
//!показывать в маске только символы из массива characters. Пример: показывать только скобки [ASDKTextField setShowInputMask:YES showCharacters:@[@"(", @")"]];
- (void)setShowInputMask:(BOOL)value showCharacters:(NSArray *)characters;
//!внутреняя обработка ввода текста для форматирования введенного текста по маске ввода
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
//- (NSRange)selectedRange;

@end
