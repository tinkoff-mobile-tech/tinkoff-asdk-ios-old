//  ASDKCardInputTableViewCell.m
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

#import "ASDKCardInputTableViewCell.h"

#import <AVFoundation/AVFoundation.h>
#import "ASDKMacroses.h"
#import "UIView+AutoLayout.h"
#import "ASDKPaymentFormStarter.h"


#define ASDKCreditCardPaymentSystemInputDefault         @"____ __________________"
#define ASDKCreditCardPaymentSystemInputMaskVisa 	    @"____ ____ ____ ____"
#define ASDKCreditCardPaymentSystemInputMaskMasterCard  @"____ ____ ____ ____"
#define ASDKCreditCardPaymentSystemInputMaskMaestro16   @"____ ____ ____ _____"
#define ASDKCreditCardPaymentSystemInputMaskMaestro19   @"________ ____________"
#define ASDKCreditCardPaymentSystemInputMaskMaestro22   @"________ ______________"
#define ASDKCreditCardPaymentSystemInputMaskMIR16       @"____ ____ ____ _____"
#define ASDKCreditCardPaymentSystemInputMaskMIR18       @"________ ___________"
#define ASDKCreditCardPaymentSystemInputMaskMIR19       @"________ ____________"

//костыль
typedef enum
{
    ASDKCreditCardTypeUnrecognized = 0,
    /// The card number corresponds to multiple card types (e.g., when only a few digits have been entered).
    ASDKCreditCardTypeAmbiguous = 1,
    /// American Express
    ASDKCreditCardTypeAmex = '3',
    /// Japan Credit Bureau
    ASDKCreditCardTypeJCB = 'J',
    /// VISA
    ASDKCreditCardTypeVisa = '4',
    /// MasterCard
    ASDKCreditCardTypeMastercard = '5',
	
	ASDKCreditCardTypeMastercard2 = '2',
	//
	ASDKCreditCardTypeMIR = '2',
    /// Discover Card
    ASDKCreditCardTypeDiscover = '6'
} ASDKCreditCardType;

@interface ASDKCardInputTableViewCell () <ASDKTextFieldKeyInputDelegate>
{
    IBOutlet UIView *_viewCardNumber;
	IBOutlet UIView *_viewCardDate;
	IBOutlet UIView *_viewCardCVC;
	
	UIBarButtonItem *_buttonInputAccessoryDone;
	
	BOOL _paymentLogoHidden;
	BOOL _expanded;
	
	BOOL _cvcValidationFailed;
	BOOL _dateValidationFailed;
	BOOL _cardNumberValidationFailed;
	
