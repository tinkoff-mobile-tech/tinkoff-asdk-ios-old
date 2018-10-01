//
//  ASDKAttachCardViewController.m
//  ASDKUI
//
//  Created by v.budnikov on 12.10.17.
//  Copyright © 2017 Tinkoff Bank. All rights reserved.
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
//

#import "ASDKAttachCardViewController.h"
#import "ASDKMacroses.h"
#import "ASDKDesign.h"
#import "ASDKBarButtonItem.h"
#import "ASDKPaymentFormStarter.h"

#import "ASDKCardInputTableViewCell.h"
#import "ASDKEmailCell.h"
#import "ASDKBaseCell.h"
#import "ASDKFooterCell.h"
#import "ASDKPaymentFormHeaderCell.h"
#import "ASDKEmptyTableViewCell.h"
#import "ASDKPayButtonCell.h"
#import "ASDKLoaderViewController.h"
#import "ASDK3DSViewController.h"
#import "ASDKCardsListDataController.h"
#import "ASDKLoopViewController.h"

#define kASDKEmailRegexp @"[\\w_.-]+@[\\w_.-]+\\.[a-zA-Z]+"

@interface ASDKAttachCardViewController () <UITextFieldDelegate>

@property (nonatomic, strong) void (^onSuccess)(ASDKResponseAttachCard *paymentInfo);
@property (nonatomic, strong) void (^onCancelled)(void);
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKFooterCell *footerCell;
@property (nonatomic, strong) ASDKPaymentFormHeaderCell *headerCell;
@property (nonatomic, strong) ASDKCardInputTableViewCell *cardRequisitesCell;
@property (nonatomic, strong) ASDKEmailCell *emailCell;
@property (nonatomic, strong) ASDKPayButtonCell *paymentButtonCell;

@property (nonatomic, strong) NSArray *tableViewDataSource;
@property (nonatomic, strong) UIView *customSecureLogo;
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, copy) NSString *cardCheckType;
@property (nonatomic, copy) NSString *viewTitleHead;
@property (nonatomic, copy) NSString *cardTitle;
@property (nonatomic, copy) NSString *cardDescription;
@property (nonatomic, copy) NSString *preStateValueEmail;
@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, strong) NSDictionary *additionalData;

@end

@implementation ASDKAttachCardViewController

