//
//  ASDKPaymentViewController.m
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


#import "ASDKPaymentFormViewController.h"
#import <WebKit/WebKit.h>
#import "ASDKPaymentFormHeaderCell.h"
#import "ASDKPaymentFormSummCell.h"

#import "ASDKExternalCardsCell.h"

#import "ASDKEmailCell.h"

#import "ASDKPayButtonCell.h"

#import "ASDKFooterCell.h"

#import "ASDK3DSViewController.h"

#import "ASDKMacroses.h"

#import "ASDKUtils.h"
#import "ASDKDesign.h"

#import "ASDKPaymentFormStarter.h"

#import "ASDKCardsListViewController.h"

#import "ASDKNavigationController.h"
#import "ASDKLoaderViewController.h"

#import "ASDKBarButtonItem.h"

#import "ASDKCardsListDataController.h"
#import "ASDKEmptyTableViewCell.h"
#import "ASDKLocalized.h"

#define kASDKEmailRegexp @"[\\w_.-]+@[\\w_.-]+\\.[a-zA-Z]+"

NSString * const kTCSRubNoDotCap = @"₽";
NSString * const kCurrencyCode = @"RUB";
NSString * const kDecimalSeparator = @",";

NSUInteger const CellPyamentCardID = CellEmptyFlexibleSpace + 1;

@interface ASDKPaymentFormViewController () <UITextFieldDelegate, ASDKCardsListDelegate>
{
    NSNumber *_amount;
    NSString *_orderId;
    NSString *_paymentTitle;
    NSString *_paymentDescription;
    NSString *_cardIdPriorityPass;
    NSString *_email;
    NSString *_customerKey;
	BOOL	_requrent;
	
    BOOL _shouldShowKeyboardWhenNewCardSelected;
	BOOL _needSetupCardRequisitesCellForCVC;
}

@property (nonatomic, strong) ASDKPaymentFormHeaderCell *headerCell;
@property (nonatomic, strong) ASDKPaymentFormSummCell *summCell;
@property (nonatomic, strong) ASDKExternalCardsCell *externalCardsCell;
@property (nonatomic, strong) ASDKCardInputTableViewCell *cardRequisitesCell;
@property (nonatomic, strong) ASDKEmailCell *emailCell;
@property (nonatomic, strong) ASDKPayButtonCell *paymentButtonCell;
@property (nonatomic, strong) ASDKFooterCell *footerCell;

@property (nonatomic, strong) void (^onSuccess)(ASDKPaymentInfo *paymentInfo);
@property (nonatomic, strong) void (^onCancelled)(void);
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKCard *selectedCard;
@property (nonatomic, strong) NSDictionary *additionalPaymentData;
@property (nonatomic, strong) NSDictionary *receiptData;
@property (nonatomic, strong) NSArray *shopsData;
@property (nonatomic, strong) NSArray *shopsReceiptsData;

@property (nonatomic, assign) BOOL updateCardCell;
@property (nonatomic, assign) BOOL makeCharge;

@property (nonatomic, strong) NSArray *tableViewDataSource;
@property (nonatomic, strong) UIView *customSecureLogo;

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) BOOL chargeError;
@property (nonatomic, copy) NSString *chargeErrorPaymentId;

@property (nonatomic, assign) BOOL needCheck3DS2;

@end

@implementation ASDKPaymentFormViewController

#pragma mark - Init