	ASDKCreditCardType _creditCardType;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardDateXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardCVCXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardNumberWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardNumberXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardIOButtonXConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imagePaymentLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelSaveCard;

@property (strong, nonatomic) NSString *fullCardNumber;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSDictionary *placeholderAttributes;
@property (strong, nonatomic) NSDictionary *invalidPlaceholderAttributes;

@property (nonatomic, weak) IBOutlet UIView *secretContainerView;
@property (nonatomic, weak) IBOutlet UILabel *secretCardNumberLabel;

@property (nonatomic, weak) IBOutlet UILabel *secretCardDateClashLabel;
@property (nonatomic, weak) IBOutlet UITextField *secretCardNumberDateLeft;
@property (nonatomic, weak) IBOutlet UITextField *secretCardNumberDateRight;

@end

@implementation ASDKCardInputTableViewCell

+ (instancetype)cell
{
	ASDKCardInputTableViewCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
    [cell setShowSecretContainer:NO];
    
	return cell;
}

+ (instancetype)cellForCVCInput
{
	ASDKCardInputTableViewCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
	
	[cell setExtendedModeEnabled:YES];
	[cell setSecureModeEnabled:YES];
	[cell setCardNumberExpanded:NO resetValidationState:YES animated:NO];
	[cell setPaymentLogoHidden:NO animated:NO];
	[cell setScanButtonHidden:YES animated:NO];
	[cell setNextButtonHidden:YES animated:NO];
	[cell.saveCardContainer setHidden:YES];
    [cell setShowSecretContainer:NO];
	
	return cell;
}

- (void)setupForCVCInput
{
	[self setExtendedModeEnabled:YES];
	[self setSecureModeEnabled:YES];
	[self setCardNumberExpanded:NO resetValidationState:YES animated:NO];
	[self setPaymentLogoHidden:NO animated:NO];
	[self setScanButtonHidden:YES animated:NO];
	[self setNextButtonHidden:YES animated:NO];
	[self.saveCardContainer setHidden:YES];
	[self setShowSecretContainer:YES];
}

+ (instancetype)cellForRecieverCard
{
	ASDKCardInputTableViewCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKCardInputTableViewCell" owner:self options:nil] objectAtIndex:0];
	if (@available(iOS 13.0, *)) {
        [cell.contentView setBackgroundColor:[UIColor systemBackgroundColor]];
        [cell.viewCardContainer setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        [cell.viewCardContainer setBackgroundColor:[UIColor whiteColor]];
    }
	[cell setUseDarkIcons:YES];
	[cell setExtendedModeEnabled:NO];
    [cell setShowSecretContainer:NO];
	
	return cell;
}

#pragma mark Lazy initializers


- (NSDictionary *)placeholderAttributes
{
	if (!_placeholderAttributes && self.placeholderColor)
	{
		NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName:self.placeholderColor};
		_placeholderAttributes = placeholderAttributes;
	}
	return _placeholderAttributes;
}

- (NSDictionary *)invalidPlaceholderAttributes
{
	if (!_invalidPlaceholderAttributes)
	{
		NSDictionary *invalidPlaceholderAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
		_invalidPlaceholderAttributes = invalidPlaceholderAttributes;
	}
	return _invalidPlaceholderAttributes;
}

#pragma mark Setters & Getters


- (void)setCardNumber:(NSString *)cardNumber
{
	_fullCardNumber = cardNumber;
	
	[self updatePaymentSystem];
	[self updateInputMasks];
	[self updatePaymentLogo];
	[self updatePlaceholders];
}

- (NSString *)cardNumber
{
    return [self numbersStringFromString:self.fullCardNumber];
}

- (NSString *)cardExpirationDate
{
	return self.textFieldCardDate.text;
}

- (NSString *)cardCVC
{
	if (_showSecretContainer)
	{
		return self.secretCVVTextField.text;
	}
	
	return self.textFieldCardCVC.text;
}

- (NSString *)exampleSavedCardName
{
	NSString *resultCardName = nil;
	
	if ([self cardNumber].length > 4)
	{
		NSString *prefix;
		switch (_creditCardType)
		{
			case ASDKCreditCardTypeVisa:
				prefix = @"VISA *";
				break;

			case ASDKCreditCardTypeMastercard:
				prefix = @"MasterCard *";
				break;

			case ASDKCreditCardTypeDiscover:
				prefix = @"Maestro *";
				break;

			case ASDKCreditCardTypeMIR:
				prefix  = @"MIR *";
				break;

			default:
				prefix = @"*";
				break;
		}
		
		NSString *lastSymbols = [[self cardNumber] substringFromIndex:[self cardNumber].length - 4];
		
		resultCardName = [NSString stringWithFormat:@"%@%@", prefix, lastSymbols];
	}
	else
	{
//        resultCardName = LOC(@"Transfer.NewCard");
	}
	
	return resultCardName;
}

- (void)setUseDarkIcons:(BOOL)useDarkIcons
{
	_useDarkIcons = useDarkIcons;
    
	[self.cardIOButton setImage:[UIImage imageNamed:useDarkIcons ? @"scan_card_grey" : @"scan_card" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
	[self.nextButton setImage:[UIImage imageNamed:useDarkIcons ? @"next_grey" : @"next_white" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor
{
	_textColor = textColor;
	
	[_textFieldCardNumber setTextColor:textColor];
	[_textFieldCardNumber setTintColor:textColor];
	[_textFieldCardDate setTextColor:textColor];
	[_textFieldCardDate setTintColor:textColor];
	[_textFieldCardCVC setTextColor:textColor];
	[_textFieldCardCVC setTintColor:textColor];
    
    [self.secretCVVTextField setTextColor:textColor];
    [self.secretCVVTextField setTintColor:textColor];

    [self.secretCardNumberLabel setTextColor:textColor];
    [self.secretCardDateClashLabel setTextColor:textColor];
    [self.secretCardNumberDateLeft setTextColor:textColor];
    [self.secretCardNumberDateRight setTextColor:textColor];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
	_placeholderColor = placeholderColor;
	_placeholderAttributes = nil;
	
	[self updatePlaceholders];
}

- (void)setExtendedModeEnabled:(BOOL)enabled
{
	_extendedModeEnabled = enabled;
	
	[self.saveCardContainer setHidden:!enabled];
	
	[self setNextButtonHidden:YES animated:NO];
	[self setScanButtonHidden:NO animated:NO];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
	_placeholderText = placeholderText;
	
	[self updatePlaceholders];
}

- (void)setPaymentSystemIcon:(UIImage *)icon
{
	if (icon)
	{
		[self setPaymentLogoHidden:NO animated:YES];
		[self.imagePaymentLogo setImage:icon];
	}
	else
	{
		[self setPaymentLogoHidden:YES animated:NO];
	}
}

- (void)setShowSecretContainer:(BOOL)showSecretContainer
{
    _showSecretContainer = showSecretContainer;
    
    if (_showSecretContainer)
    {
		if (self.cardNumber.length > 4)
		{
        	self.secretCardNumberLabel.text = [NSString stringWithFormat:@"%@", [self.cardNumber substringFromIndex:self.cardNumber.length - 4]];
		}
        self.secretCVVTextField.text = @"";
    }

	[self setScanButtonHidden:_showSecretContainer animated:NO];

    self.secretContainerView.hidden = !_showSecretContainer;
}

#pragma mark Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
	_creditCardType = ASDKCreditCardTypeUnrecognized;
	
	[self setExtendedModeEnabled:YES];
	[self setPaymentLogoHidden:YES  animated:NO];
	[self setNextButtonHidden:YES   animated:NO];
	[self setScanButtonHidden:NO    animated:NO];
	
	[_viewCardNumber setBackgroundColor:nil];
	[_viewCardDate setBackgroundColor:nil];
	[_viewCardCVC setBackgroundColor:nil];
	
//	_buttonInputAccessoryDone = [[UIBarButtonItem alloc] initWithTitle:LOC(@"button.done") style:UIBarButtonItemStyleDone target:self action:@selector(buttonAction:)];
	
//	self.nextButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
//	self.cardIOButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
	
	UIEdgeInsets textFieldInsets = UIEdgeInsetsMake(2, 0, 0, 0);
	self.textFieldCardNumber = [[ASDKTextField alloc] init];
	[self.textFieldCardNumber setInputMask:@"____ ____ ____ _____"];
	[self.textFieldCardNumber setShowInputMask:NO];
	//[self.textFieldCardNumber setDisablePaste:YES];
	//[self.textFieldCardNumber setDisableCopy:YES];
	[self.textFieldCardNumber setKeyboardType:UIKeyboardTypeNumberPad];
	[self.textFieldCardNumber setKeyboardAppearance:UIKeyboardAppearanceLight];
	[self.textFieldCardNumber setFont:[UIFont systemFontOfSize:17]];
	[self.textFieldCardNumber setDelegate:self];
	
	[_viewCardNumber addSubview:self.textFieldCardNumber];
	[self.textFieldCardNumber autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];

	self.textFieldCardDate = [[ASDKTextField alloc] init];
	[self.textFieldCardDate setInputMask:@"__/__"];
	[self.textFieldCardDate setShowInputMask:NO];
	[self.textFieldCardDate setDisablePaste:YES];
	[self.textFieldCardDate setDisableCopy:YES];
	[self.textFieldCardDate setDelegate:self];
	[self.textFieldCardDate setKeyboardType:UIKeyboardTypeNumberPad];
	[self.textFieldCardDate setKeyboardAppearance:UIKeyboardAppearanceLight];
	[self.textFieldCardDate setFont:[UIFont systemFontOfSize:17.0]];
	[self.textFieldCardDate setKeyInputDelegate:self];
	
	[_viewCardDate addSubview:self.textFieldCardDate];
	[self.textFieldCardDate autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];
	
	self.textFieldCardCVC = [[ASDKTextField alloc] init];
	[self.textFieldCardCVC setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.textFieldCardCVC setInputMask:@"___"];
	[self.textFieldCardCVC setDisablePaste:YES];
	[self.textFieldCardCVC setDisableCopy:YES];
	[self.textFieldCardCVC setKeyboardType:UIKeyboardTypeNumberPad];
	[self.textFieldCardCVC setKeyboardAppearance:UIKeyboardAppearanceLight];
	[self.textFieldCardCVC setFont:[UIFont systemFontOfSize:17.0]];
	[self.textFieldCardCVC setSecureTextEntry:YES];
	[self.textFieldCardCVC setDelegate:self];
	[self.textFieldCardCVC setKeyInputDelegate:self];
	[_viewCardCVC addSubview:self.textFieldCardCVC];
	
	[self.textFieldCardCVC autoPinEdgesToSuperviewEdgesWithInsets:textFieldInsets];
    
    [self.secretCVVTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.secretCVVTextField setInputMask:@"___"];
	[self.secretCVVTextField setDisablePaste:YES];
	[self.secretCVVTextField setDisableCopy:YES];
    [self.secretCVVTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.secretCVVTextField setKeyboardAppearance:UIKeyboardAppearanceLight];
    [self.secretCVVTextField setFont:[UIFont systemFontOfSize:17.0]];
    [self.secretCVVTextField setSecureTextEntry:YES];
    [self.secretCVVTextField setDelegate:self];
    [self.secretCVVTextField setKeyInputDelegate:self];
	
	[self setCardNumberExpanded:YES resetValidationState:YES animated:NO];
	
	[self updatePlaceholders];
	
	[self.labelSaveCard setBackgroundColor:nil];
    self.labelSaveCard.text = LOC(@"acq_saved_card_label");
	[self.switchSaveCard setBackgroundColor:nil];
	
	if (!_textColor)
	{
		if (@available(iOS 13.0, *)) {
            [self setTextColor:[UIColor labelColor]];
        } else {
            [self setTextColor:[UIColor blackColor]];
        }
	}
}

#pragma mark ASDKTextFieldKeyInputDelegate

- (void)textFieldDidDelete:(ASDKTextField *)textField
{
	if (textField.text.length == 0)
	{
		if (textField == _textFieldCardCVC)
		{
			[_textFieldCardDate becomeFirstResponder];
		}
		else if (textField == _textFieldCardDate)
		{
			[_textFieldCardNumber becomeFirstResponder];
		}
	}
}


#pragma mark UITextFieldDelegate

+ (UIToolbar *)toolBarWithButton:(UIBarButtonItem *)buttonDone buttonCancel:(UIBarButtonItem *)buttonCancel
{
    UIToolbar *toolBarInputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
    [toolBarInputAccessoryView setTranslucent:YES];
    [toolBarInputAccessoryView setBarStyle:UIBarStyleBlack];
    [toolBarInputAccessoryView setTintColor:[UIColor orangeColor]];
    [toolBarInputAccessoryView setBarTintColor:[UIColor purpleColor]];
    UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [NSMutableArray new];
    
    if (buttonCancel) [items addObject:buttonCancel];
    [items addObject:flexiableItem];
    if (buttonDone) [items addObject:buttonDone];
    
    [toolBarInputAccessoryView setItems:items];
    
    return toolBarInputAccessoryView;
}

- (UIView *)textFieldInputAccessoryView:(UITextField *)textField
{
	return [ASDKCardInputTableViewCell toolBarWithButton:_buttonInputAccessoryDone buttonCancel:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [self.delegate textFieldDidBeginEditing:textField];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setInputAccessoryView:nil];//[self textFieldInputAccessoryView:textField]];
	
	if (self.secureModeEnabled)
	{
		if (textField == self.textFieldCardNumber || textField == self.textFieldCardDate)
			return NO;
	}
	
	if (textField == self.textFieldCardNumber)
	{
		if (!_expanded)
		{
			[self setCardNumberExpanded:YES resetValidationState:YES animated:YES];
			[self updateButtonsStates];
		}
	}
	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField == self.textFieldCardNumber)
	{
		NSString *oldString = textField.text;
		
		// Case when user pastes full card number on top of existing card number with different card type
		if (range.location == 0)
		{
			[self updatePaymentSystemWithCardNumber:string];
			[self updateInputMasksWithCardNumber:string];
		}
		
		if (![self.textFieldCardNumber shouldChangeCharactersInRange:range replacementString:string])
		{
			UITextPosition *beginning = textField.beginningOfDocument;
			UITextPosition *cursorLocation = [textField positionFromPosition:beginning offset:(NSInteger)(range.location + string.length)];
			
			ASDKTextField *tcsTextField = (ASDKTextField *)textField;
            NSString *availableString = [self numbersStringFromString:tcsTextField.text];
			
            [self updateInputMasksWithCardNumber:availableString];
            
			[tcsTextField setText:@""];
			
			BOOL result = [tcsTextField shouldChangeCharactersInRange:(NSRange){0, [tcsTextField.text length]} replacementString:availableString];
			
			if (cursorLocation)
			{
				if ([[oldString substringWithRange:range] isEqualToString:@" "])
				{
					cursorLocation = [textField positionFromPosition:cursorLocation offset:-1];
				}
				else
				{
					NSUInteger location = range.location + 1;
					NSUInteger length = [string length];
					
					NSString *insertedString = nil;
					if (location + length <= [tcsTextField.text length])
					{
						insertedString = [tcsTextField.text substringWithRange:NSMakeRange(location, length)];
					}
					
					if ([insertedString isEqualToString:@" "])
					{
						NSInteger cursorOffset = [textField offsetFromPosition:textField.beginningOfDocument toPosition:cursorLocation];
						
						if (cursorOffset < (NSInteger)textField.text.length)
							cursorLocation = [textField positionFromPosition:cursorLocation offset:1];
					}
				}
				
				NSString *oldNumbers = [self numbersStringFromString:oldString];
				NSString *currentNumbers = [self numbersStringFromString:tcsTextField.text];
				
				// keep cursor at last character when user is backspacing and new mask is longer then old mask
				if ([oldNumbers rangeOfString:currentNumbers].location != NSNotFound && [oldString rangeOfString:textField.text].location == NSNotFound) {
					UITextRange *selectedTextRange = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
					[textField setSelectedTextRange:selectedTextRange];
				}
				else
				{
					// set start/end location to same spot so that nothing is highlighted
					UITextRange *selectedTextRange = [textField textRangeFromPosition:cursorLocation toPosition:cursorLocation];
					[textField setSelectedTextRange:selectedTextRange];
				}
			}
			
			[self textFieldDidChange:textField];
			
			return result;
		}
	}
	else if (textField == self.textFieldCardDate)
	{
		ASDKTextField *tcsTextField = (ASDKTextField *)textField;
		BOOL result = [tcsTextField shouldChangeCharactersInRange:range replacementString:string];
		
		[self textFieldDidChange:textField];
		return result;
	}
	else if (textField == self.textFieldCardCVC || textField == self.secretCVVTextField)
	{
		ASDKTextField *tcsTextField = (ASDKTextField *)textField;
		if (![tcsTextField shouldChangeCharactersInRange:range replacementString:string])
		{
			NSString *availableString = [self numbersStringFromString:tcsTextField.text];
			
			BOOL result = [tcsTextField shouldChangeCharactersInRange:(NSRange){0, [tcsTextField.text length]} replacementString:availableString];
			
			[self textFieldDidChange:textField];
			return result;
		}
	}
	
	return YES;
}


- (void)updatePaymentSystem
{
	[self updatePaymentSystemWithCardNumber:[self cardNumber]];
}

- (void)updatePaymentSystemWithCardNumber:(NSString *)cardNumber
{
	char firstCardNumberSymbol;
	
	if (cardNumber.length > 0)
		firstCardNumberSymbol = (char)[cardNumber characterAtIndex:0];
	else
		firstCardNumberSymbol = '\0';
	
	ASDKCreditCardType cardType = ASDKCreditCardTypeUnrecognized;
	
	switch (firstCardNumberSymbol)
	{
		case ASDKCreditCardTypeVisa:
		{
			cardType = ASDKCreditCardTypeVisa;
			break;
		}
			
        case ASDKCreditCardTypeMastercard:
		{
			cardType = ASDKCreditCardTypeMastercard;
			break;
		}
		case ASDKCreditCardTypeDiscover:
		{
			cardType = ASDKCreditCardTypeDiscover;
			break;
		}
			
		case ASDKCreditCardTypeMastercard2:
			cardType = ASDKCreditCardTypeMastercard;
		default:
		{
			if ([cardNumber length] >= 4)
			{
				NSString *headNumbers = [cardNumber substringToIndex:4];
				if ([headNumbers length] == 4)
				{
					NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"^220[0-4]" options:NSRegularExpressionCaseInsensitive error:nil];
					
					__block NSTextCheckingType checkingType;
					[regExp enumerateMatchesInString:cardNumber options:0 range:NSMakeRange(0, cardNumber.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
						 checkingType = result.resultType;
					 }];
					
					if (checkingType == NSTextCheckingTypeRegularExpression)
					{
						cardType = ASDKCreditCardTypeMIR;
					}
				}
			}
			break;
		}
	}
	
	_creditCardType = cardType;
}

#pragma mark Input processing

- (void)textFieldDidChange:(UITextField *)textField
{
	if (textField == self.textFieldCardNumber)
	{
		_cardNumberValidationFailed = NO;
		
		[self updateCardNumberTextField];
		[self updatePaymentSystem];
		[self updateInputMasks];
		[self updatePaymentLogo];
		[self updatePlaceholders];
		[self updateButtonsStates];
		
		if (_creditCardType == ASDKCreditCardTypeUnrecognized)
		{
			self.textFieldCardNumber.textColor = [UIColor redColor];
		}
	}
	else if (textField == self.textFieldCardDate)
	{
		_dateValidationFailed = NO;
		
		if (textField.text.length >= 5)
		{
			[textField setTextColor:[self validateDate] ? self.textColor : [UIColor redColor]];
			if ([self validateDate] && [textField isFirstResponder])
			{
				//[textField resignFirstResponder];
				[self.textFieldCardCVC becomeFirstResponder];
			}
			else
				[textField setTextColor:[UIColor redColor]];
		}
		else
			[textField setTextColor:self.textColor];
	}
	
	else if (textField == self.textFieldCardCVC)
	{
		_cvcValidationFailed = NO;
		
		[textField setTextColor:self.textColor];
		
		if ([self validateCVC])
			[textField resignFirstResponder];
	}
    
    else if (textField == self.secretCVVTextField)
    {
        _cvcValidationFailed = NO;
        
        [textField setTextColor:self.textColor];
        
        if ([self validateSecretCVC])
        [textField resignFirstResponder];
    }
	
	id <ASDKCardInputTableViewCellDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(cardInputCellTextDidChange:)])
	{
		[delegate cardInputCellTextDidChange:self];
	}
	
	[self updatePlaceholders];
}



- (void)updateCardNumberTextField
{
	ASDKTextField *textField = self.textFieldCardNumber;
	
	_fullCardNumber = textField.text;
	if (self.textFieldCardNumber.text.length >= self.textFieldCardNumber.inputMask.length)
	{
		[self validateCardNumberAndCollapse];
	}
	else
	{
		[textField setTextColor:self.textColor];
	}
}


- (void)updateButtonsStates
{
	if (_extendedModeEnabled)
	{
		ASDKTextField *textField = self.textFieldCardNumber;
		
		NSString *cardNumber = [self cardNumber];
		
		if (_creditCardType == ASDKCreditCardTypeDiscover || _creditCardType == ASDKCreditCardTypeMIR)
		{
			if (cardNumber.length >= 16)
			{
				if (cardNumber.length <= 22)
				{
					[self setNextButtonHidden:NO animated:YES];
					[self setScanButtonHidden:YES animated:YES];
				}
				else
				{
					[self setNextButtonHidden:YES animated:YES];
					[self setScanButtonHidden:YES animated:YES];
				}
			}
			else if (cardNumber.length > 0)
			{
				[self setNextButtonHidden:YES animated:YES];
				[self setScanButtonHidden:NO animated:YES];
			}
		}
		else if (_fullCardNumber.length >= textField.inputMask.length && [self luhnCheck:self.cardNumber] && _expanded)
		{
			[self setNextButtonHidden:NO animated:YES];
			[self setScanButtonHidden:YES animated:YES];
		}
		else
		{
			[self setNextButtonHidden:YES animated:YES];
			[self setScanButtonHidden:!_expanded animated:YES];
		}
	}
	else
	{
		[self setNextButtonHidden:YES animated:NO];
		[self setScanButtonHidden:NO animated:YES];
	}
}

- (void)updatePaymentLogo
{
	ASDKTextField *textField = self.textFieldCardNumber;
	
	if (textField.text.length >= 1)
	{
		NSString *paymentSystemIconName = [self paymentSystemIconNameForCardType:_creditCardType];
		UIImage *paymentSystemIcon = paymentSystemIconName ? [UIImage imageNamed:paymentSystemIconName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] : nil;
		
		if (paymentSystemIconName)
		{
			[self setPaymentLogoHidden:NO animated:YES];
			[self.imagePaymentLogo setImage:paymentSystemIcon];
		}
		else
		{
			[self setPaymentLogoHidden:YES animated:NO];
			[self.textFieldCardNumber setTextColor:[UIColor redColor]];
		}
	}
	else
	{
		[self setPaymentLogoHidden:YES animated:YES];
	}
}


- (void)updatePlaceholders
{
	NSString *placeholderText = self.placeholderText ? self.placeholderText : @"";
	NSString *cvcPlaceholderText = [self paymentSystemSecurityCodeNameForCardType:_creditCardType];
	
	NSDictionary *cardNumberAttributes = _cardNumberValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	NSDictionary *cardDateAttributes = _dateValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	NSDictionary *cardCVCAttributes = _cvcValidationFailed ? self.invalidPlaceholderAttributes : self.placeholderAttributes;
	
	[self.textFieldCardNumber setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholderText attributes:cardNumberAttributes]];
	[self.textFieldCardDate setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:LOC(@"acq_exp_date_hint") attributes:cardDateAttributes]];
	[self.textFieldCardCVC setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:LOC(cvcPlaceholderText) attributes:cardCVCAttributes]];
    [self.secretCVVTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:LOC(cvcPlaceholderText) attributes:cardCVCAttributes]];
}

