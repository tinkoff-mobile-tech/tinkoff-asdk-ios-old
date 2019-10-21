//
//  ASDKPaymentFormStarter.m
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


#import "ASDKPaymentFormStarter.h"
#import "ASDKPaymentFormViewController.h"
#import "ASDKNavigationController.h"
#import "ASDKLoaderViewController.h"
#import "ASDKBarButtonItem.h"
#import "ASDKCardsListDataController.h"
#import "ASDKAttachCardViewController.h"
#import "ASDKLoopViewController.h"

@interface ASDKPaymentFormStarter () <PKPaymentAuthorizationViewControllerDelegate>
{
    UIStatusBarStyle _oldStatusBarStyle;
}

@property (nonatomic, strong) ASDKAcquiringSdk *acquiringSdk;

@property (nonatomic, strong) NSString *terminalKey;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *publicKeyAsString;

@property (nonatomic, readwrite) BOOL debug;
@property (nonatomic, strong) id<ASDKAcquiringSdkLoggerDelegate> logger;

@property (nonatomic, strong) UIWindow *loaderWindow;

// ApplePay
@property (nonatomic, weak) UIViewController *presentingViewControllerApplePay;
@property (nonatomic, strong) NSString *paymentIdForApplePay;
//
@property (nonatomic, strong) void (^onSuccess)(ASDKPaymentInfo *paymentInfo);
@property (nonatomic, strong) void (^onCancelled)(void);
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKPaymentInfo *onCompleteSuccessPaymentInfo;
@property (nonatomic, strong) ASDKAcquringSdkError *onCompleteError;
@property (nonatomic, assign) ASDKPaymentStatus onCompleteStatus;

@end

@implementation ASDKPaymentFormStarter

static ASDKPaymentFormStarter * __paymentFormStarterInstance = nil;

+ (instancetype)instance
{
    @synchronized(self)
    {
        return __paymentFormStarterInstance;
    }
}

+ (instancetype)paymentFormStarterWithAcquiringSdk:(ASDKAcquiringSdk *)acquiringSdk
{
    @synchronized(self)
    {
        if (!__paymentFormStarterInstance)
        {
            __paymentFormStarterInstance = [[ASDKPaymentFormStarter alloc] init];
            
            __paymentFormStarterInstance.acquiringSdk = acquiringSdk;
            __paymentFormStarterInstance.designConfiguration = [[ASDKDesignConfiguration alloc] init];
            
            [__paymentFormStarterInstance registerForNotifications];
        }

        return __paymentFormStarterInstance;
    }
}

+ (void)resetSharedInstance
{
	@synchronized(self)
	{
		[ASDKCardsListDataController resetAcquiringSdk];
		[__paymentFormStarterInstance unregisterForNotifications];
		[__paymentFormStarterInstance hideLoaderIfNeeded];
		__paymentFormStarterInstance = nil;
	}
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loaderVisiblityChanged:) name:ASDKNotificationShowLoader object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loaderVisiblityChanged:) name:ASDKNotificationHideLoader object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareDesign
{
    ASDKDesignConfiguration *designConfiguration = self.designConfiguration;
    
    [[ASDKBarButtonItem appearance] setTintColor:[designConfiguration navigationBarItemsTextColor]];
}

- (void)presentPaymentFormFromViewController:(UIViewController *)presentingViewController
									 orderId:(NSString *)orderId
									  amount:(NSNumber *)amount
									   title:(NSString *)title
								 description:(NSString *)description
									  cardId:(NSString *)cardId
									   email:(NSString *)email
								 customerKey:(NSString *)customerKey
								   recurrent:(BOOL)recurrent
								  makeCharge:(BOOL)makeCharge
					   additionalPaymentData:(NSDictionary *)data
								 receiptData:(NSDictionary *)receiptData
									 success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								   cancelled:(void (^)(void))onCancelled
									   error:(void (^)(ASDKAcquringSdkError *error))onError
{
	[self presentPaymentFormFromViewController:presentingViewController
									   orderId:orderId
										amount:amount
										 title:title
								   description:description
										cardId:cardId
										 email:email
								   customerKey:customerKey
									 recurrent:recurrent
									makeCharge:makeCharge
						 additionalPaymentData:data
								   receiptData:receiptData
									 shopsData:nil
							 shopsReceiptsData:nil
									   success:onSuccess
									 cancelled:onCancelled
										 error:onError];
}