- (instancetype)initWithAmount:(NSNumber *)amount
                       orderId:(NSString *)orderId
                         title:(NSString *)title
                   description:(NSString *)description
                        cardId:(NSString *)cardId
                         email:(NSString *)email
				   customerKey:(NSString *)customerKey
					 recurrent:(BOOL)recurrent
					makeCharge:(BOOL)makeCharge
		 additionalPaymentData:(NSDictionary *)data
				   receiptData:(NSDictionary *)receiptData
					 shopsData:(NSArray *)shopsData
			 shopsReceiptsData:(NSArray *)shopsReceiptsData
                       success:(void (^)(ASDKPaymentInfo *paymentInfo))success
                     cancelled:(void (^)(void))cancelled
                         error:(void (^)(ASDKAcquringSdkError *error))error
{
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self)
    {
        _paymentTitle = title;
        _amount = amount;
        _orderId = orderId;
        _paymentDescription = description;
        _cardIdPriorityPass = cardId;
        _email = email;
        _onSuccess = success;
        _onCancelled = cancelled;
        _onError = error;
        _customerKey = customerKey;
		_requrent = recurrent;
		_additionalPaymentData = data;
		_receiptData = receiptData;
		_shopsData = shopsData;
		_shopsReceiptsData = shopsReceiptsData;
		_updateCardCell = NO;
		_makeCharge = makeCharge;
		_chargeError = NO;
		_needSetupCardRequisitesCellForCVC = NO;
		_needCheck3DS2 = YES;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = LOC(@"acq_screen_title");
	
	[self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.presentationController.delegate = self;
	
	self.tableView.sectionHeaderHeight = 0;
	self.tableView.sectionFooterHeight = 0;
	self.tableView.estimatedSectionHeaderHeight = 0;
	self.tableView.estimatedSectionFooterHeight = 0;
	self.tableView.rowHeight = 0;
	
    [self.tableView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
	[self.tableView registerNib:[UINib nibWithNibName:@"ASDKEmptyTableViewCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"ASDKEmptyTableViewCell"];
	[self.tableView registerNib:[UINib nibWithNibName:@"ASDKPaymentFormHeaderCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"ASDKPaymentFormHeaderCell"];

	self.keyboardHeight = 0;

    ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"acq_btn_cancel")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
    ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
	if ([designConfiguration payViewTitle] != nil)
	{
		self.title = [designConfiguration payViewTitle];
	}
	
	self.customSecureLogo = designConfiguration.paymentsSecureLogosView;
	
    cancelButton.tintColor = [designConfiguration navigationBarItemsTextColor];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
	
	if (designConfiguration.customBackButton)
	{
		[self.navigationItem setLeftBarButtonItem:nil];
		
		UIBarButtonItem *button = designConfiguration.customBackButton;
		[button setAction:@selector(cancelAction:)];
		[button setTarget:self];

		[self.navigationItem setLeftBarButtonItem:button];
	}

	NSMutableArray *dataSource = [NSMutableArray new];
	if (designConfiguration.payFormItems != nil)
	{
		[dataSource addObjectsFromArray:designConfiguration.payFormItems];
	}

	if ([dataSource count] == 0)
	{
		[dataSource addObjectsFromArray:@[@(CellProductTitle),
										  @(CellProductDescription),
										  @(CellAmount),
										  @(CellPaymentCardRequisites),
										  @(CellEmail),
										  @(CellPayButton),
										  @(CellSecureLogos)
										  ]];
	}

	self.tableViewDataSource = [dataSource copy];
	
    [self updateExternalCardsList];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.updateCardCell == YES)
	{
		self.updateCardCell = NO;
		[self updateSelectedExternalCardOnStart];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	if ( self.isMovingFromParentViewController || self.isBeingDismissed)
	{
		if (self.onCancelled)
		{
			self.onCancelled();
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	self.keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	
	[self updateFlexibleSpace];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	self.keyboardHeight = 0;
	
	[self updateFlexibleSpace];
}

- (void)updateFlexibleSpace
{
	NSMutableArray<NSIndexPath *> *paths = [NSMutableArray new];
	for (NSInteger index = 0; index < [self.tableViewDataSource count]; index++)
	{
		NSNumber *number = [self.tableViewDataSource objectAtIndex:index];
		if ([number integerValue] == CellEmptyFlexibleSpace)
		{
			[paths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
		}
	}
	
	if ([paths count] > 0)
	{
		[self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)updateExternalCardsList
{
    if (_customerKey.length > 0)
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
		
		__weak typeof(self) weakSelf = self;
		
		[[ASDKCardsListDataController instance] updateCardsListWithSuccessBlock:^
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			
			__strong typeof(self) strongSelf = weakSelf;
			
			if (strongSelf)
			{
				[strongSelf updateSelectedExternalCardOnStart];
			}
		}
																	 errorBlock:^(ASDKAcquringSdkError *error)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			
			__strong typeof(self) strongSelf = weakSelf;
			
			if (strongSelf)
			{
				[strongSelf updateSelectedExternalCardOnStart];
			}
		}];
    }
}

- (void)updateSelectedExternalCardOnStart
{
	if ([self filterCardList:[[ASDKCardsListDataController instance] externalCards]].count > 0)
    {
		NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.tableViewDataSource];
		NSUInteger index = [dataSource indexOfObjectIdenticalTo:@(CellPaymentCardRequisites)];
		if (index != NSNotFound && [dataSource indexOfObjectIdenticalTo:@(CellPyamentCardID)] == NSNotFound)
		{
			[dataSource insertObject:@(CellPyamentCardID) atIndex:index];
			self.tableViewDataSource = [dataSource copy];
		}

		ASDKCard *card = _selectedCard;

		if (_selectedCard == nil)
		{
			if (_cardIdPriorityPass != nil)
			{
				card = [[ASDKCardsListDataController instance] cardWithIdentifier:_cardIdPriorityPass];
			}

			if (_makeCharge == YES && card == nil && _cardIdPriorityPass != nil)
			{
				card = [[ASDKCardsListDataController instance] cardWithIdentifier:_cardIdPriorityPass];
				if (card.rebillId == nil)
				{
					card = [[ASDKCardsListDataController instance] cardWithRebillId];
				}
			}
			else if (card == nil && _cardIdPriorityPass != nil && _cardIdPriorityPass.length == 0)
			{
				card = [[[ASDKCardsListDataController instance] externalCards] firstObject];
			}

			[self setSelectedCard:card];
			
			if (card == nil)
			{
				_shouldShowKeyboardWhenNewCardSelected = YES;
			}
		}
    }
	else
	{
		[self setSelectedCard:nil];
		NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.tableViewDataSource];
		
		NSUInteger index = [dataSource indexOfObjectIdenticalTo:@(CellPyamentCardID)];
		if (index != NSNotFound)
		{
			[dataSource removeObjectAtIndex:index];
			self.tableViewDataSource = [dataSource copy];
		}
	}

	[self.tableView reloadData];

	if (_needSetupCardRequisitesCellForCVC == YES)
	{
		self.makeCharge = NO;
		self.chargeError = YES;
		[[self cardRequisitesCell] setupForCVCInput];
		[[self cardRequisitesCell] setUserInteractionEnabled:YES];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[[self cardRequisitesCell] secretCVVTextField] becomeFirstResponder];
		});

		_needSetupCardRequisitesCellForCVC = NO;
	}
}

#pragma mark - ASDKCustomKeyboardInputDelegate

- (void)didEnterNumber:(NSNumber *)number
{
    if ([self shouldShowCustomKeyboardOnKeyboardNotification])
    {
        UITextField *textField = [self secretTextFieldResponder];
        NSRange range = [(ASDKTextField *)textField selectedRange];
        
        [self.cardRequisitesCell textField:textField shouldChangeCharactersInRange:range replacementString:[number stringValue]];
    }
}

- (void)didPressOnDeleteButton
{
    NSString *text = [self secretTextFieldResponder].text;
    UITextField *textField = [self secretTextFieldResponder];
    
    NSRange range;
    if (textField.text.length > 0)
    {
        range = NSMakeRange(text.length - 1, 1);
        
        NSRange selectedRange = [(ASDKTextField *)textField selectedRange];
        
        if (selectedRange.location != NSNotFound)
        {
			if (selectedRange.location > 0)
			{
				range.location = selectedRange.location - 1;
			}
			else
			{
				range.location = 0;
			}
        }
		
		if (selectedRange.length > 0)
		{
			range.length = selectedRange.length;
		}
        
        [self.cardRequisitesCell textField:textField shouldChangeCharactersInRange:range replacementString:@""];
    }
    else
    {
        if ([self secretTextFieldResponder] == self.cardRequisitesCell.textFieldCardCVC)
        {
            [self.cardRequisitesCell.textFieldCardDate becomeFirstResponder];
        }
        else if ([self secretTextFieldResponder] == self.cardRequisitesCell.textFieldCardDate)
        {
            [self.cardRequisitesCell.textFieldCardNumber becomeFirstResponder];
        }
    }
}
 
#pragma mark - Setters

- (void)setSelectedCard:(ASDKCard *)selectedCard
{
    _selectedCard = selectedCard;
    
    if (_selectedCard)
    {
        NSString *cardNumber = _selectedCard.pan;
		
		if (_selectedCard.rebillId != nil)
		{
			[self updateCardRequisitesCellWithCardRequisites:cardNumber expiredData:nil];
			[[self cardRequisitesCell] setUserInteractionEnabled:NO];
			[self cardRequisitesCell].showSecretContainer = NO;
			[[self cardRequisitesCell] setScanButtonHidden:YES animated:NO];

			[[self cardRequisitesCell] setCardNumber:cardNumber];
			[[[self cardRequisitesCell] textFieldCardNumber] setText:cardNumber];
			if (@available(iOS 13.0, *)) {
                [[[self cardRequisitesCell] textFieldCardNumber] setTextColor:[UIColor labelColor]];
            } else {
                [[[self cardRequisitesCell] textFieldCardNumber] setTextColor:[UIColor blackColor]];
            }
		}
		else
		{
			[[self cardRequisitesCell] setUserInteractionEnabled:YES];
			[self updateCardRequisitesCellWithCardRequisites:cardNumber expiredData:nil];
			[self cardRequisitesCell].showSecretContainer = YES;
		}
		
        [self externalCardsCell].titleLabel.text = LOC(@"acq_saved_card_label");
		
        if (_shouldShowKeyboardWhenNewCardSelected)
        {
            //[[self cardRequisitesCell].secretCVVTextField becomeFirstResponder];
        }
        else
        {
            //_shouldShowKeyboardWhenNewCardSelected = YES;
        }
    }
    else
    {
		[[self cardRequisitesCell] setUserInteractionEnabled:YES];
        [[self cardRequisitesCell].textFieldCardCVC setText:@""];
        [[self cardRequisitesCell].textFieldCardDate setText:@""];
        [self updateCardRequisitesCellWithCardRequisites:@"" expiredData:nil];
        [[self cardRequisitesCell].textFieldCardNumber setText:@""];
        
        [self cardRequisitesCell].showSecretContainer = NO;
        
        [self externalCardsCell].titleLabel.text = LOC(@"acq_new_card_label");
        
        if (_shouldShowKeyboardWhenNewCardSelected)
        {
            [[self cardRequisitesCell].textFieldCardNumber becomeFirstResponder];
        }
        else
        {
            _shouldShowKeyboardWhenNewCardSelected = YES;
        }
    }
    
    [self cardRequisitesCell].shouldShowTopSeparator = ![self shouldShowExternalCardsCell];
}

- (IBAction)cancelAction:(id)sender
{
    [self closeSelfWithCompletion:^{
		
    }];
}


#pragma mark - Getters

- (ASDKPaymentFormHeaderCell *)headerCell
{
    if (!_headerCell)
    {
        _headerCell = [ASDKPaymentFormHeaderCell cell];
        _headerCell.titleLabel.text = _paymentTitle;
        _headerCell.descriptionLabel.text = _paymentDescription;
        
        [_headerCell layoutIfNeeded];
    }
    
    return _headerCell;
}

- (ASDKPaymentFormSummCell *)summCell
{
    if (!_summCell)
    {
        _summCell = [ASDKPaymentFormSummCell cell];
        _summCell.summLabel.text = [self stringFromAmount:_amount];
        _summCell.shouldShowTopSeparator = YES;
    }
    
    return _summCell;
}

- (ASDKExternalCardsCell *)externalCardsCell
{
    if (!_externalCardsCell)
    {
        _externalCardsCell = [ASDKExternalCardsCell cell];
        [_externalCardsCell.changeCardButton addTarget:self action:@selector(openCardsList) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _externalCardsCell;
}

- (ASDKCardInputTableViewCell *)cardRequisitesCell
{
    if (!_cardRequisitesCell)
    {
        _cardRequisitesCell = [ASDKCardInputTableViewCell cell];
        [_cardRequisitesCell.cardIOButton setBackgroundColor:[UIColor clearColor]];
        [_cardRequisitesCell.saveCardContainer setHidden:YES];
        if (@available(iOS 13.0, *)) {
            _cardRequisitesCell.contentView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
            _cardRequisitesCell.contentView.backgroundColor = [UIColor whiteColor];
        }
        [_cardRequisitesCell setPlaceholderText:LOC(@"acq_title_card_number")];
        [_cardRequisitesCell setUseDarkIcons:YES];
        
        id<ASDKAcquiringSdkCardScanner> cardScanner = [[ASDKPaymentFormStarter instance] cardScanner];
        
        if (cardScanner && [cardScanner respondsToSelector:@selector(scanCardSuccess:failure:cancel:)])
        {
            _cardRequisitesCell.cardIOButton.alpha = 1;
            [_cardRequisitesCell.cardIOButton addTarget:self
                                                 action:@selector(cardIOButtonPressed:)
                                       forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            _cardRequisitesCell.cardIOButton.alpha = 0;
        }
        
        [_cardRequisitesCell setTextColor:[ASDKDesign colorTextDark]];
        [_cardRequisitesCell setPlaceholderColor:[ASDKDesign colorTextPlaceholder]];
    }

    return _cardRequisitesCell;
}

- (ASDKEmailCell *)emailCell
{
    if (!_emailCell)
    {
        _emailCell = [ASDKEmailCell cell];
		[_emailCell.emailTextField setPlaceholder:LOC(@"acq_email_hint")];
		[_emailCell.emailTextField setText:_email];
        [_emailCell.emailTextField setDelegate:self];
    }
    
    return _emailCell;
}

- (ASDKPayButtonCell *)paymentButtonCell
{
    if (!_paymentButtonCell)
    {
        _paymentButtonCell = [ASDKPayButtonCell cell];
    }
    
    return _paymentButtonCell;
}

- (ASDKFooterCell *)footerCell
{
    if (!_footerCell)
    {
        _footerCell = [ASDKFooterCell cell];
    }
    
    return _footerCell;
}

#pragma mark - on charge error

- (void)needSetupCardRequisitesCellForCVC
{
	self.updateCardCell = YES;
	_needSetupCardRequisitesCellForCVC = YES;
}

#pragma mark - button action

- (void)buttonPayAction:(UIButton *)button
{
	[self performPayment];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITextField *emailTextField = [self emailCell].emailTextField;
    if ([textField isEqual:emailTextField])
    {
        UIColor *textColor = [UIColor blackColor];
        if (@available(iOS 13.0, *)) {
            textColor = [UIColor labelColor];
        }
        [textField setTextColor:[self validateEmail] ? textColor : [UIColor redColor]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITextField *emailTextField = [self emailCell].emailTextField;
    if ([textField isEqual:emailTextField])
    {
        UIColor *textColor = [UIColor blackColor];
        if (@available(iOS 13.0, *)) {
            textColor = [UIColor labelColor];
        }
        [textField setTextColor:[self validateEmail] ? textColor : [UIColor redColor]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *emailTextField = [self emailCell].emailTextField;
    if ([textField isEqual:emailTextField])
    {
        if (@available(iOS 13.0, *)) {
            [textField setTextColor:[UIColor labelColor]];
        } else {
            [textField setTextColor:[UIColor blackColor]];
        }
    }
    
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	switch ([[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue])
	{
  		case CellProductTitle:
			{
				ASDKPaymentFormHeaderCell *cellTitle = [tableView dequeueReusableCellWithIdentifier:@"ASDKPaymentFormHeaderCell"];
				cellTitle.titleLabel.text = _paymentTitle;
				cellTitle.descriptionLabel.text = nil;
				[cellTitle layoutIfNeeded];
				cell = cellTitle;
			}
			break;

		case CellProductDescription:
			{
				ASDKPaymentFormHeaderCell *cellTitle = [tableView dequeueReusableCellWithIdentifier:@"ASDKPaymentFormHeaderCell"];
				cellTitle.titleLabel.text = nil;
				cellTitle.descriptionLabel.text = _paymentDescription;
				[cellTitle layoutIfNeeded];
				cell = cellTitle;
			}
			break;

		case CellAmount:
			cell = [self summCell];
			break;

		case CellEmail:
			cell = [self emailCell];
			break;

		case CellSecureLogos:
			cell = [self footerCell];
			[[self footerCell] setCustomSecureLogos:self.customSecureLogo];
			break;

		case CellPayButton:
			{
				ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
				ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
				if (designConfiguration.customPayButton == nil)
				{
					ASDKPayButtonCell *paymentButtonCell = [self paymentButtonCell];
					
					[paymentButtonCell setButtonTitle:designConfiguration.payButtonTitle];
					[paymentButtonCell setAttributedButtonTitle:designConfiguration.payButtonAttributedTitle];
					
					cell = paymentButtonCell;
				}
				else
				{
					cell = [tableView dequeueReusableCellWithIdentifier:@"ASDKEmptyTableViewCell" forIndexPath:indexPath];
					[designConfiguration.customPayButton setCenter:cell.contentView.center];
					[cell.contentView addSubview:designConfiguration.customPayButton];
					
					[designConfiguration.customPayButton addTarget:self action:@selector(buttonPayAction:) forControlEvents:UIControlEventTouchUpInside];
				}
			}
			break;

		case CellPyamentCardID:
			cell = [self externalCardsCell];
			break;

		case CellPaymentCardRequisites:
			cell = [self cardRequisitesCell];
			break;
		
		case CellEmpty20px:
		case CellEmpty5px:
		case CellEmptyFlexibleSpace:
  		default:
			cell = [tableView dequeueReusableCellWithIdentifier:@"ASDKEmptyTableViewCell"];
			break;
	}
	
	if (indexPath.row > 0)
	{
		NSInteger index = [[self.tableViewDataSource objectAtIndex:indexPath.row-1] integerValue];
		NSInteger index1 = [[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue];
		if ((index == CellProductTitle || index == CellProductDescription || index == CellEmpty20px || index == CellEmpty5px || index == CellEmptyFlexibleSpace) &&
		   (index1 != CellProductDescription && index1 != CellEmpty20px && index1 != CellEmpty5px && index1 != CellEmptyFlexibleSpace))
		{
			if ([cell isKindOfClass:[ASDKBaseCell class]] && [cell respondsToSelector:@selector(shouldShowTopSeparator)])
			{
				ASDKBaseCell *baseCell = (ASDKBaseCell *)cell;
				baseCell.shouldShowTopSeparator = YES;
			}
		}
		else
		{
			if ([cell isKindOfClass:[ASDKBaseCell class]] && [cell respondsToSelector:@selector(shouldShowTopSeparator)])
			{
				ASDKBaseCell *baseCell = (ASDKBaseCell *)cell;
				baseCell.shouldShowTopSeparator = NO;
			}
		}
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue] == CellPayButton )
	{
		[self performPayment];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 0;

	switch ([[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue])
	{
		case CellProductTitle:
			self.headerCell.titleLabel.text = _paymentTitle;
			self.headerCell.descriptionLabel.text = nil;//_paymentDescription;
			result = [self.headerCell cellHeightWithSuperviewWidth:self.view.frame.size.width];
			break;
			
		case CellProductDescription:
			self.headerCell.titleLabel.text = nil;//_paymentTitle;
			self.headerCell.descriptionLabel.text = _paymentDescription;
			result = [self.headerCell cellHeightWithSuperviewWidth:self.view.frame.size.width];
			break;
			
		case CellSecureLogos:
			if (self.customSecureLogo)
			{
				result = self.customSecureLogo.frame.size.height;
			}
			else
			{
				result = 44.0f;
			}

			break;
			
		case CellPaymentCardRequisites:
			result = 44.0f;
			break;
			
		case CellAmount:
		case CellEmail:
			result = 44.0f;
			break;
			
		case CellPayButton:
			{
				ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
				ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
				if (designConfiguration.customPayButton == nil)
				{
					result = 44.0f;
				}
				else
				{
					result = designConfiguration.customPayButton.frame.size.height;
				}
			}
			break;
			
		case CellEmpty20px:
			result = 20.0f;
			break;
			
		case CellEmpty5px:
			result = 5.0f;
			break;
			
		case CellEmptyFlexibleSpace:
			{
				CGFloat height = 0;
				NSInteger count = 0;
				for ( NSInteger index = 0; index < [self.tableViewDataSource count]; index++)
				{
					NSNumber *number = [self.tableViewDataSource objectAtIndex:index];
					if ([number integerValue] != CellEmptyFlexibleSpace)
					{
						height += [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
					}
					else
					{
						count++;
					}
				}
				
				if (count == 0) { count = 1; }
				
				result = (tableView.frame.size.height - height - self.keyboardHeight) / count;
				
				if (@available(iOS 11, *))
				{
					result -= self.view.safeAreaInsets.bottom;
				}
				
				if (result < 0)
				{
					result = 0;
				}
			}
			break;

		default:
			result = 44.0f;
			break;
	}

	return result;
}


- (void)cardIOButtonPressed:(id)sender
{
    [self scanCard];
}

- (void)updateCardRequisitesCellWithCardRequisites:(NSString *)cardNumber expiredData:(NSString *)expiredData
{
    [[self cardRequisitesCell].textFieldCardNumber setText:@""];
    [[self cardRequisitesCell] setCardNumber:cardNumber];
	[[[self cardRequisitesCell] textFieldCardDate] setText:expiredData];
    [[self cardRequisitesCell] textField:[self cardRequisitesCell].textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:cardNumber];
}

- (void)scanCard
{
    [self.view endEditing:YES];
    
    id<ASDKAcquiringSdkCardScanner> cardScanner = [[ASDKPaymentFormStarter instance] cardScanner];
    
    if (cardScanner && [cardScanner respondsToSelector:@selector(scanCardSuccess:failure:cancel:)])
    {
        __weak typeof(self) weakSelf = self;

		[cardScanner scanCardSuccess:^(id<ASDKAcquiringSdkCardRequisites> cardRequisites) {
			__strong typeof(weakSelf) strongSelf = weakSelf;
			
			if (strongSelf)
			{
				[strongSelf updateCardRequisitesCellWithCardRequisites:cardRequisites.cardNumber expiredData:cardRequisites.cardExpireDate];
			}
		} failure:nil cancel:nil];
    }
}

#pragma mark - Payment request

- (void)performInitRequest
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];

    NSNumber *realAmount = [NSNumber numberWithDouble:100 * _amount.doubleValue];
    
    __weak typeof(self) weakSelf = self;
	
	NSMutableDictionary *paymentData = [[NSMutableDictionary alloc] init];
	if ([_additionalPaymentData count])
	{
		[paymentData addEntriesFromDictionary:_additionalPaymentData];
	}
	
	if (self.selectedCard && self.selectedCard.rebillId && self.makeCharge == YES && self.chargeError == NO)
	{
		[paymentData setObject:@(YES) forKey:@"chargeFlag"];
	}
	
	if (self.chargeError == YES && self.chargeErrorPaymentId.length > 0)
	{
		[paymentData setObject:self.chargeErrorPaymentId forKey:@"failMapiSessionId"];
		[paymentData setObject:@(12) forKey:@"recurringType"];
	}
	
    [self.acquiringSdk initWithAmount:realAmount
                              orderId:_orderId
                          description:nil
							  payForm:nil
                          customerKey:_customerKey
							recurrent:_requrent
				additionalPaymentData:[paymentData copy]
						  receiptData:_receiptData
							shopsData:_shopsData
					shopsReceiptsData:_shopsReceiptsData
							 location:ASDKLocalized.sharedInstance.localeIdentifier
                              success:^(ASDKInitResponse *response)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf performFinishAuthorizeRequestWithPaymentId:response];
        }
    }
                              failure:^(ASDKAcquringSdkError *error)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf manageError:error];
        }
    }];
}

- (void)performFinishChargeWithPayment:(ASDKInitResponse *)payment
{
	__weak typeof(self) weakSelf = self;
	[self.acquiringSdk chargeWithPaymentId:payment.paymentId rebillId:self.selectedCard.rebillId success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		__strong typeof(weakSelf) strongSelf1 = weakSelf;
		if (strongSelf1)
		{
			[strongSelf1 manageSuccessWithPaymentInfo:paymentInfo];
		}
	} failure:^(ASDKAcquringSdkError *error) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		
		if (strongSelf)
		{
			ASDKAcquiringResponse *errorResponse = [error.userInfo objectForKey:@"acquringResponse"];
			//пользователю необходимо подтвердить платеж через ввод cvc ASDK-432
			//ErrorCode == 104
			if ([[errorResponse.dictionary objectForKey:@"ErrorCode"] integerValue] == 104)
			{
				strongSelf.makeCharge = NO;
				strongSelf.chargeError = YES;
				strongSelf.chargeErrorPaymentId = [errorResponse.dictionary objectForKey:@"PaymentId"];
				[[strongSelf cardRequisitesCell] setupForCVCInput];
				[[strongSelf cardRequisitesCell] setUserInteractionEnabled:YES];
				[[[strongSelf cardRequisitesCell] secretCVVTextField] becomeFirstResponder];
			}
			else
			{
				[strongSelf manageError:error];
			}
		}
	}];
}

- (void)confirmPaymentBy3dsCheckingWithCard:(ASDKThreeDsData *)data paymentInfo:(ASDKPaymentInfo *)paymentInfo
{
	ASDK3DSViewController *threeDsController = [[ASDK3DSViewController alloc] initWithPaymentId:paymentInfo.paymentId threeDsData:data acquiringSdk:self.acquiringSdk];
	
	__weak typeof(self) weakSelf = self;

	[threeDsController showFromViewController:self success:^(NSString *paymentId) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf manageSuccessWithPaymentInfo:paymentInfo];
	} failure:^(ASDKAcquringSdkError *statusError) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf manageError:statusError];
	} cancel:^() {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf closeSelfWithCompletion:strongSelf.onCancelled];
	}];
}

