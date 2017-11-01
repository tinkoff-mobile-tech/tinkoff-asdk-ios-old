//
//  ASDKCardInputTableViewCell.h
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

#import <UIKit/UIKit.h>
#import "ASDKTextField.h"
#import <ASDKCore/ASDKAcquiringSdk.h>
#import "ASDKBaseCell.h"

@class ASDKCardInputTableViewCell;
@protocol ASDKCardInputTableViewCellDelegate <NSObject>

@optional
- (void)cardInputCellTextDidChange:(ASDKCardInputTableViewCell *)cell;
- (void)textFieldDidBeginEditing:(UITextField *)textField;

@end

@interface ASDKCardInputTableViewCell : ASDKBaseCell <UITextFieldDelegate>

@property (nonatomic, weak) id <ASDKCardInputTableViewCellDelegate> delegate;

@property ASDKTextField *textFieldCardNumber;
@property ASDKTextField *textFieldCardDate;
@property ASDKTextField *textFieldCardCVC;

@property (weak, nonatomic) IBOutlet UIView *viewCardContainer;
@property (weak, nonatomic) IBOutlet UIView *saveCardContainer;

@property (weak, nonatomic) IBOutlet UISwitch *switchSaveCard;
@property (weak, nonatomic) IBOutlet UIButton *cardIOButton;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, assign) BOOL extendedModeEnabled;
@property (nonatomic, assign) BOOL secureModeEnabled;

@property (nonatomic, assign) BOOL useDarkIcons;

@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) NSString *placeholderText;

@property (nonatomic, assign) BOOL showSecretContainer;
@property (nonatomic, weak) IBOutlet UIButton *clearSecretContainerButton;

@property (nonatomic, weak) IBOutlet ASDKTextField *secretCVVTextField;

+ (instancetype)cell;
+ (instancetype)cellForCVCInput;
+ (instancetype)cellForRecieverCard;

- (BOOL)validateForm;

- (void)setPlaceholderText:(NSString *)placeholderText;
- (void)setSecureModeEnabled:(BOOL)enabled;
- (void)setPaymentSystemIcon:(UIImage *)icon;
- (void)setCardNumber:(NSString *)cardNumber;

- (NSString *)cardNumber;
- (NSString *)cardExpirationDate;
- (NSString *)cardCVC;
- (NSString *)exampleSavedCardName;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (void)setScanButtonHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setupForCVCInput;

@end