- (void)presentPaymentFormFromViewController:(UIViewController *)presentingViewController
                                     orderId:(NSString *)orderId
                                      amount:(NSNumber *)amount
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
                                     success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
                                   cancelled:(void (^)(void))onCancelled
                                       error:(void (^)(ASDKAcquringSdkError *error))onError
{
    [self prepareDesign];
    
    ASDKPaymentFormViewController *vc = [[ASDKPaymentFormViewController alloc] initWithAmount:amount
                                                                                      orderId:orderId
                                                                                        title:title
                                                                                  description:description
                                                                                       cardId:cardId
                                                                                        email:email
                                                                                  customerKey:customerKey
																					recurrent:recurrent
																				   makeCharge:makeCharge
																		additionalPaymentData:data
																				  receiptData:receiptData
																					shopsData:shopsData
																			shopsReceiptsData:shopsReceiptsData
                                                                                      success:^(ASDKPaymentInfo *paymentInfo)
                                         {
                                             [ASDKPaymentFormStarter resetSharedInstance];
                                             
                                             onSuccess(paymentInfo);
                                         }
                                                                                    cancelled:^
                                         {
                                             [ASDKPaymentFormStarter resetSharedInstance];
                                             
                                             onCancelled();
                                         }
                                                                                        error:^(ASDKAcquringSdkError *error)
                                         {
                                             [ASDKPaymentFormStarter resetSharedInstance];
                                             
                                             onError(error);
                                         }];
    
    vc.acquiringSdk = self.acquiringSdk;

	ASDKNavigationController *nc = [[ASDKNavigationController alloc] initWithRootViewController:vc];
	[nc setModalPresentationStyle:self.designConfiguration.modalPresentationStyle];

    [ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey];

    [presentingViewController presentViewController:nc animated:YES completion:nil];
}

#pragma mark - Loader

- (void)loaderVisiblityChanged:(NSNotification *)notification
{
    NSString *name = notification.name;
    UIWindow *loaderWindow = self.loaderWindow;
    __unused BOOL hidden = loaderWindow.hidden;
    
    if ([name isEqualToString:ASDKNotificationShowLoader])
    {
        [self showLoaderIfNeeded];
        
    }
    else if ([name isEqualToString:ASDKNotificationHideLoader])
    {
        [self hideLoaderIfNeeded];
    }
}

- (void)showLoaderIfNeeded
{
    UIWindow *loaderWindow = self.loaderWindow;
    BOOL hidden = loaderWindow.hidden;
    
    if (hidden)
    {
        [loaderWindow.rootViewController viewWillAppear:NO];
        loaderWindow.hidden = NO;
        [loaderWindow becomeKeyWindow];
    }
}

- (void)hideLoaderIfNeeded
{
    UIWindow *loaderWindow = self.loaderWindow;
    BOOL hidden = loaderWindow.hidden;
    
    if (!hidden)
    {
        [loaderWindow.rootViewController viewWillDisappear:NO];
        loaderWindow.hidden = YES;
        [loaderWindow resignKeyWindow];
    }
}

- (UIWindow *)loaderWindow
{
    if (_loaderWindow == nil)
    {
        ASDKLoaderViewController *loaderViewController = [ASDKLoaderViewController new];
        
        _loaderWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        _loaderWindow.rootViewController = loaderViewController;
        
        _loaderWindow.windowLevel = UIWindowLevelAlert;
    }
    
    return _loaderWindow;
}

#pragma mark - PKPaymentAuthorizationViewController

+ (BOOL)isPayWithAppleAvailable
{
	BOOL canMakePayments = [PKPaymentAuthorizationViewController canMakePayments];
	BOOL canMakePaymentsUsingNetworks = canMakePaymentsUsingNetworks = [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[ASDKPaymentFormStarter payWithAppleSupportedNetworks]];

	return canMakePayments && canMakePaymentsUsingNetworks;
}

+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks
{
	NSArray<PKPaymentNetwork> *result =  @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];

	return result;
}