- (NSDictionary *)threeDSMethodCheckURL:(NSString *)threeDSMethodURL tdsServerTransID:(NSString *)tdsServerTransID
{
	if (threeDSMethodURL != nil && tdsServerTransID != nil)
	{
		WKWebViewConfiguration *wkWebConfig = [WKWebViewConfiguration new];
		WKWebView *webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration: wkWebConfig];
		[webView setHidden:true];
		[self.view addSubview:webView];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:threeDSMethodURL]];
		request.timeoutInterval = _acquiringSdk.apiRequestsTimeoutInterval;
		[request setHTTPMethod: @"POST"];
		[request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];

		NSString *threeDSMethodNotificationURL = [NSString stringWithFormat:@"%@%@", [self.acquiringSdk domainPath_v2], kASDKComplete3DSMethodv2];
		NSString *paramsString = [NSString stringWithFormat:@"{\"threeDSServerTransID\":\"%@\",\"threeDSMethodNotificationURL\":\"%@\"}", tdsServerTransID, threeDSMethodNotificationURL];
		NSData *plainData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
		NSString *postString = [NSString stringWithFormat:@"%@", [plainData base64EncodedStringWithOptions:0]];
		NSData *postData = [[NSString stringWithFormat:@"threeDSMethodData=%@", postString] dataUsingEncoding: NSUTF8StringEncoding];
		[request setHTTPBody: postData];
		[webView loadRequest:request];
	}
	
	if (threeDSMethodURL != nil || tdsServerTransID != nil)
	{
		NSString *cresCallbackUrl = [NSString stringWithFormat:@"%@%@", [self.acquiringSdk domainPath_v2], kASDKSubmit3DSAuthorizationV2];
		NSMutableDictionary *result = [NSMutableDictionary dictionary];
		
		[result setObject:@"Y" forKey:@"threeDSCompInd"];
		[result setObject:@"true" forKey:@"javaEnabled"];
		[result setObject:ASDKLocalized.sharedInstance.localeIdentifier forKey:@"language"];
		[result setObject:@"32" forKey:@"colorDepth"];
		[result setObject:@([[NSTimeZone localTimeZone] secondsFromGMT] / 60) forKey:@"timezone"];
		[result setObject:@(UIScreen.mainScreen.bounds.size.height) forKey:@"screen_height"];
		[result setObject:@(UIScreen.mainScreen.bounds.size.width) forKey:@"screen_width"];
		[result setObject:cresCallbackUrl forKey:@"cresCallbackUrl"];
		
		return result;
	}
	
	return nil;
}