#pragma mark Button handling


- (IBAction)buttonAction:(id)sender
{
	if (sender == self.nextButton)
	{
		[self validateCardNumberAndCollapse];
	}
	else if (sender == _buttonInputAccessoryDone)
	{
		[self endEditing:NO];
	}
}

- (void)resetValidationResults
{
	_cvcValidationFailed = NO;
	_dateValidationFailed = NO;
	_cardNumberValidationFailed = NO;
	
	[self updatePlaceholders];
	[self setTextColor:_textColor];
}

#pragma mark Validation

- (BOOL)validateForm
{
    [self resetValidationResults];
    
    if (self.showSecretContainer)
    {
        BOOL isCVCValid = [self validateSecretCVC];
        if (isCVCValid)
        {
            _cvcValidationFailed = YES;
            self.secretCVVTextField.textColor = [UIColor redColor];
        }
        
        [self updatePlaceholders];
        
        return isCVCValid;
    }
    
    if (self.secureModeEnabled)
    {
        BOOL isCVCValid = [self validateCVC];
        if (isCVCValid)
        {
            _cvcValidationFailed = YES;
            self.textFieldCardCVC.textColor = [UIColor redColor];
        }
        
        [self updatePlaceholders];
        
        return isCVCValid;
    }
    
    BOOL isFormValid = YES;
    
    BOOL isCardNumberValid = YES;
    if (_creditCardType == ASDKCreditCardTypeDiscover)
    {
        isCardNumberValid = self.textFieldCardNumber.text.length > 0;
    }
    else if (_creditCardType == ASDKCreditCardTypeUnrecognized)
    {
        isCardNumberValid = NO;
    }
    else
    {
        isCardNumberValid = [self luhnCheck:self.cardNumber];
    }
    
    if (!isCardNumberValid)
    {
        _cardNumberValidationFailed = YES;
        _textFieldCardNumber.textColor = [UIColor redColor];
        
        [self setCardNumberExpanded:YES resetValidationState:NO animated:YES];
    }
    
    isFormValid &= isCardNumberValid;
    
    if (self.extendedModeEnabled)
    {
        BOOL isDateValid = [self validateDate];
        if (!isDateValid)
        {
            _dateValidationFailed = YES;
            self.textFieldCardDate.textColor = [UIColor redColor];
            
            if (isFormValid)
            {
                [self.textFieldCardDate becomeFirstResponder];
                [self setCardNumberExpanded:NO resetValidationState:NO animated:YES];
                [self setNextButtonHidden:YES animated:YES];
                [self setScanButtonHidden:YES animated:YES];
            }
        }
        
        isFormValid &= isDateValid;
        
        BOOL isCVCValid = [self validateCVC];
        if (!isCVCValid)
        {
            _cvcValidationFailed = YES;
            self.textFieldCardCVC.textColor = [UIColor redColor];
            
            if (isFormValid)
            {
                [self.textFieldCardCVC becomeFirstResponder];
                [self setCardNumberExpanded:NO resetValidationState:NO animated:YES];
                [self setNextButtonHidden:YES animated:YES];
                [self setScanButtonHidden:YES animated:YES];
            }
        }
        
        isFormValid &= isCVCValid;
    }
    
    [self updatePlaceholders];
    
    return isFormValid;
}