- (void)payWithApplePayFromViewController:(UIViewController *)presentingViewController
								   amount:(NSNumber *)amount
								  orderId:(NSString *)orderId
							  description:(NSString *)description
							  customerKey:(NSString *)customerKey
								sendEmail:(BOOL)sendEmail
									email:(NSString *)email
						  appleMerchantId:(NSString *)appleMerchantId
						  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods
						  shippingContact:(PKContact *)shippingContact
				   shippingEditableFields:(PKAddressField)shippingEditableFields
								recurrent:(BOOL)recurrent
					additionalPaymentData:(NSDictionary *)additionalPaymentData
							  receiptData:(NSDictionary *)receiptData
								shopsData:(NSArray *)shopsData
						shopsReceiptsData:(NSArray *)shopsReceiptsData
								  success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								cancelled:(void (^)(void))onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError
{
	self.onSuccess = onSuccess;
	self.onError = onError;
	self.onCancelled = onCancelled;

	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble:100 * amount.doubleValue]
							  orderId:orderId
						  description:nil
							  payForm:nil
						  customerKey:customerKey
							recurrent:recurrent
				additionalPaymentData:additionalPaymentData
						  receiptData:receiptData
							shopsData:shopsData
					shopsReceiptsData:shopsReceiptsData
							 location:ASDKLocalized.sharedInstance.localeIdentifier
		success:^(ASDKInitResponse *response){
			self.paymentIdForApplePay = response.paymentId;
			
			PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
			paymentRequest.merchantIdentifier = appleMerchantId;
			paymentRequest.countryCode = @"RU";
			paymentRequest.currencyCode = @"RUB";
			paymentRequest.supportedNetworks = [ASDKPaymentFormStarter payWithAppleSupportedNetworks];
			paymentRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityCredit|PKMerchantCapabilityDebit;
			//paymentSummaryItems
			NSMutableArray *paymentSummaryItems = [NSMutableArray new];//
			[paymentSummaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:description amount:[NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]]]];
			[paymentSummaryItems addObjectsFromArray:shippingMethods];
			
			paymentRequest.paymentSummaryItems = paymentSummaryItems;
			
			//
			PKAddressField addressFieldBilling = PKAddressFieldNone;
			if (sendEmail == YES) { addressFieldBilling |= PKAddressFieldEmail; }
			//	if (shippingContact.postalAddress) { addressFieldBilling |= PKAddressFieldPostalAddress; }
			
			PKContact *billingContact = [[PKContact alloc] init];
			billingContact.emailAddress = email;
			paymentRequest.billingContact = billingContact;
			paymentRequest.requiredBillingAddressFields = addressFieldBilling;
			
			paymentRequest.requiredShippingAddressFields = shippingEditableFields;
			paymentRequest.shippingContact = shippingContact;
			
			//paymentRequest.shippingMethods = shippingMethods;
			
			PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
			viewController.delegate = self;
			
			if (viewController)
			{
				self.presentingViewControllerApplePay = presentingViewController;
				[self.presentingViewControllerApplePay presentViewController:viewController animated:YES completion:^{}];
			}
			else
			{
				[ASDKPaymentFormStarter resetSharedInstance];
				self.onError(nil);
				
			}
		}
		failure:^(ASDKAcquringSdkError *error) {
			[ASDKPaymentFormStarter resetSharedInstance];
			self.onError(error);
		}
	 ];
}