- (void)performFinishAuthorize:(NSDictionary *)additionalData ip:(NSString *)ipAddress emailString:(NSString *)emailString encryptedCardString:(NSString *)encryptedCardString payment:(ASDKInitResponse *)payment threeDSVersion:(NSString *)threeDSVersion
{
	__weak typeof(self) weakSelf = self;

	[self.acquiringSdk finishAuthorizeWithPaymentId:payment.paymentId encryptedPaymentData:nil cardData:encryptedCardString infoEmail:emailString data:additionalData ip:ipAddress success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];

		data.threeDSVersion = threeDSVersion;
		if (strongSelf)
		{
			if (data.fallbackOnTdsV1 == true)
			{
				[strongSelf setNeedCheck3DS2:NO];
				[strongSelf performPayment];
			}
			else if (status == ASDKPaymentStatus_3DS_CHECKING)
			{
				[strongSelf confirmPaymentBy3dsCheckingWithCard:data paymentInfo:paymentInfo];
			}
			else if (status == ASDKPaymentStatus_CONFIRMED || status == ASDKPaymentStatus_AUTHORIZED)
			{
				[strongSelf manageSuccessWithPaymentInfo:paymentInfo];
			}
			else
			{
				ASDKAcquiringResponse *result = [[ASDKAcquiringResponse alloc] initWithDictionary: paymentInfo.dictionary];
				NSString *errorMessage = result.message;
				NSString *errorDetails = result.details == nil ? [NSString stringWithFormat: @"%@", paymentInfo] : result.details;
				NSInteger errorCode = result.errorCode == nil ? 0 : [result.errorCode integerValue];
				
				ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:errorMessage  details:errorDetails code:errorCode];
				[strongSelf manageError:error];
			}
		}
	} failure:^(ASDKAcquringSdkError *error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		__strong typeof(weakSelf) strongSelf = weakSelf;
		if (strongSelf)
		{
			if (error.code == 106)
			{
				[strongSelf setNeedCheck3DS2:NO];
				[strongSelf performPayment];
			}
			else
			{
				[strongSelf manageError:error];
			}
		}
	}];
}