- (void)validateCardNumberAndCollapse
{
	ASDKTextField *textField = self.textFieldCardNumber;
	BOOL cardNumberIsValid = [self luhnCheck:[self cardNumber]];
	
	if (_expanded)
	{
		if (cardNumberIsValid)
		{
			//[textField resignFirstResponder];
			if (self.extendedModeEnabled && !self.secureModeEnabled)
			{                
                if ([self validateDate])
                {
                    [self.textFieldCardCVC becomeFirstResponder];
                }
                else
                {
                    [self.textFieldCardDate becomeFirstResponder];
                }
			}
			else
			{
				[textField resignFirstResponder];
			}
			
			[textField setTextColor:self.textColor];
			[self setCardNumberExpanded:NO resetValidationState:YES animated:YES];
			[self setNextButtonHidden:YES animated:YES];
			[self setScanButtonHidden:YES animated:YES];
		}
		else
		{
			[textField setTextColor:[UIColor redColor]];
		}
	}
}

- (BOOL)validateCVC
{
	return [self validateString:self.textFieldCardCVC.text inputMask:self.textFieldCardCVC.inputMask];
}

- (BOOL)validateSecretCVC
{
    return [self validateString:self.secretCVVTextField.text inputMask:self.textFieldCardCVC.inputMask];
}