- (void)payUsingApplePayFromViewController:(UIViewController *)presentingViewController
									amount:(NSNumber *)amount // цена товара
								   orderId:(NSString *)orderId // идентификатор товара
							   description:(NSString *)description // описание
							   customerKey:(NSString *)customerKey // идетинификатор пользователя (для сохранеиня платежей)
								 sendEmail:(BOOL)sendEmail // отправлять чек на почту
									 email:(NSString *)email
						   appleMerchantId:(NSString *)appleMerchantId // берётся из Target->Capabilities->ApplePay Merchant IDs
						   shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods //доставка и стоимость доставки
						   shippingContact:(PKContact *)shippingContact //кому доставить и адрес доставки
					shippingEditableFields:(NSSet<PKContactField> *)shippingEditableFields //какие поля можно показывать и редактировть на форме оплаты ApplePay
								 recurrent:(BOOL)recurrent
					 additionalPaymentData:(NSDictionary *)additionalPaymentData //JSON объект содержащий дополнительные параметры, например @{@"Email" : @"a@test.ru"}
							   receiptData:(NSDictionary *)receiptData // JSON объект с данными чека, обязательно должен быть объект Items в который вложены позиции чека Email и Taxation - Система налогообложения, значения: osn, usn_income, usn_income_outcome, envd, esn, или patent
								 shopsData:(NSArray *)shopsData
						 shopsReceiptsData:(NSArray *)shopsReceiptsData
								   success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								 cancelled:(void (^)(void))onCancelled
									 error:(void (^)(ASDKAcquringSdkError *error))onError
{
	self.onSuccess = onSuccess;
	self.onError = onError;
	self.onCancelled = onCancelled;

	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble: 100 * amount.doubleValue]
							  orderId:orderId
						  description:nil
							  payForm:nil
						  customerKey:customerKey
							recurrent:recurrent
				additionalPaymentData:additionalPaymentData
						  receiptData:receiptData
							shopsData:shopsData
					shopsReceiptsData:shopsReceiptsData
							 location:ASDKLocalized.sharedInstance.localeIdentifier
		success:^(ASDKInitResponse *response){
			self.paymentIdForApplePay = response.paymentId;
			
			PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
			paymentRequest.merchantIdentifier = appleMerchantId;
			paymentRequest.countryCode = @"RU";
			paymentRequest.currencyCode = @"RUB";
			paymentRequest.supportedNetworks = [ASDKPaymentFormStarter payWithAppleSupportedNetworks];
			paymentRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityCredit|PKMerchantCapabilityDebit;
			//paymentSummaryItems
			NSMutableArray *paymentSummaryItems = [NSMutableArray new];//
			[paymentSummaryItems addObject: [PKPaymentSummaryItem summaryItemWithLabel:description amount: [NSDecimalNumber decimalNumberWithDecimal: [amount decimalValue]]]];
			[paymentSummaryItems addObjectsFromArray: shippingMethods];
			
			paymentRequest.paymentSummaryItems = paymentSummaryItems;
						
			if (sendEmail == YES)
			{
				paymentRequest.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldEmailAddress, nil];
			}
            paymentRequest.requiredBillingContactFields = shippingEditableFields;
			PKContact *billingContact = [[PKContact alloc] init];
			billingContact.emailAddress = email;
			paymentRequest.billingContact = billingContact;

			paymentRequest.shippingContact = shippingContact;

			PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest: paymentRequest];
			viewController.delegate = self;
			
			if (viewController)
			{
				self.presentingViewControllerApplePay = presentingViewController;
				[self.presentingViewControllerApplePay presentViewController: viewController animated: YES completion:^{}];
			}
			else
			{
				[ASDKPaymentFormStarter resetSharedInstance];
				self.onError(nil);
				
			}
		}
		failure:^(ASDKAcquringSdkError *error) {
			[ASDKPaymentFormStarter resetSharedInstance];
			self.onError(error);
		}
	 ];
}

- (void)checkStatusTransaction:(NSString *)paymentId
					   success:(void (^)(ASDKPaymentStatus status))onSuccess
						 error:(void (^)(ASDKAcquringSdkError *error))onError
{
	[self.acquiringSdk getStateWithPaymentId:paymentId success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
		onSuccess(status);
	} failure:^(ASDKAcquringSdkError *error) {
		onError(error);
	}];
}

- (void)refundTransaction:(NSString *)paymentId
				  success:(void (^)(void))onSuccess
					error:(void (^)(ASDKAcquringSdkError *error))onError
{
	[self.acquiringSdk rejectTrancastionWithPaymentId:paymentId success:^(ASDKCancelResponse *response) {
		onSuccess();
	} failure:^(ASDKAcquringSdkError *error) {
		onError(error);
	}];
}