- (void)performFinishAuthorizeRequestWithPaymentId:(ASDKInitResponse *)payment
{
	if (self.selectedCard && self.selectedCard.rebillId && self.makeCharge == YES && self.chargeError == NO)
	{
		[self performFinishChargeWithPayment:payment];
	}
	else
	{
		NSString *cardNumber = [self cardRequisitesCell].cardNumber;
		NSString *date = [self cardRequisitesCell].cardExpirationDate;
		date = [date stringByReplacingOccurrencesOfString:@"/" withString:@""];
		NSString *cvv = [self cardRequisitesCell].cardCVC;
		NSString *emailString = [self emailCell].emailTextField.text;
		ASDKCardData *cardData = [[ASDKCardData alloc] initWithPan:cardNumber expiryDate:date securityCode:cvv cardId:self.selectedCard.cardId publicKeyRef:[self.acquiringSdk publicKeyRef]];
		NSString *encryptedCardString = cardData.cardData;
		
		__weak typeof(self) weakSelf = self;
		if ([self needCheck3DS2] == YES)
		{
			[self.acquiringSdk check3dsVersionWithPaymentId:payment.paymentId cardData:encryptedCardString success:^(ASDKResponseCheck3dsVersion *response) {
				__strong typeof(weakSelf) strongSelf = weakSelf;
				NSDictionary *additionalData = [strongSelf threeDSMethodCheckURL:[response threeDSMethodURL] tdsServerTransID:[response tdsServerTransID]];
				NSString *ipAddress = ASDKUtils.getIPAddress;
				[strongSelf performFinishAuthorize:additionalData ip:ipAddress emailString:emailString encryptedCardString:encryptedCardString payment:payment threeDSVersion:[response threeDSVersion]];
			} failure: ^(ASDKAcquringSdkError *error) {
				[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
				__strong typeof(weakSelf) strongSelf = weakSelf;
				if (strongSelf)
				{
					[strongSelf manageError:error];
				}
			}];
		}
		else
		{
			[self performFinishAuthorize:nil ip:nil emailString:emailString encryptedCardString:encryptedCardString payment:payment threeDSVersion:nil];
		}
	}
}

- (void)performPayment
{
    [self.view endEditing:YES];
	
    if (![self validateForm])
    {
        return;
    }
	
    [self performInitRequest];
}

- (void)manageSuccessWithPaymentInfo:(ASDKPaymentInfo *)paymentInfo
{
    __weak typeof(self) weakSelf = self;
	
    void (^paymentSuccessBlock)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
		
        if (strongSelf)
        {
			strongSelf.onCancelled = nil;
            [strongSelf closeSelfWithCompletion:^{
                 if (strongSelf.onSuccess)
                 {
                     strongSelf.onSuccess(paymentInfo);
                 }
             }];
        }
    };
	
    if (!self.selectedCard)
    {
        [[ASDKCardsListDataController instance] updateCardsListWithSuccessBlock:^{ paymentSuccessBlock(); }
																	 errorBlock:^(ASDKAcquringSdkError *error) { paymentSuccessBlock(); } ];
    }
    else
    {
        paymentSuccessBlock();
    }
}