- (BOOL)validateDate
{
	BOOL resultExpirationDate = [self validateString:self.textFieldCardDate.text inputMask:self.textFieldCardDate.inputMask];
	if (resultExpirationDate == YES)
	{
		NSArray *components = [self.textFieldCardDate.text componentsSeparatedByString:@"/"];
		NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnit)(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
		if ([[components objectAtIndex:1] integerValue] < currentDateComponents.year%1000)
		{
			resultExpirationDate = NO;
		}
		else if ([[components objectAtIndex:1] integerValue] == currentDateComponents.year%1000 && [[components objectAtIndex:0] integerValue] < currentDateComponents.month)
		{
			resultExpirationDate = NO;
		}
		else if ([[components objectAtIndex:0] integerValue] > 12)
		{
			resultExpirationDate = NO;
		}
	}
	
	return resultExpirationDate;
}



#pragma mark Internal animated status trans itions


- (void)setPaymentLogoHidden:(BOOL)hidden animated:(BOOL)animated
{
	CGFloat alpha = hidden ? 0 : 1;
	CGFloat width = hidden ? 0 : 30;
	CGFloat numberX = hidden ? 15 : 48;
	CGFloat logoX = hidden ? -30 : 15;
	
	[self.contentView layoutIfNeeded];
	
	if (_paymentLogoHidden != hidden)
	{
		_paymentLogoHidden = hidden;
		
		if(animated)
		{
			__strong __typeof(self) weakSelf = self;
			[UIView animateWithDuration:0.5 animations:^{
				__strong __typeof(self) strongSelf = weakSelf;
				
				strongSelf.imagePaymentLogo.alpha = alpha;
				strongSelf.logoWidthConstraint.constant = width;
				strongSelf.cardNumberXConstraint.constant = numberX;
				strongSelf.logoXConstraint.constant = logoX;
				
				[strongSelf.contentView layoutIfNeeded];
			}];
		}
		else
		{
			self.imagePaymentLogo.alpha = alpha;
			self.logoWidthConstraint.constant = width;
			self.cardNumberXConstraint.constant = numberX;
			self.logoXConstraint.constant = logoX;
		}
	}
}