- (void)chargeWithRebillId:(NSNumber *)rebillId
					amount:(NSNumber *)amount
				   orderId:(NSString *)orderId
			   description:(NSString *)description
			   customerKey:(NSString *)customerKey
	 additionalPaymentData:(NSDictionary *)data
			   receiptData:(NSDictionary *)receiptData
				 shopsData:(NSArray *)shopsData
		 shopsReceiptsData:(NSArray *)shopsReceiptsData
				   success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
		   needShowConfirm:(void (^)(UIViewController *vc))paymentConfirm
					 error:(void (^)(ASDKAcquringSdkError *error))onError
{
	NSMutableDictionary *paymentData = [[NSMutableDictionary alloc] init];
	if ([data count])
	{
		[paymentData addEntriesFromDictionary:data];
	}

	[paymentData setObject:@(YES) forKey:@"chargeFlag"];

	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble:100 * amount.doubleValue]
							  orderId:orderId
						  description:description
							  payForm:nil
						  customerKey:customerKey
							recurrent:NO
				additionalPaymentData:paymentData
						  receiptData:receiptData
							shopsData:shopsData
					shopsReceiptsData:shopsReceiptsData
							 location:ASDKLocalized.sharedInstance.localeIdentifier
	 success:^(ASDKInitResponse *response) {
		 [self.acquiringSdk chargeWithPaymentId:response.paymentId rebillId:rebillId success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
			 [ASDKPaymentFormStarter resetSharedInstance];
			 onSuccess(paymentInfo);
		 } failure:^(ASDKAcquringSdkError *error) {
			 ASDKAcquiringResponse *errorResponse = [error.userInfo objectForKey:@"acquringResponse"];
			 //пользователю необходимо подтвердить платеж через ввод cvc ASDK-432
			 //ErrorCode == 104
			 if ([[errorResponse.dictionary objectForKey:@"ErrorCode"] integerValue] == 104)
			 {
				 [[ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey] updateCardsListWithSuccessBlock:^{
					 ASDKCard *selectedCard = [[ASDKCardsListDataController instance] cardByRebillId:rebillId];
					 if (selectedCard != nil)
					 {
						[self prepareDesign];

						 ASDKPaymentFormViewController *vc = [[ASDKPaymentFormViewController alloc] initWithAmount:amount
																										   orderId:orderId
																											 title:nil
																									   description:description
																											cardId:selectedCard.cardId
																											 email:nil
																									   customerKey:customerKey
																										 recurrent:NO
																										makeCharge:YES
																							 additionalPaymentData:paymentData
																									   receiptData:receiptData
																										 shopsData:shopsData
																								 shopsReceiptsData:shopsReceiptsData
																										   success:^(ASDKPaymentInfo *paymentInfo)
															  {
																  [ASDKPaymentFormStarter resetSharedInstance];

																  onSuccess(paymentInfo);
															  }
																										 cancelled:^
															  {
																  [ASDKPaymentFormStarter resetSharedInstance];

																  onError(nil);
															  }
																											 error:^(ASDKAcquringSdkError *error)
															  {
																  [ASDKPaymentFormStarter resetSharedInstance];

																  onError(error);
															  }];

						 vc.acquiringSdk = self.acquiringSdk;
						 [ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey];
						 [vc setChargeError:YES];
						 [vc setChargeErrorPaymentId:[errorResponse.dictionary objectForKey:@"PaymentId"]];
						 [vc needSetupCardRequisitesCellForCVC];
                         
                         ASDKNavigationController *nc = [[ASDKNavigationController alloc] initWithRootViewController:vc];
                         [nc setModalPresentationStyle:self.designConfiguration.modalPresentationStyle];
                         
						 if (paymentConfirm)
						 {
							 paymentConfirm(nc);
						 }
					 }
				 } errorBlock:^(ASDKAcquringSdkError *error) {
					 [ASDKPaymentFormStarter resetSharedInstance];
					 onError(error);
				 }];
			 }
			 else
			 {
				 [ASDKPaymentFormStarter resetSharedInstance];
				 onError(error);
			 }
		 }];
	 } failure:^(ASDKAcquringSdkError *error) {
		 onError(error);
	 }];
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
					   didAuthorizePayment:(PKPayment *)payment
								   handler:(void (^)(PKPaymentAuthorizationResult *result))completion API_AVAILABLE(ios(11.0), watchos(4.0))
{
	if (completion)
	{
		NSString *encryptedPaymentData = [payment.token.paymentData base64EncodedStringWithOptions:0];

		[self.acquiringSdk finishAuthorizeWithPaymentId:self.paymentIdForApplePay
								   encryptedPaymentData:encryptedPaymentData
											   cardData:nil
											  infoEmail:payment.billingContact.emailAddress
												success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
													self.onCompleteSuccessPaymentInfo = paymentInfo;
													self.onCompleteStatus = status;
													PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil];
													completion(result);
												}
												failure:^(ASDKAcquringSdkError *error) {
													self.onCompleteError = error;
													self.onCompleteStatus = ASDKPaymentStatus_UNKNOWN;
													PKPaymentAuthorizationResult *result = [[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil];
													completion(result);
												}];
	}
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
					   didAuthorizePayment:(PKPayment *)payment
								completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
	if (completion)
	{
		NSString *encryptedPaymentData = [payment.token.paymentData base64EncodedStringWithOptions:0];

		[self.acquiringSdk finishAuthorizeWithPaymentId:self.paymentIdForApplePay
								   encryptedPaymentData:encryptedPaymentData
											   cardData:nil
											  infoEmail:payment.billingContact.emailAddress
												success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
													self.onCompleteSuccessPaymentInfo = paymentInfo;
													self.onCompleteStatus = status;
													completion(PKPaymentAuthorizationStatusSuccess);
												}
												failure:^(ASDKAcquringSdkError *error) {
													self.onCompleteError = error;
													self.onCompleteStatus = ASDKPaymentStatus_UNKNOWN;
													completion(PKPaymentAuthorizationStatusFailure);
												}];
	}
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
	[self.presentingViewControllerApplePay dismissViewControllerAnimated:YES completion:^{
		if (self.onCompleteSuccessPaymentInfo != nil && self.onCompleteError == nil && (self.onCompleteStatus == ASDKPaymentStatus_CONFIRMED || self.onCompleteStatus == ASDKPaymentStatus_AUTHORIZED))
		{
			self.onSuccess(self.onCompleteSuccessPaymentInfo);
			self.onCompleteSuccessPaymentInfo = nil;
		}
		else if (self.onCompleteSuccessPaymentInfo == nil && self.onCompleteError == nil)
		{
			self.onCancelled();
		}
		else if (self.onCompleteError != nil)
		{
			self.onError(self.onCompleteError);
			self.onCompleteError = nil;
		}
		else
		{
			NSString *details = [NSString stringWithFormat:@"%@", self.onCompleteSuccessPaymentInfo];
			ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:nil details:details code:0];
			self.onError(error);
			self.onCompleteError = nil;
		}
		
		[ASDKPaymentFormStarter resetSharedInstance];
	}];
}