- (instancetype)initWithCardCheckType:(NSString *)cardCheckType
							formTitle:(NSString *)title
						   formHeader:(NSString *)header
						  description:(NSString *)description
								email:(NSString *)email
						  customerKey:(NSString *)customerKey
					   additionalData:(NSDictionary *)data
							  success:(void (^)(ASDKResponseAttachCard *paymentInfo))success
							cancelled:(void (^)(void))cancelled
								error:(void (^)(ASDKAcquringSdkError *error))error
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		_cardCheckType = cardCheckType;
		_viewTitleHead = title;
		_cardTitle = header;
		_cardDescription = description;
		_preStateValueEmail = email;
		_customerKey = customerKey;
		_onSuccess = success;
		_onCancelled = cancelled;
		_onError = error;
		_additionalData = data;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (self.viewTitleHead != nil && self.viewTitleHead.length > 0)
	{
		self.title = self.viewTitleHead;
	}
	else
	{
		self.title = LOC(@"externalCardsCell.newCard");
	}

	[self.navigationController.navigationBar setTranslucent:NO];
	
	self.tableView.sectionHeaderHeight = 0;
	self.tableView.sectionFooterHeight = 0;
	self.tableView.estimatedSectionHeaderHeight = 0;
	self.tableView.estimatedSectionFooterHeight = 0;
	self.tableView.rowHeight = 0;
	
	[self.tableView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
	[self.tableView registerNib:[UINib nibWithNibName:@"ASDKEmptyTableViewCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"ASDKEmptyTableViewCell"];
	[self.tableView registerNib:[UINib nibWithNibName:@"ASDKPaymentFormHeaderCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"ASDKPaymentFormHeaderCell"];
	
	self.keyboardHeight = 0;
	
	ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel")
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(cancelAction:)];
	
	ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
	ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
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
	if (designConfiguration.attachCardItems != nil)
	{
		[dataSource addObjectsFromArray:designConfiguration.attachCardItems];
	}
	
	if ([dataSource count] == 0)
	{
		[dataSource addObjectsFromArray:@[@(CellProductTitle),
										  @(CellProductDescription),
										  @(CellPaymentCardRequisites),
										  @(CellEmail),
										  @(CellEmptyFlexibleSpace),
										  @(CellAttachButton),
										  @(CellEmpty20px),
										  @(CellSecureLogos)
										  ]];
	}
	
	self.tableViewDataSource = [dataSource copy];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender
{
	[self closeSelfWithCompletion:^
	 {
		 if (self.onCancelled)
		 {
			 self.onCancelled();
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

#pragma mark - TableView helpers

- (ASDKFooterCell *)footerCell
{
	if (!_footerCell)
	{
		_footerCell = [ASDKFooterCell cell];
	}
	
	return _footerCell;
}

- (ASDKPaymentFormHeaderCell *)headerCell
{
	if (!_headerCell)
	{
		_headerCell = [ASDKPaymentFormHeaderCell cell];
		_headerCell.titleLabel.text = nil;
		_headerCell.descriptionLabel.text = nil;
		
		[_headerCell layoutIfNeeded];
	}

	return _headerCell;
}

- (ASDKEmailCell *)emailCell
{
	if (!_emailCell)
	{
		_emailCell = [ASDKEmailCell cell];
		[_emailCell.emailTextField setPlaceholder:LOC(@"attachCard.emailCellPlaceholder")];
		[_emailCell.emailTextField setText:_preStateValueEmail];
		[_emailCell.emailTextField setDelegate:self];
	}

	return _emailCell;
}

- (ASDKCardInputTableViewCell *)cardRequisitesCell
{
	if (!_cardRequisitesCell)
	{
		_cardRequisitesCell = [ASDKCardInputTableViewCell cell];
		[_cardRequisitesCell.cardIOButton setBackgroundColor:[UIColor clearColor]];
		[_cardRequisitesCell.saveCardContainer setHidden:YES];
		_cardRequisitesCell.contentView.backgroundColor = [UIColor whiteColor];
		[_cardRequisitesCell setPlaceholderText:LOC(@"Transfer.CardNumber.Sender")];
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

- (ASDKPayButtonCell *)paymentButtonCell
{
	if (!_paymentButtonCell)
	{
		_paymentButtonCell = [ASDKPayButtonCell cell];
		[_paymentButtonCell setButtonTitle:LOC(@"attachCard.attach")];
	}
	
	return _paymentButtonCell;
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
			cellTitle.titleLabel.text = self.cardTitle;
			_headerCell.descriptionLabel.text = nil;
			[cellTitle layoutIfNeeded];
			cell = cellTitle;
		}
			break;
			
		case CellProductDescription:
		{
			ASDKPaymentFormHeaderCell *cellTitle = [tableView dequeueReusableCellWithIdentifier:@"ASDKPaymentFormHeaderCell"];
			cellTitle.titleLabel.text = nil;
			cellTitle.descriptionLabel.text = self.cardDescription;
			[cellTitle layoutIfNeeded];
			cell = cellTitle;
		}
			break;

		case CellEmail:
			cell = [self emailCell];
			break;

		case CellSecureLogos:
			cell = [self footerCell];
			[[self footerCell] setCustomSecureLogos:self.customSecureLogo];
			break;

		case CellAttachButton:
		{
			ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
			ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
			if (designConfiguration.attachCardCustomButton == nil)
			{
				ASDKPayButtonCell *buttonCell = [self paymentButtonCell];
				
				if (designConfiguration.attachCardButtonTitle.length > 0)
				{
					[buttonCell setButtonTitle:designConfiguration.attachCardButtonTitle];
				}

				cell = buttonCell;
			}
			else
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"ASDKEmptyTableViewCell" forIndexPath:indexPath];
				[designConfiguration.attachCardCustomButton setCenter:cell.contentView.center];
				[cell.contentView addSubview:designConfiguration.attachCardCustomButton];
				
				[designConfiguration.attachCardCustomButton addTarget:self action:@selector(buttonActionAttach:) forControlEvents:UIControlEventTouchUpInside];
			}
		}
			break;

		case CellPaymentCardRequisites:
			cell = [self cardRequisitesCell];
			break;

		case CellPayButton:
		case CellAmount:
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 0;
	
	switch ([[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue])
	{
		case CellProductTitle:
			self.headerCell.titleLabel.text = self.cardTitle;
			self.headerCell.descriptionLabel.text = nil;
			result = [self.headerCell cellHeightWithSuperviewWidth:self.view.frame.size.width];
			break;
			
		case CellProductDescription:
			self.headerCell.titleLabel.text = nil;
			self.headerCell.descriptionLabel.text = self.cardDescription;
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
			
		case CellAttachButton:
		{
			ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
			ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
			if (designConfiguration.attachCardCustomButton == nil)
			{
				result = 44.0f;
			}
			else
			{
				result = designConfiguration.attachCardCustomButton.frame.size.height;
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
			
			result = (tableView.frame.size.height - height - self.keyboardHeight) / count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue] == CellPayButton ||
		[[self.tableViewDataSource objectAtIndex:indexPath.row] integerValue] == CellAttachButton)
	{
		[self buttonActionAttach:nil];
	}
}

#pragma mark - Validation

- (BOOL)validateForm
{
	return [self validateCard] && [self validateEmail];
}

- (BOOL)validateCard
{
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
	NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:kASDKEmailRegexp
																			options:NSRegularExpressionCaseInsensitive
																			  error:nil];
	
	__block NSTextCheckingType checkingType;
	[regExp enumerateMatchesInString:emailString options:0 range:NSMakeRange(0, emailString.length) usingBlock:^(NSTextCheckingResult *result,
																												 NSMatchingFlags flags,
																												 BOOL *stop)
	 {
		 checkingType = result.resultType;
	 }];
	
	BOOL isEmailValid = (checkingType == NSTextCheckingTypeRegularExpression) ? YES : NO;
	
	return isEmailValid;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	UITextField *emailTextField = [self emailCell].emailTextField;
	if ([textField isEqual:emailTextField])
	{
		[textField setTextColor:[self validateEmail] ? [UIColor blackColor] : [UIColor redColor]];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	UITextField *emailTextField = [self emailCell].emailTextField;
	if ([textField isEqual:emailTextField])
	{
		[textField setTextColor:[self validateEmail] ? [UIColor blackColor] : [UIColor redColor]];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	UITextField *emailTextField = [self emailCell].emailTextField;
	if ([textField isEqual:emailTextField])
	{
		[textField setTextColor:[UIColor blackColor]];
	}
	
	return YES;
}

#pragma mark - ASDKCardsListDelegate

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
		
		[cardScanner scanCardSuccess:^(id<ASDKAcquiringSdkCardRequisites> cardRequisites){
			 __strong typeof(weakSelf) strongSelf = weakSelf;
			 
			 if (strongSelf)
			 {
				 [strongSelf updateCardRequisitesCellWithCardRequisites:[cardRequisites cardNumber] expiredData:[cardRequisites cardExpireDate]];
			 }
		 }
							 failure:nil
							  cancel:nil];
	}
}

- (void)buttonActionAttach:(UIButton *)button
{
	[self.view endEditing:YES];
	
	if ([self validateForm] == YES)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
		
		__weak typeof(self) weakSelf = self;
		
		[self.acquiringSdk initAttachCardWithCheckType:self.cardCheckType customerKey:self.customerKey success:^(ASDKResponseAddCardInit *response) {
			NSString *requestKey = response.requestKey;
			if ([requestKey length] > 0)
			{
				NSString *cardNumber = [self cardRequisitesCell].cardNumber;
				NSString *date = [self cardRequisitesCell].cardExpirationDate;
				date = [date stringByReplacingOccurrencesOfString:@"/" withString:@""];
				NSString *cvv = [self cardRequisitesCell].cardCVC;
				
				NSString *emailString = [self emailCell].emailTextField.text;
				if ([emailString length] > 0)
				{
					NSMutableDictionary *additionalData = [NSMutableDictionary new];
					if (self.additionalData != nil)
					{
						[additionalData addEntriesFromDictionary:self.additionalData];
					}
					
					[additionalData setObject:emailString forKey:@"Email"];
					self.additionalData = additionalData;
				}
				
				NSLog(@"QQQQ %@",self.acquiringSdk);
				
				ASDKCardData *cardData = [[ASDKCardData alloc] initWithPan:cardNumber
																expiryDate:date
															  securityCode:cvv
																	cardId:nil
															  publicKeyRef:[self.acquiringSdk publicKeyRef]];

				[self.acquiringSdk finishAttachCardWithCardData:cardData.cardData aditionalInfo:self.additionalData requestKey:requestKey success:^(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status) {
					__strong typeof(weakSelf) strongSelf = weakSelf;
					
					if (result.status == ASDKPaymentStatus_3DS_CHECKING || result.status == ASDKPaymentStatus_3DSHOLD)
					{
						
						ASDK3DSViewController *threeDsController = [[ASDK3DSViewController alloc] initWithAddCardRequestKey:requestKey
																										threeDsData:data
																									   acquiringSdk:strongSelf.acquiringSdk];
						
						[threeDsController showFromViewController:strongSelf
														  success:^(NSString *cardId)
						 {
							 NSLog(@"\n\n\nAttach card SUCCESS AFTER 3DS\n\n\n");
							 
							 __strong typeof(weakSelf) strongSelf1 = weakSelf;
							 
							 if (strongSelf1)
							 {
								 NSMutableDictionary *infoAttach = [NSMutableDictionary dictionaryWithDictionary:result.dictionary];
								 [infoAttach setObject:cardId forKey:kASDKCardId];
								 [strongSelf1 manageSuccessWithInfo:[[ASDKResponseAttachCard alloc] initWithDictionary:infoAttach]];
							 }
						 }
														  failure:^(ASDKAcquringSdkError *statusError)
						 {
							 NSLog(@"\n\n\nAttach card ERROR AFTER 3DS\n\n\n");
							 
							 __strong typeof(weakSelf) strongSelf1 = weakSelf;
							 
							 if (strongSelf1)
							 {
								 [strongSelf1 manageError:statusError];
							 }
						 }
														   cancel:^()
						 {
							 NSLog(@"\n\n\nAttach card 3DS CANCELED\n\n\n");
							 
							 __strong typeof(weakSelf) strongSelf1 = weakSelf;
							 
							 if (strongSelf1)
							 {
								 [strongSelf1 closeSelfWithCompletion:self.onCancelled];
							 }
						 }];
						//
					}
					else if ((result.status == ASDKPaymentStatus_NO || result.status == ASDKPaymentStatus_HOLD || result.status == ASDKPaymentStatus_UNKNOWN) && [result.errorCode isEqualToString:@"0"])
					{
						__strong typeof(weakSelf) strongSelf1 = weakSelf;
						
						if (strongSelf1)
						{
							[strongSelf1 manageSuccessWithInfo:result];
						}
					}
					else if (result.status == ASDKPaymentStatus_LOOP)
					{
						[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
						ASDKLoopViewController *loopVoewController = [[ASDKLoopViewController alloc] initWithAddCardRequestKey:requestKey acquiringSdk:strongSelf.acquiringSdk];
						[loopVoewController showFromViewController:strongSelf success:^(NSString *loopResult) {
							NSLog(@"\n\n\nAttach card SUCCESS AFTER LOOP\n\n\n");
							
							__strong typeof(weakSelf) strongSelf1 = weakSelf;
							
							if (strongSelf1)
							{
								NSMutableDictionary *infoAttach = [NSMutableDictionary dictionaryWithDictionary:result.dictionary];
								[infoAttach setObject:loopResult forKey:kASDKCardId];
								[strongSelf1 manageSuccessWithInfo:[[ASDKResponseAttachCard alloc] initWithDictionary:infoAttach]];
							}
						} failure:^(ASDKAcquringSdkError *statusError) {
							NSLog(@"\n\n\nAttach card ERROR AFTER LOOP\n\n\n");
							
							__strong typeof(weakSelf) strongSelf1 = weakSelf;
							
							if (strongSelf1)
							{
								[strongSelf1 manageError:statusError];
							}
						} cancel:^{
							NSLog(@"\n\n\nAttach card LOOP CANCELED\n\n\n");
							
							__strong typeof(weakSelf) strongSelf1 = weakSelf;
							
							if (strongSelf1)
							{
								[strongSelf1 closeSelfWithCompletion:self.onCancelled];
							}
						}];
					}
					else
					{
						[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
						
						NSLog(@"\n\n\nAttach card FINISHED WITH ERROR STATE\n\n\n");
						
						NSString *message = @"Attach card error";
						NSString *details = [NSString stringWithFormat:@"error %@", result.errorCode];
						
						ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:message
																					 details:details
																						code:[result.errorCode integerValue]];
						
						if (strongSelf)
						{
							[strongSelf manageError:error];
						}
					}
				} failure:^(ASDKAcquringSdkError *error) {
					[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
					[self manageError:error];
				}];
			}
			else
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
				ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:response.message
																			 details:response.details
																				code:0];
				[self manageError:error];
			}
		} failure:^(ASDKAcquringSdkError *error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			[self manageError:error];
		}];
	}
}

- (void)manageError:(ASDKAcquringSdkError *)error
{
	if (error.isSdkError)
	{
		[self closeSelfWithCompletion:^
		 {
			 if (self.onError)
			 {
				 self.onError(error);
			 }
		 }];
	}
	else
	{
		NSString *alertDetails = error.errorDetails ? error.errorDetails : error.userInfo[kASDKStatus];
		NSString *alertMessage = error.errorMessage ? error.errorMessage : @"";

		if ( alertDetails.length > 0)
		{
			alertMessage = [NSString stringWithFormat:@"%@ %@", alertMessage, alertDetails];
		}

		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOC(@"Common.error") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *cancelAction = [UIAlertAction
									   actionWithTitle:LOC(@"Common.Close")
									   style:UIAlertActionStyleCancel
									   handler:^(UIAlertAction *action)
									   {
										   [alertController dismissViewControllerAnimated:YES completion:nil];
									   }];
		
		[alertController addAction:cancelAction];
		
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

- (void)manageSuccessWithInfo:(ASDKResponseAttachCard *)cardInfo
{
	__weak typeof(self) weakSelf = self;

	void (^paymentSuccessBlock)(void) = ^
	{
		__strong typeof(weakSelf) strongSelf = weakSelf;

		if (strongSelf)
		{
			[strongSelf closeSelfWithCompletion:^
			 {
				 if (strongSelf.onSuccess)
				 {
					 strongSelf.onSuccess(cardInfo);
				 }
			 }];
		}
	};

	[[ASDKCardsListDataController instance] updateCardsListWithSuccessBlock:^{ paymentSuccessBlock(); }  errorBlock:^(ASDKAcquringSdkError *error) { paymentSuccessBlock(); } ];
}

@end