- (void)manageError:(ASDKAcquringSdkError *)error
{
	self.onCancelled = nil;
	[self closeSelfWithCompletion:^{
		if (self.onError)
		{
			self.onError(error);
		}
	}];
}

- (void)closeSelfWithCompletion: (void (^)(void))completion
{
    [self.view endEditing:YES];
    
	[self dismissViewControllerAnimated:YES completion:^{
         if (completion)
         {
             completion();
         }
     }];
}

#pragma mark - Actions

- (void)openCardsList
{
    [self.view endEditing:YES];
    
    ASDKCardsListViewController *cardsListController = [[ASDKCardsListViewController alloc] init];
    cardsListController.cardsListDelegate = self;
    cardsListController.selectedCard = self.selectedCard;
    
    ASDKNavigationController *nc = [[ASDKNavigationController  alloc] initWithRootViewController:cardsListController];
	ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
	ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
	[nc setModalPresentationStyle:designConfiguration.modalPresentationStyle];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - Validation

- (BOOL)validateForm
{
    return [self validateCard] && [self validateEmail];
}

- (BOOL)validateCard
{
	if (_selectedCard && _selectedCard.rebillId)
	{
		return YES;
	}
	
    return  [[self cardRequisitesCell] validateForm];
}

- (BOOL)validateEmail
{
    NSString *emailString = [self emailCell].emailTextField.text;
    
    if (emailString.length > 0)
    {
        return [self validateEmail:emailString];
    }
    
    return YES;
}

- (BOOL)validateEmail:(NSString *)emailString
{
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:kASDKEmailRegexp options:NSRegularExpressionCaseInsensitive error:nil];
    
    __block NSTextCheckingType checkingType;
    [regExp enumerateMatchesInString:emailString options:0 range:NSMakeRange(0, emailString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
         checkingType = result.resultType;
     }];
    
    BOOL isEmailValid = (checkingType == NSTextCheckingTypeRegularExpression) ? YES : NO;
    
    return isEmailValid;
}