-(void)setNextButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self setHidden:hidden button:self.nextButton constraint:self.nextButtonXConstraint animated:animated];
}
-(void)setScanButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self setHidden:hidden button:self.cardIOButton constraint:self.cardIOButtonXConstraint animated:animated];
}

- (void)setHidden:(BOOL)hidden button:(UIButton *)button constraint:(NSLayoutConstraint *)constraint animated:(BOOL)animated
{
	UIButton *buttonToHide = nil;
	UIButton *buttonToShow = nil;
	
	NSLayoutConstraint *constraintToHide = nil;
	NSLayoutConstraint *constraintToShow = nil;
	
	const CGFloat kHiddenConstant = -100;
	const CGFloat kVisibleConstant = 12;
	
	if (hidden && (!button.hidden || !animated))
	{
		buttonToHide = button;
		constraintToHide = constraint;
	}
	else if (!hidden && (button.hidden || !animated))
	{
		buttonToShow = button;
		constraintToShow = constraint;
	}
	
	if (buttonToHide || buttonToShow)
	{
		if (animated) {
			[self.contentView layoutIfNeeded];
			
			__strong __typeof(self) weakSelf = self;
			[UIView animateWithDuration:0.5
								  delay:0.0
				 usingSpringWithDamping:1.0
				  initialSpringVelocity:1.0
								options:0
							 animations:^{
								 __strong __typeof(self) strongSelf = weakSelf;
								 
								 [constraintToHide setConstant:kHiddenConstant];
								 [constraintToShow setConstant:kVisibleConstant];
								 
								 [buttonToShow setHidden:NO];
								 
								 [strongSelf.contentView layoutIfNeeded];
							 } completion:^(BOOL finished) {
								
								 if (constraintToHide.constant == kHiddenConstant)
								 {
									  [buttonToHide setHidden:YES];
								 }
							 }];
		}
		else
		{
			[constraintToHide setConstant:kHiddenConstant];
			[constraintToShow setConstant:kVisibleConstant];
			
			[buttonToShow setHidden:NO];
			[buttonToHide setHidden:YES];
			[self.contentView layoutIfNeeded];
		}
	}
}

