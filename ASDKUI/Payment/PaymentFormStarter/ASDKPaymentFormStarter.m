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
@property (nonatomic, strong) void (^onSuccess)(NSString *paymentId);
@property (nonatomic, strong) void (^onCancelled)();
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) NSString *onCompleteSuccessPaymentId;
@property (nonatomic, strong) ASDKAcquringSdkError *onCompleteError;

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
                              customKeyboard:(BOOL)keyboard
                                 customerKey:(NSString *)customerKey
                                     success:(void (^)(NSString *paymentId))onSuccess
                                   cancelled:(void (^)())onCancelled
                                       error:(void(^)(ASDKAcquringSdkError *error))onError
{
    [self prepareDesign];
    
    ASDKPaymentFormViewController *vc = [[ASDKPaymentFormViewController alloc] initWithAmount:amount
                                                                                      orderId:orderId
                                                                                        title:title
                                                                                  description:description
                                                                                       cardId:cardId
                                                                                        email:email
                                                                                  customerKey:customerKey
                                                                               customKeyboard:keyboard
                                                                                      success:^(NSString *paymentId)
                                         {
                                             [ASDKPaymentFormStarter resetSharedInstance];
                                             
                                             onSuccess(paymentId);
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
    
    [ASDKCardsListDataController cardsListDataControllerWithAcquiringSdk:self.acquiringSdk customerKey:customerKey];
    
    [presentingViewController presentViewController:nc animated:YES completion:nil];
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
	BOOL canMakePaymentsUsingNetworks = [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[ASDKPaymentFormStarter payWithAppleSupportedNetworks]];
	
	return canMakePayments && canMakePaymentsUsingNetworks;
}

+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks
{
	return  @[//PKPaymentNetworkAmex,
			  //PKPaymentNetworkChinaUnionPay,
			  PKPaymentNetworkDiscover,
			  //PKPaymentNetworkInterac,
			  PKPaymentNetworkMasterCard,
			  //PKPaymentNetworkPrivateLabel,
			  PKPaymentNetworkVisa];
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
								  success:(void (^)(NSString *paymentId))onSuccess
								cancelled:(void (^)())onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError
{
	///////////////
	self.onSuccess = onSuccess;
	self.onError = onError;
	self.onCancelled = onCancelled;

	[self.acquiringSdk initWithAmount:[NSNumber numberWithDouble:100 * amount.doubleValue] orderId:orderId description:nil payForm:nil customerKey:customerKey recurrent:NO
		success:^(ASDKInitResponse *response){
			self.paymentIdForApplePay = response.paymentId;
			
			PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
			paymentRequest.merchantIdentifier = appleMerchantId;
			paymentRequest.countryCode = @"RU";
			paymentRequest.currencyCode = @"RUB";
			paymentRequest.supportedNetworks = [ASDKPaymentFormStarter payWithAppleSupportedNetworks];
			paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
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
			PKAddressField addressFieldShipping = PKAddressFieldNone;
			if (shippingContact.postalAddress) { addressFieldShipping |= PKAddressFieldPostalAddress; }
			if (shippingContact.name) { addressFieldShipping |= PKAddressFieldName; }
			if (shippingContact.emailAddress) { addressFieldShipping |= PKAddressFieldEmail; }
			if (shippingContact.phoneNumber) { addressFieldShipping |= PKAddressFieldPhone; }
			paymentRequest.shippingContact = shippingContact;
			paymentRequest.requiredShippingAddressFields = addressFieldShipping;
			
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

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
					   didAuthorizePayment:(PKPayment *)payment
								completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
	if (completion)
	{
		NSString *encryptedPaymentData = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
		//encryptedPaymentData = @"paymentId={\"version\":\"EC_v1\",\"data\":\"bhgLPJ+Wra1MlGtYd1M2dHHXC1QqZOcIXC7TwbsNcVlqUZBEEYFCdI0NSCGk+EkU6VKgB64qL6N+lfvQFXKPQdjY8m4w7jRXlKGWC8HpjAUKFggyjDjnEaJZ4eXOvtpn+D5MQb4+YMl+o3ECOKvLfjGWp7WkxFbpl+Gs1LkntofBFBZ4Hq3IWRysfLUcTeRqDGgNk7LiHwVLzj9FTqh6TpFfQoDaQtJ1Ga/k3j/gMAJVtlwZ6CGGM9yjLtr3pjTWDp4tUieSeWsbAMMkB/0J9zK1V0L3rZ4tmY5DU6Xewl4dmQBxNXQ8MoqTdKQlqcrN9qRhlpUtiEJJEOBOMu2PmiShp+TZnjRb09Jva9rqeGIdGT57GlpXBVEEe8xgh62aMbxpWKVCEzTEsiI0fcw4\",\"signature\":\"MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCAMIID4jCCA4igAwIBAgIIJEPyqAad9XcwCgYIKoZIzj0EAwIwejEuMCwGA1UEAwwlQXBwbGUgQXBwbGljYXRpb24gSW50ZWdyYXRpb24gQ0EgLSBHMzEmMCQGA1UECwwdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMB4XDTE0MDkyNTIyMDYxMVoXDTE5MDkyNDIyMDYxMVowXzElMCMGA1UEAwwcZWNjLXNtcC1icm9rZXItc2lnbl9VQzQtUFJPRDEUMBIGA1UECwwLaU9TIFN5c3RlbXMxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEwhV37evWx7Ihj2jdcJChIY3HsL1vLCg9hGCV2Ur0pUEbg0IO2BHzQH6DMx8cVMP36zIg1rrV1O/0komJPnwPE";
		
		[self.acquiringSdk finishAuthorizeWithPaymentId:self.paymentIdForApplePay
								   encryptedPaymentData:encryptedPaymentData
											   cardData:nil
											  infoEmail:payment.billingContact.emailAddress
												success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
													completion(PKPaymentAuthorizationStatusSuccess);
													self.onCompleteSuccessPaymentId = paymentInfo.paymentId;
												}
												failure:^(ASDKAcquringSdkError *error) {
													completion(PKPaymentAuthorizationStatusFailure);
													self.onCompleteError = error;
												}];
	}
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
	[self.presentingViewControllerApplePay dismissViewControllerAnimated:YES completion:^{
		if ([self.onCompleteSuccessPaymentId length] > 0 && self.onCompleteError == nil)
		{
			self.onSuccess(self.onCompleteSuccessPaymentId);
			self.onCompleteSuccessPaymentId = nil;
		}
		else if ([self.onCompleteSuccessPaymentId length] == 0 && self.onCompleteError == nil)
		{
			self.onCancelled();
		}
		else if (self.onCompleteError != nil)
		{
			self.onError(self.onCompleteError);
			self.onCompleteError = nil;
		}
	}];
}

@end
