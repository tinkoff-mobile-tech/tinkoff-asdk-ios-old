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

@property (nonatomic,strong) ASDKAcquiringSdk *acquiringSdk;

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

- (void)dealloc
{
    NSLog(@"STARTER DEALLOC");
}

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
	BOOL canMakePaymentsUsingNetworks = NO;
 
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_0)
	{
		canMakePaymentsUsingNetworks = [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[ASDKPaymentFormStarter payWithAppleSupportedNetworks]];
	}

	return canMakePayments && canMakePaymentsUsingNetworks;
}

+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks
{
	NSArray<PKPaymentNetwork> *result = nil;
	
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_0)
	{
		result = @[//PKPaymentNetworkAmex,
				   //PKPaymentNetworkChinaUnionPay,
				   //PKPaymentNetworkDiscover,
				   //PKPaymentNetworkInterac,
				   PKPaymentNetworkMasterCard,
				   //PKPaymentNetworkPrivateLabel,
				   PKPaymentNetworkVisa];
	}
	else
	{
		result = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
	}

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
								  success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								cancelled:(void (^)(void))onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError
{
	///////////////
	self.onSuccess = onSuccess;
	self.onError = onError;
	self.onCancelled = onCancelled;

	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble:100 * amount.doubleValue] orderId:orderId description:nil payForm:nil customerKey:customerKey recurrent:recurrent additionalPaymentData:additionalPaymentData receiptData:receiptData
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
			
			//
			//PKAddressField shippingEditableFields = PKAddressFieldNone;
			//if (shippingContact.postalAddress) { shippingEditableFields |= PKAddressFieldPostalAddress; }
			//if (shippingContact.name) { shippingEditableFields |= PKAddressFieldName; }
			//if (shippingContact.emailAddress) { shippingEditableFields |= PKAddressFieldEmail; }
			//if (shippingContact.phoneNumber) { shippingEditableFields |= PKAddressFieldPhone; }
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
				self.onError(nil);
			}
		}
		failure:^(ASDKAcquringSdkError *error){
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
				   success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
					 error:(void (^)(ASDKAcquringSdkError *error))onError
{
	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble:100 * amount.doubleValue] orderId:orderId description:description payForm:nil customerKey:customerKey recurrent:NO additionalPaymentData:data receiptData:receiptData
	 success:^(ASDKInitResponse *response) {
		 [self.acquiringSdk chargeWithPaymentId:response.paymentId rebillId:rebillId success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
			 [ASDKPaymentFormStarter resetSharedInstance];
			 onSuccess(paymentInfo);
		 } failure:^(ASDKAcquringSdkError *error) {
			 [ASDKPaymentFormStarter resetSharedInstance];
			 onError(error);
		 }];
	 } failure:^(ASDKAcquringSdkError *error) {
		 onError(error);
	 }];
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

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
			NSString *message = @"Payment state error";
			NSString *details = [NSString stringWithFormat:@"%@", self.onCompleteSuccessPaymentInfo];
			ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage:message details:details code:0];
			self.onError(error);
			self.onCompleteError = nil;
		}
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
									success:(void (^)(ASDKResponseAttachCard *result))onSuccess
								  cancelled:(void (^)(void))onCancelled
									  error:(void (^)(ASDKAcquringSdkError *error))onError
{
	[self prepareDesign];

//	ASDKLoopViewController *viewController = [[ASDKLoopViewController alloc] initWithAddCardRequestKey:@"1" acquiringSdk:self.acquiringSdk];
	
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

	viewController.acquiringSdk = self.acquiringSdk;
	
	ASDKNavigationController *nc = [[ASDKNavigationController alloc] initWithRootViewController:viewController];
	[nc setModalPresentationStyle:self.designConfiguration.modalPresentationStyle];
	[ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey];
	[presentingViewController presentViewController:nc animated:YES completion:nil];
}

@end
