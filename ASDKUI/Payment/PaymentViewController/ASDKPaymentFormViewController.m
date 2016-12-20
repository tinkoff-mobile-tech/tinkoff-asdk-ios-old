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

#import "ASDKPaymentFormHeaderCell.h"
#import "ASDKPaymentFormSummCell.h"

#import "ASDKExternalCardsCell.h"
#import "ASDKCardInputTableViewCell.h"
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

#define kASDKEmailRegexp @"[\\w_.-]+@[\\w_.-]+\\.[a-zA-Z]+"

NSString * const kTCSRubNoDotCap = @"₽";
NSString * const kCurrencyCode = @"RUB";
NSString * const kDecimalSeparator = @",";

typedef enum
{
    ASDKPaymentViewControllerSectionHeader = 0,
    ASDKPaymentViewControllerSectionRequisites,
    ASDKPaymentViewControllerSectionDoneButton,
    ASDKPaymentViewControllerSectionFooter
} ASDKPaymentViewControllerSection;

@interface ASDKPaymentFormViewController () <UITextFieldDelegate, ASDKCardsListDelegate>
{
    NSNumber *_amount;
    NSString *_orderId;
    NSString *_paymentTitle;
    NSString *_paymentDescription;
    NSString *_cardId;
    NSString *_email;
    NSString *_customerKey;
	
    BOOL _shouldShowKeyboardWhenNewCardSelected;
}

@property (nonatomic, strong) ASDKPaymentFormHeaderCell *headerCell;
@property (nonatomic, strong) ASDKPaymentFormSummCell *summCell;
@property (nonatomic, strong) ASDKExternalCardsCell *externalCardsCell;
@property (nonatomic, strong) ASDKCardInputTableViewCell *cardRequisitesCell;
@property (nonatomic, strong) ASDKEmailCell *emailCell;
@property (nonatomic, strong) ASDKPayButtonCell *paymentButtonCell;
@property (nonatomic, strong) ASDKFooterCell *footerCell;

@property (nonatomic, strong) void (^onSuccess)(NSString *paymentId);
@property (nonatomic, strong) void (^onCancelled)();
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKCard *selectedCard;
@property (nonatomic, strong) NSDictionary *additionalPaymentData;

@end

@implementation ASDKPaymentFormViewController

#pragma mark - Init

- (void)dealloc
{
    NSLog(@"DALLOC %@",NSStringFromClass([self class]));
}

- (instancetype)initWithAmount:(NSNumber *)amount
                       orderId:(NSString *)orderId
                         title:(NSString *)title
                   description:(NSString *)description
                        cardId:(NSString *)cardId
                         email:(NSString *)email
				   customerKey:(NSString *)customerKey
		 additionalPaymentData:(NSDictionary *)data
                       success:(void (^)(NSString *paymentId))success
                     cancelled:(void (^)())cancelled
                         error:(void(^)(ASDKAcquringSdkError *error))error
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _paymentTitle = title;
        _amount = amount;
        _orderId = orderId;
        _paymentDescription = description;
        _cardId = cardId;
        _email = email;
        _onSuccess = success;
        _onCancelled = cancelled;
        _onError = error;
        _customerKey = customerKey;
		_additionalPaymentData = data;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"paymentForm.title");
    
    [self.tableView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
    
    ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter instance];
    ASDKDesignConfiguration *designConfiguration = paymentFormStarter.designConfiguration;
    cancelButton.tintColor = [designConfiguration navigationBarItemsTextColor];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    [self updateExternalCardsList];
}

- (void)updateExternalCardsList
{
    if (_customerKey.length > 0)
    {
//        if ([[ASDKCardsListDataController instance] externalCards] == nil)
//        {
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
//        }
//        else
//        {
//            [self updateSelectedExternalCardOnStart];
//        }
    }
}