- (void)presentAttachFormFromViewController:(UIViewController *)presentingViewController
                                  formTitle:(NSString *)title
                                 formHeader:(NSString *)header
                                description:(NSString *)description
                                      email:(NSString *)email
                              cardCheckType:(NSString *)cardCheckType
                                customerKey:(NSString *)customerKey
                             additionalData:(NSDictionary *)data
                  isDissmissAfterCompletion:(BOOL)isDissmissAfterCompletion
                                    success:(void (^)(ASDKResponseAttachCard *result))onSuccess
                                  cancelled:(void (^)(void))onCancelled
                                      error:(void (^)(ASDKAcquringSdkError *error))onError
{
    [self prepareDesign];
    
    //    ASDKLoopViewController *viewController = [[ASDKLoopViewController alloc] initWithAddCardRequestKey:@"1" acquiringSdk:self.acquiringSdk];
    
    ASDKAttachCardViewController *viewController = [[ASDKAttachCardViewController alloc] initWithCardCheckType:cardCheckType
                                                                                                     formTitle:(NSString *)title
                                                                                                    formHeader:(NSString *)header
                                                                                                   description:(NSString *)description
                                                                                                         email:(NSString *)email
                                                                                                   customerKey:(NSString *)customerKey
                                                                                                additionalData:(NSDictionary *)data
                                                                                                       success:^(ASDKResponseAttachCard *result) {
                                                                                                           [ASDKPaymentFormStarter resetSharedInstance];
                                                                                                           onSuccess(result);
                                                                                                       } cancelled:^{
                                                                                                           [ASDKPaymentFormStarter resetSharedInstance];
                                                                                                           onCancelled();
                                                                                                       } error:^(ASDKAcquringSdkError *error) {
                                                                                                           [ASDKPaymentFormStarter resetSharedInstance];
                                                                                                           onError(error);
                                                                                                       }];
    viewController.isDissmissAfterCompletion = isDissmissAfterCompletion;
    
    viewController.acquiringSdk = self.acquiringSdk;
    
    ASDKNavigationController *nc = [[ASDKNavigationController alloc] initWithRootViewController:viewController];
    [nc setModalPresentationStyle:self.designConfiguration.modalPresentationStyle];
    [ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey];
    [presentingViewController presentViewController:nc animated:YES completion:nil];
}

- (void)presentAttachFormFromViewController:(UIViewController *)presentingViewController
								  formTitle:(NSString *)title
								 formHeader:(NSString *)header
								description:(NSString *)description
									  email:(NSString *)email
							  cardCheckType:(NSString *)cardCheckType
								customerKey:(NSString *)customerKey
							 additionalData:(NSDictionary *)data
									success:(void (^)(ASDKResponseAttachCard *result))onSuccess
                                  cancelled:(void (^)(void))onCancelled
                                      error:(void (^)(ASDKAcquringSdkError *error))onError
{
    [self presentAttachFormFromViewController:presentingViewController
                                    formTitle:title
                                   formHeader:header
                                  description:description
                                        email:email
                                cardCheckType:cardCheckType
                                  customerKey:customerKey
                               additionalData:data
                    isDissmissAfterCompletion:YES
                                      success:onSuccess
                                    cancelled:onCancelled
                                        error:onError];
}

@end