- (void)setCardNumberExpanded:(BOOL)expanded resetValidationState:(BOOL)reset animated:(BOOL)animated
{
	if (!_extendedModeEnabled)
	{
		expanded = YES;
	}
	
	if (_secureModeEnabled)
	{
		expanded = NO;
	}
	
    if (reset) [self resetValidationResults];
	
	CGFloat viewWidth = self.frame.size.width;
	
	__block CGFloat cvcViewX = self.cardCVCXConstraint.constant;
	__block CGFloat dateViewX = self.cardDateXConstraint.constant;
	__block CGFloat numberViewWidth = self.cardNumberWidthConstraint.constant;
    CGFloat expAndCVVAlpha = 0.0f;
	
	CGFloat maxWidth = self.frame.size.width - 60;
	CGFloat minWidth = 60;
	
	NSString *cardNumberText = self.textFieldCardNumber.text;
	
	if (_expanded == expanded) return;
	
	_expanded = expanded;
	
	if (expanded)
	{
		cvcViewX = -100;
		dateViewX = -(viewWidth / 2 + 100);
		numberViewWidth = maxWidth;
		cardNumberText = self.fullCardNumber;
	}
	else
	{
        expAndCVVAlpha = 1.0f;
		cvcViewX = 8;
		dateViewX = -10;//-[self defaultDateOffset];
		numberViewWidth = minWidth;
		if (self.fullCardNumber)
			cardNumberText = [@"" stringByAppendingString:[self.fullCardNumber substringFromIndex:self.fullCardNumber.length - 4]];
	}
	
	if (cardNumberText)
		self.textFieldCardNumber.text = cardNumberText;
	
	[self.contentView layoutIfNeeded];
	
	if (animated)
	{
		__weak __typeof(self) weakSelf = self;
		[UIView animateWithDuration:0.6
							  delay:0.0
			 usingSpringWithDamping:1.0
			  initialSpringVelocity:1.0
							options:0
						 animations:^{
							 __strong __typeof(self) strongSelf = weakSelf;
							 
							 strongSelf.cardCVCXConstraint.constant = cvcViewX;
							 strongSelf.cardDateXConstraint.constant = dateViewX;
							 strongSelf.cardNumberWidthConstraint.constant = numberViewWidth;
							
                             strongSelf.textFieldCardNumber.text = cardNumberText;
                             
                             strongSelf.textFieldCardDate.alpha = expAndCVVAlpha;
                             strongSelf.textFieldCardCVC.alpha = expAndCVVAlpha;
                             
							 [strongSelf.contentView layoutIfNeeded];
						 } completion:nil];
	}
	else
	{
		self.cardCVCXConstraint.constant = cvcViewX;
		self.cardDateXConstraint.constant = dateViewX;
		self.cardNumberWidthConstraint.constant = numberViewWidth;
        
        self.textFieldCardDate.alpha = expAndCVVAlpha;
        self.textFieldCardCVC.alpha = expAndCVVAlpha;
		
		[self.contentView layoutIfNeeded];
	}
}