#pragma mark - Helpers

- (NSString *)stringFromAmount:(NSNumber *)amount
{
    NSNumberFormatter *summFormatter = [[NSNumberFormatter alloc] init];
    summFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    summFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    summFormatter.usesGroupingSeparator = YES;
    summFormatter.groupingSeparator = @" ";
    summFormatter.groupingSize = 3;
    summFormatter.maximumFractionDigits = 2;
	
	summFormatter.currencyCode = kCurrencyCode;
	summFormatter.currencySymbol = kTCSRubNoDotCap;
	summFormatter.currencyDecimalSeparator = kDecimalSeparator;
	summFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"ru_RU"];

    return [summFormatter stringFromNumber:amount];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldShowExternalCardsCell
{
    return [[ASDKCardsListDataController instance] externalCards].count > 0;
}

- (BOOL)shouldShowCustomKeyboardOnKeyboardNotification
{
    for (UITextField *textField in [self secretTextFields])
    {
        if ([textField isFirstResponder])
        {
            return YES;
        }
    }
    
    return NO;
}

- (UITextField *)secretTextFieldResponder
{
    for (UITextField *textField in [self secretTextFields])
    {
        if ([textField isFirstResponder])
        {
            return textField;
        }
    }
    
    return nil;
}

- (NSArray *)secretTextFields
{
    return @[self.cardRequisitesCell.textFieldCardNumber, self.cardRequisitesCell.textFieldCardDate, self.cardRequisitesCell.textFieldCardCVC];
}

#pragma mark - Cards list delegate

- (void)didSelectCard:(ASDKCard *)card
{
    [self setSelectedCard:card];
}

- (void)cardsListDidCancel
{
	if (self.view.window == nil)
	{
		self.updateCardCell = YES;
	}
	else
	{
		[self updateSelectedExternalCardOnStart];
	}
}

- (void)cardListDidChanged
{
	if ([[ASDKCardsListDataController instance] cardWithIdentifier:_selectedCard.cardId] == nil)
	{
		_selectedCard = nil;
	}
	
	if (self.view.window == nil)
	{
		self.updateCardCell = YES;
	}
	else
	{
		[self updateSelectedExternalCardOnStart];
	}
}

- (NSArray<ASDKCard*>*)filterCardList:(NSArray<ASDKCard*>*)cardList
{
	if (self.makeCharge)
	{
		NSMutableArray *result = [NSMutableArray new];
		for (ASDKCard *card in cardList)
		{
			if (card.rebillId)
			{
				[result addObject:card];
			}
		}

		return [result copy];
	}

	return cardList;
}

#pragma mark - UIAdaptivePresentationControllerDelegate

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
    [self closeSelfWithCompletion:self.onCancelled];
}

@end
