//
//  ASDKLoopViewController.m
//  ASDKUI
//
//  Created by v.budnikov on 16.10.17.
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

#import "ASDKLoopViewController.h"
#import <ASDKCore/ASDKApiKeys.h>
#import <ASDKCore/ASDKAcquiringSdk.h>
#import "ASDKLoaderViewController.h"

#import "ASDKNavigationController.h"
#import "ASDKPaymentFormStarter.h"
#import "ASDKBarButtonItem.h"
#import "ASDKPaymentFormHeaderCell.h"
#import "ASDKPayButtonCell.h"
#import "ASDKEmailCell.h"

#import "ASDKMacroses.h"
#import "ASDKUtils.h"
#import "ASDKDesign.h"

@interface ASDKLoopViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *addCardRequestKey;

@property(nonatomic, strong) ASDKAcquiringSdk *acquiringSdk;

@property (nonatomic, strong) void (^onSuccess)(NSString *result);
@property (nonatomic, strong) void (^onCancelled)(void);
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKPaymentFormHeaderCell *headerCell;
@property (nonatomic, strong) ASDKPayButtonCell *buttonCell;
@property (nonatomic, strong) ASDKEmailCell *amountCell;

@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation ASDKLoopViewController

- (instancetype)initWithAddCardRequestKey:(NSString *)requestKey acquiringSdk:(ASDKAcquiringSdk *)acquiringSdk
{
	if (self = [super initWithStyle:UITableViewStylePlain])
	{
		_addCardRequestKey = requestKey;
		_acquiringSdk = acquiringSdk;
	}
	
	return self;
}

- (void)showFromViewController:(UIViewController *)viewController
					   success:(void (^)(NSString *result))success
					   failure:(void (^)(ASDKAcquringSdkError *statusError))failure
						cancel:(void (^)(void))cancel
{
	self.onSuccess = success;
	self.onError = failure;
	self.onCancelled = cancel;
	
	ASDKNavigationController *nc = [[ASDKNavigationController  alloc] initWithRootViewController:self];
	[viewController presentViewController:nc animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = LOC(@"Добавление карты");
	
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
	
	ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"acq_btn_cancel")
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(cancelAction:)];
	
	ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
	ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
	//self.customSecureLogo = designConfiguration.paymentsSecureLogosView;
	
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (ASDKPayButtonCell *)buttonCell
{
	if (!_buttonCell)
	{
		_buttonCell = [ASDKPayButtonCell cell];
		[_buttonCell setButtonTitle:@"Проверить"];
	}
	
	return _buttonCell;
}

- (ASDKEmailCell *)amountCell
{
	if (!_amountCell)
	{
		_amountCell = [ASDKEmailCell cell];
		[_amountCell.emailTextField setPlaceholder:@"Заблокированная сумма"];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
		
		[_amountCell setShouldShowTopSeparator:YES];
		[_amountCell setShouldShowBottomSeparator:YES];
		
		[label setText:@"руб"];
		[_amountCell.emailTextField setKeyboardType:UIKeyboardTypeDecimalPad];
		[_amountCell.emailTextField setRightView:label];
		[_amountCell.emailTextField setRightViewMode:UITextFieldViewModeAlways];
		[_amountCell.emailTextField setDelegate:self];
	}

	return _amountCell;
}

- (NSString *)amountDescription
{
	return @"Для подтверждения привязки карты мы списали и вернули небольшую сумму (до 1.99 руб.)\nПожалуйста, укажите ее с точностью до копеек";
}

- (BOOL)validateSumm
{
	UITextField *amountTextField = [self amountCell].emailTextField;
	NSString *summString = amountTextField.text;
	BOOL result = [self isValidAmount:summString];
	
	UIColor *textColor;
    if (@available(iOS 13.0, *)) {
        textColor = [UIColor labelColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
    [amountTextField setTextColor:result ? textColor : [UIColor redColor]];
	
	return result;
}

- (BOOL)isValidAmount:(NSString *)string
{
	if ([string length] > 0)
	{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		self.amount = [numberFormatter numberFromString:string];
		
		if (self.amount != nil)
		{
			return YES;
		}
	}
	
	return NO;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (@available(iOS 13.0, *)) {
        [textField setTextColor:[UIColor labelColor]];
    } else {
        [textField setTextColor:[UIColor blackColor]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	UITextField *amountTextField = [self amountCell].emailTextField;
	if ([textField isEqual:amountTextField])
	{
        UIColor *textColor;
        if (@available(iOS 13.0, *)) {
            textColor = [UIColor labelColor];
        } else {
            textColor = [UIColor blackColor];
        }
		[textField setTextColor:[self isValidAmount:textField.text] ? textColor : [UIColor redColor]];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (@available(iOS 13.0, *)) {
        [textField setTextColor:[UIColor labelColor]];
    } else {
        [textField setTextColor:[UIColor blackColor]];
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
	
	switch (indexPath.row)
	{
		case 0:
			{
				ASDKPaymentFormHeaderCell *cellTitle = [tableView dequeueReusableCellWithIdentifier:@"ASDKPaymentFormHeaderCell"];
				cellTitle.titleLabel.text = nil;
				cellTitle.descriptionLabel.text = self.amountDescription;
				[cellTitle layoutIfNeeded];
				cell = cellTitle;
			}
			break;
			
		case 2:
			cell = [self amountCell];
			break;
			
		case 4:
			cell = [self buttonCell];
			break;
			
		default:
			cell = [tableView dequeueReusableCellWithIdentifier:@"ASDKEmptyTableViewCell"];
			break;
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = 44.0f;

	if (indexPath.row == 0)
	{
		self.headerCell.titleLabel.text = nil;
		self.headerCell.descriptionLabel.text = self.amountDescription;
		result = [self.headerCell cellHeightWithSuperviewWidth:self.view.frame.size.width];
	}

	return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == 4)
	{
		[self checkAddCardState];
	}
}

- (void)closeSelfWithCompletion:(void (^)(void))completion
{
	[self dismissViewControllerAnimated:YES completion:completion];
}

- (void)cancelAction:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
	[self closeSelfWithCompletion:^{
		 if (self.onCancelled)
		 {
			 self.onCancelled();
		 }
	 }];
}

- (void)checkAddCardState
{
	[self.view endEditing:YES];

	if (self.validateSumm)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
		
	 	NSNumber *realAmount = [NSNumber numberWithDouble:100 * self.amount.doubleValue];
		
		[self.acquiringSdk getStateSubmitRandomAmount:realAmount requestKey:self.addCardRequestKey success:^(ASDKResponseGetAddCardState *response) {
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			[self closeSelfWithCompletion:^{
				if (response.success == YES)
				{
					if (self.onSuccess)
					{
						self.onSuccess([response cardId]);
					}
				}
				else
				{
					NSString *message = @"AddCard state error";
					NSString *details = [NSString stringWithFormat:@"%@", response.message.length > 0 ? response.message: @""];
					
					ASDKAcquringSdkError *stateError = [ASDKAcquringSdkError errorWithMessage:message details:details code:0];
					
					if (self.onError)
					{
						self.onError(stateError);
					}
				}
			}];
		} failure:^(ASDKAcquringSdkError *error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			
			[self closeSelfWithCompletion:^{
				if (self.onError)
				{
					self.onError(error);
				}
			}];
		}];
	}
}

@end