- (void)updateSelectedExternalCardOnStart
{
    if ([[ASDKCardsListDataController instance] externalCards].count > 0)
    {
        ASDKCard *card = [[[ASDKCardsListDataController instance] externalCards] firstObject];
        
        [self setSelectedCard:card];
        
        _shouldShowKeyboardWhenNewCardSelected = YES;
        
        [self.tableView reloadData];
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
        
        [self updateCardRequisitesCellWithCardNumber:cardNumber];
        
        [self cardRequisitesCell].showSecretContainer = YES;
        
        [self externalCardsCell].titleLabel.text = LOC(@"externalCardsCell.savedCard");
        
        if (_shouldShowKeyboardWhenNewCardSelected)
        {
            [[self cardRequisitesCell].secretCVVTextField becomeFirstResponder];
        }
        else
        {
            _shouldShowKeyboardWhenNewCardSelected = YES;
        }
    }
    else
    {
        [[self cardRequisitesCell].textFieldCardCVC setText:@""];
        [[self cardRequisitesCell].textFieldCardDate setText:@""];
        [self updateCardRequisitesCellWithCardNumber:@""];
        [[self cardRequisitesCell].textFieldCardNumber setText:@""];
        
        [self cardRequisitesCell].showSecretContainer = NO;
        
        [self externalCardsCell].titleLabel.text = LOC(@"externalCardsCell.newCard");
        
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
    [self closeSelfWithCompletion:^
    {
        if (self.onCancelled)
        {
            self.onCancelled();
        }
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

- (ASDKEmailCell *)emailCell
{
    if (!_emailCell)
    {
        _emailCell = [ASDKEmailCell cell];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 3;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ASDKPaymentViewControllerSectionHeader)
    {
        if (indexPath.row == 0)
        {
            return [self headerCell];
        }
        
        return [self summCell];
    }
    else if (indexPath.section == ASDKPaymentViewControllerSectionRequisites)
    {
        if (indexPath.row == 1)
        {
            [self cardRequisitesCell].shouldShowTopSeparator = ![self shouldShowExternalCardsCell];
            
            return [self cardRequisitesCell];
        }
        else if (indexPath.row == 2)
        {
            return [self emailCell];
        }
        else
        {
            [self externalCardsCell].shouldShowTopSeparator = [self shouldShowExternalCardsCell];
        
            return [self externalCardsCell];
        }
    }
    else if (indexPath.section == ASDKPaymentViewControllerSectionDoneButton)
    {
        return [self paymentButtonCell];
    }
    else
    {
        return [self footerCell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == ASDKPaymentViewControllerSectionDoneButton)
    {
        [self performPayment];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == ASDKPaymentViewControllerSectionHeader)
    {
        return .01f;
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ASDKPaymentViewControllerSectionHeader)
    {
        if (indexPath.row == 0)
        {
            return MIN([self.headerCell cellHeightWithSuperviewWidth:self.view.frame.size.width], 98);
        }
    }
    
    else if (indexPath.section == ASDKPaymentViewControllerSectionRequisites)
    {
        if (indexPath.row == 0)
        {
            return [self shouldShowExternalCardsCell] ? [super tableView:tableView heightForRowAtIndexPath:indexPath] : .01f;
        }
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)cardIOButtonPressed:(id)sender
{
    [self scanCard];
}

- (void)updateCardRequisitesCellWithCardNumber:(NSString *)cardNumber
{
    [[self cardRequisitesCell].textFieldCardNumber setText:@""];
    [[self cardRequisitesCell] setCardNumber:cardNumber];
    [[self cardRequisitesCell] textField:[self cardRequisitesCell].textFieldCardNumber shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:cardNumber];
}

- (void)updateCardRequisitesCellWithCardDate:(NSString *)cardDate
{
    [[self cardRequisitesCell].textFieldCardDate setText:@""];
    [[self cardRequisitesCell] textField:[self cardRequisitesCell].textFieldCardDate shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:cardDate];
}

- (void)scanCard
{
    [self.view endEditing:YES];
    
    id<ASDKAcquiringSdkCardScanner> cardScanner = [[ASDKPaymentFormStarter instance] cardScanner];
    
    if (cardScanner && [cardScanner respondsToSelector:@selector(scanCardSuccess:failure:cancel:)])
    {
        __weak typeof(self) weakSelf = self;
        
        [cardScanner scanCardSuccess:^(NSString *cardNumber)
         {
             NSLog(@"scanned %@", cardNumber);
             
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             if (strongSelf)
             {
                 [strongSelf updateCardRequisitesCellWithCardNumber:cardNumber];
             }
         }
                             failure:nil
                              cancel:nil];
    }
}

- (void)performInitRequest
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
    
    NSNumber *realAmount = [NSNumber numberWithDouble:100 * _amount.doubleValue];
    
    __weak typeof(self) weakSelf = self;
    
    NSLog(@"step1");
    
    [self.acquiringSdk initWithAmount:realAmount
                              orderId:_orderId
                          description:nil
							  payForm:nil
                          customerKey:_customerKey
							recurrent:NO
				additionalPaymentData:_additionalPaymentData
                              success:^(ASDKInitResponse *response)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [strongSelf performFinishAuthorizeRequestWithPaymentId:response.paymentId];
        }
    }
                              failure:^(ASDKAcquringSdkError *error)
    {
        NSLog(@"failure %@", error);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [strongSelf manageError:error];
        }
    }];
}

- (void)performFinishAuthorizeRequestWithPaymentId:(NSString *)paymentId
{
    NSString *cardNumber = [self cardRequisitesCell].cardNumber;
    NSString *date = [self cardRequisitesCell].cardExpirationDate;
    date = [date stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *cvv = [self cardRequisitesCell].cardCVC;
        
    NSString *emailString = [self emailCell].emailTextField.text;
    
    NSLog(@"QQQQ %@",self.acquiringSdk);
    
    ASDKCardData *cardData = [[ASDKCardData alloc] initWithPan:cardNumber
                                                    expiryDate:date
                                                  securityCode:cvv
                                                        cardId:self.selectedCard.cardId
                                                  publicKeyRef:[self.acquiringSdk publicKeyRef]];
    
    NSString *encryptedCardString = cardData.cardData;
    
    __weak typeof(self) weakSelf = self;
    
    [self.acquiringSdk finishAuthorizeWithPaymentId:paymentId
							   encryptedPaymentData:nil
                                           cardData:encryptedCardString
                                          infoEmail:emailString
                                            success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status)
     {
         NSLog(@"success\nData: %@\n PaymentInfo: %@, Status: %u", data.ACSUrl, paymentInfo, status);
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         if (status == ASDKPaymentStatus_3DS_CHECKING)
         {
             if (strongSelf)
             {
                 ASDK3DSViewController *threeDsController = [[ASDK3DSViewController alloc] initWithPaymentId:paymentInfo.paymentId
                                                                                                 threeDsData:data
                                                                                                acquiringSdk:strongSelf.acquiringSdk];
                 
                 [threeDsController showFromViewController:strongSelf
                                                   success:^(NSString *paymentId)
                  {
                      NSLog(@"\n\n\nPAYMENT SUCCESS AFTER 3DS\n\n\n");
                      
                      __strong typeof(weakSelf) strongSelf1 = weakSelf;
                      
                      if (strongSelf1)
                      {
                          [strongSelf1 manageSuccessWithPaymentId:paymentId];
                      }
                  }
                                                   failure:^(ASDKAcquringSdkError *statusError)
                  {
                      NSLog(@"\n\n\nPAYMENT ERROR AFTER 3DS\n\n\n");
                      
                      __strong typeof(weakSelf) strongSelf1 = weakSelf;
                      
                      if (strongSelf1)
                      {
                          [strongSelf1 manageError:statusError];
                      }
                  }
                                                    cancel:^()
                  {
                      NSLog(@"\n\n\nPAYMENT 3DS CANCELED\n\n\n");
                      
                      __strong typeof(weakSelf) strongSelf1 = weakSelf;
                      
                      if (strongSelf1)
                      {
                          [strongSelf1 closeSelfWithCompletion:self.onCancelled];
                      }
                  }];
             }
         }
         else if (status == ASDKPaymentStatus_CONFIRMED || status == ASDKPaymentStatus_AUTHORIZED)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
             
             if (strongSelf)
             {
                 [strongSelf manageSuccessWithPaymentId:paymentId];
             }
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
             
             NSLog(@"\n\n\nPAYMENT FINISHED WITH ERROR STATE\n\n\n");
             
             NSString *message = @"Payment state error";
             NSString *details = [NSString stringWithFormat:@"%@",paymentInfo];
             
             ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:message
                                                                          details:details
                                                                             code:0];
             
             if (strongSelf)
             {
                 [strongSelf manageError:error];
             }
         }
     }
                                            failure:^(ASDKAcquringSdkError *error)
     {
         NSLog(@"failure %@, message %@, details %@", error, error.errorMessage, error.errorDetails);
         
         [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         if (strongSelf)
         {
             [strongSelf manageError:error];
         }
     }];
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

- (void)manageSuccessWithPaymentId:(NSString *)paymentId
{
    __weak typeof(self) weakSelf = self;
    
    void (^paymentSuccessBlock)() = ^
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [strongSelf closeSelfWithCompletion:^
             {
                 if (strongSelf.onSuccess)
                 {
                     strongSelf.onSuccess(paymentId);
                 }
             }];
        }
    };
    
    if (!self.selectedCard)
    {
        [[ASDKCardsListDataController instance] updateCardsListWithSuccessBlock:^
         {
             paymentSuccessBlock();
         }
                                                                     errorBlock:^(ASDKAcquringSdkError *error)
         {
             paymentSuccessBlock();
         }];
    }
    else
    {
        paymentSuccessBlock();
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.errorMessage message:error.errorDetails preferredStyle:UIAlertControllerStyleAlert];
        
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
    
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark - Validation

- (BOOL)validateForm
{
    return [self validateCard] && [self validateEmail];
}

- (BOOL)validateCard
{
    return [[self cardRequisitesCell] validateForm];
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
    [self.view endEditing:YES];
    
    [self.tableView reloadData];
    
    [self setSelectedCard:[[[ASDKCardsListDataController instance] externalCards] firstObject]];
}

@end