#pragma mark Payment system detection

- (void)updateInputMasks
{
	NSString *cardNumber = [self cardNumber];
	[self updateInputMasksWithCardNumber:cardNumber];
}

- (void)updateInputMasksWithCardNumber:(NSString *)cardNumber
{
	switch (_creditCardType)
	{
            
		case ASDKCreditCardTypeVisa:
		{
			self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskVisa;
			break;
		}
			
		case ASDKCreditCardTypeMastercard:
		{
			self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMasterCard;
			break;
		}
            
        case ASDKCreditCardTypeMIR:
        {
            if (cardNumber.length <= 16)
            {
                self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMIR16;
            }
            else if (cardNumber.length <= 18)
            {
                self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMIR18;
            }
            else
            {
                self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMIR19;
            }
            
            break;
        }

		case ASDKCreditCardTypeDiscover:
		{
			if (cardNumber.length <= 16)
			{
				self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMaestro16;
			}
			else if (cardNumber.length <= 19)
			{
				self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMaestro19;
			}
			else
			{
				self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputMaskMaestro22;
			}
			
			break;
		}
            
		default:
		{
			self.textFieldCardNumber.inputMask = ASDKCreditCardPaymentSystemInputDefault;
			break;
		}
	}
    
    [self.textFieldCardCVC setInputMask:@"___"];
}

- (NSString *)paymentSystemSecurityCodeNameForCardType:(ASDKCreditCardType)creditCardType
{
	NSString *securityCodeName;
	
	switch (creditCardType)
	{
		case ASDKCreditCardTypeVisa:
			securityCodeName = @"CVV";
			break;
			
		case ASDKCreditCardTypeMIR:
		case ASDKCreditCardTypeMastercard:
		case ASDKCreditCardTypeDiscover:
			securityCodeName = @"CVC";
			break;
			
		default:
			securityCodeName = @"CVC";
			break;
	}
	
	return securityCodeName;
}


- (NSString *)paymentSystemIconNameForCardType:(ASDKCreditCardType)creditCardType
{
	NSString *iconName;
	
	switch (creditCardType)
	{
		case ASDKCreditCardTypeVisa:
			iconName = _useDarkIcons ? @"psIconVisa" : @"psIconVisa_White";
			break;

		case ASDKCreditCardTypeMastercard:
			iconName = @"psIconMastercard";
			break;
			
		case ASDKCreditCardTypeDiscover:
			iconName = @"psIconMaestro";
			break;
			
		case ASDKCreditCardTypeMIR:
			iconName = @"psIconMir";
			break;

		default:
			if (self.textFieldCardNumber.text.length == 0)
			{
				iconName = @"psIcons";
			}
			break;
	}
	
	return iconName;
}

- (NSString *)numbersStringFromString:(NSString *)string
{
    if ([string length] >0)
    {
        static NSCharacterSet *nonDecimalDigitCharacterSet_ = nil;
        @synchronized(self)
        {
            if (nonDecimalDigitCharacterSet_ == nil)
            {
                nonDecimalDigitCharacterSet_ = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            }
            
            return [[string componentsSeparatedByCharactersInSet:nonDecimalDigitCharacterSet_] componentsJoinedByString:@""];
        }
    }
    
    return @"";
}

- (BOOL)validateString:(NSString *)text inputMask:(NSString *)mask
{
    NSCharacterSet *maskCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *nonFormatText = [[text componentsSeparatedByCharactersInSet:[maskCharacterSet invertedSet]] componentsJoinedByString:@""];
    maskCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"_"];
    NSString *nonFormatMask = [[mask componentsSeparatedByCharactersInSet:[maskCharacterSet invertedSet]] componentsJoinedByString:@""];
    
    if ([nonFormatText length] == [nonFormatMask length])
        return YES;
    
    return NO;
}

#pragma mark - Helpers

- (NSMutableArray *)toCharArray:(NSString *)string
{
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[string length]];
    for (NSUInteger i=0; i < [string length]; i++)
    {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        [characters addObject:ichar];
    }
    
    return characters;
}

- (BOOL)luhnCheck:(NSString *)stringToTest
{
    if (![stringToTest length])
    {
        return NO;
    }
    
    NSMutableArray *stringAsChars = [self toCharArray:stringToTest];
    
    BOOL isOdd = YES;
    int oddSum = 0;
    int evenSum = 0;
    
    for (NSInteger i = (NSInteger)[stringToTest length] - 1; i >= 0; i--) {
        
        int digit = [(NSString *)[stringAsChars objectAtIndex:(NSUInteger)i] intValue];
        
        if (isOdd)
            oddSum += digit;
        else
            evenSum += digit/5 + (2*digit) % 10;
        
        isOdd = !isOdd;
    }
    
    return ((oddSum + evenSum) % 10 == 0);
}

@end
