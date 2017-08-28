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
@property (nonatomic, strong) void (^onSuccess)(ASDKPaymentInfo *paymentInfo);
@property (nonatomic, strong) void (^onCancelled)();
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, strong) ASDKPaymentInfo *onCompleteSuccessPaymentInfo;
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
                                 customerKey:(NSString *)customerKey
								   recurrent:(BOOL)recurrent
					   additionalPaymentData:(NSDictionary *)data
								 receiptData:(NSDictionary *)receiptData
                                     success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
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
																					recurrent:recurrent
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
								cancelled:(void (^)())onCancelled
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
				  success:(void (^)())onSuccess
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
		//NSString *encryptedPaymentData = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
		//encryptedPaymentData = @"paymentId={\"version\":\"EC_v1\",\"data\":\"bhgLPJ+Wra1MlGtYd1M2dHHXC1QqZOcIXC7TwbsNcVlqUZBEEYFCdI0NSCGk+EkU6VKgB64qL6N+lfvQFXKPQdjY8m4w7jRXlKGWC8HpjAUKFggyjDjnEaJZ4eXOvtpn+D5MQb4+YMl+o3ECOKvLfjGWp7WkxFbpl+Gs1LkntofBFBZ4Hq3IWRysfLUcTeRqDGgNk7LiHwVLzj9FTqh6TpFfQoDaQtJ1Ga/k3j/gMAJVtlwZ6CGGM9yjLtr3pjTWDp4tUieSeWsbAMMkB/0J9zK1V0L3rZ4tmY5DU6Xewl4dmQBxNXQ8MoqTdKQlqcrN9qRhlpUtiEJJEOBOMu2PmiShp+TZnjRb09Jva9rqeGIdGT57GlpXBVEEe8xgh62aMbxpWKVCEzTEsiI0fcw4\",\"signature\":\"MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCAMIID4jCCA4igAwIBAgIIJEPyqAad9XcwCgYIKoZIzj0EAwIwejEuMCwGA1UEAwwlQXBwbGUgQXBwbGljYXRpb24gSW50ZWdyYXRpb24gQ0EgLSBHMzEmMCQGA1UECwwdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMB4XDTE0MDkyNTIyMDYxMVoXDTE5MDkyNDIyMDYxMVowXzElMCMGA1UEAwwcZWNjLXNtcC1icm9rZXItc2lnbl9VQzQtUFJPRDEUMBIGA1UECwwLaU9TIFN5c3RlbXMxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEwhV37evWx7Ihj2jdcJChIY3HsL1vLCg9hGCV2Ur0pUEbg0IO2BHzQH6DMx8cVMP36zIg1rrV1O/0komJPnwPE";
//		encryptedPaymentData = [RSA encryptString:@"eyJ2ZXJzaW9uIjoiRUNfdjEiLCJkYXRhIjoibHUyUnhma0E1TXBZclZMYXZWamN5NERZamZGQ1NBQXErek5Ic0dKN2FtWmlrY2prZWt6MGc5cmx0SmcxaG1JT1pwNGMyZFQvRWtLK2QvWHB6aWY3T1FXNWJrVGdaazVVa2Z1YjY2MXhoZXNiLzAxSGpjL0xCNVVpQjhKaFdhVWJCNmdIdHVzTkEydFI3eDRjRWkvRFhGd003OGl6bXZRNDFyYWZYa09VUnRlZUd1WmZLYVNoU0xOR2Z2QkpTMlJrSnpya0hHTUZPd0NtNDRjc056SGJBMWN6UjgraUxESndKQWpaNHd6UWtQRWpUei8xZCs4bU1jbjlJSU1kMjEzUkVjaUY0YXFrUjROTzRoeHp4WVRDMVNQazI2MEhEWlRBd2pIN0t6U1ZmaWkzREFSQmtmenVZOTB0aUtUOHZzblVKSUI3Q3R3VU8rT09lMU83a0Jtd1IvendoWW00MGFNdjhEdTBaM2RsSW5MYzB1NkFkTlZ3WFhsTS9tSjk3TWVTbmZiMUxxdUJnaE9KZjQxbmpvWT0iLCJzaWduYXR1cmUiOiJNSUFHQ1NxR1NJYjNEUUVIQXFDQU1JQUNBUUV4RHpBTkJnbGdoa2dCWlFNRUFnRUZBRENBQmdrcWhraUc5dzBCQndFQUFLQ0FNSUlENGpDQ0E0aWdBd0lCQWdJSUpFUHlxQWFkOVhjd0NnWUlLb1pJemowRUF3SXdlakV1TUN3R0ExVUVBd3dsUVhCd2JHVWdRWEJ3YkdsallYUnBiMjRnU1c1MFpXZHlZWFJwYjI0Z1EwRWdMU0JITXpFbU1DUUdBMVVFQ3d3ZFFYQndiR1VnUTJWeWRHbG1hV05oZEdsdmJpQkJkWFJvYjNKcGRIa3hFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1CNFhEVEUwTURreU5USXlNRFl4TVZvWERURTVNRGt5TkRJeU1EWXhNVm93WHpFbE1DTUdBMVVFQXd3Y1pXTmpMWE50Y0MxaWNtOXJaWEl0YzJsbmJsOVZRelF0VUZKUFJERVVNQklHQTFVRUN3d0xhVTlUSUZONWMzUmxiWE14RXpBUkJnTlZCQW9NQ2tGd2NHeGxJRWx1WXk0eEN6QUpCZ05WQkFZVEFsVlRNRmt3RXdZSEtvWkl6ajBDQVFZSUtvWkl6ajBEQVFjRFFnQUV3aFYzN2V2V3g3SWhqMmpkY0pDaElZM0hzTDF2TENnOWhHQ1YyVXIwcFVFYmcwSU8yQkh6UUg2RE14OGNWTVAzNnpJZzFyclYxTy8wa29tSlBud1BFNk9DQWhFd2dnSU5NRVVHQ0NzR0FRVUZCd0VCQkRrd056QTFCZ2dyQmdFRkJRY3dBWVlwYUhSMGNEb3ZMMjlqYzNBdVlYQndiR1V1WTI5dEwyOWpjM0F3TkMxaGNIQnNaV0ZwWTJFek1ERXdIUVlEVlIwT0JCWUVGSlJYMjIvVmRJR0dpWWwyTDM1WGhRZm5tMWdrTUF3R0ExVWRFd0VCL3dRQ01BQXdId1lEVlIwakJCZ3dGb0FVSS9KSnhFK1Q1TzhuNXNUMktHdy9vcnY5TGtzd2dnRWRCZ05WSFNBRWdnRVVNSUlCRURDQ0FRd0dDU3FHU0liM1kyUUZBVENCL2pDQnd3WUlLd1lCQlFVSEFnSXdnYllNZ2JOU1pXeHBZVzVqWlNCdmJpQjBhR2x6SUdObGNuUnBabWxqWVhSbElHSjVJR0Z1ZVNCd1lYSjBlU0JoYzNOMWJXVnpJR0ZqWTJWd2RHRnVZMlVnYjJZZ2RHaGxJSFJvWlc0Z1lYQndiR2xqWVdKc1pTQnpkR0Z1WkdGeVpDQjBaWEp0Y3lCaGJtUWdZMjl1WkdsMGFXOXVjeUJ2WmlCMWMyVXNJR05sY25ScFptbGpZWFJsSUhCdmJHbGplU0JoYm1RZ1kyVnlkR2xtYVdOaGRHbHZiaUJ3Y21GamRHbGpaU0J6ZEdGMFpXMWxiblJ6TGpBMkJnZ3JCZ0VGQlFjQ0FSWXFhSFIwY0RvdkwzZDNkeTVoY0hCc1pTNWpiMjB2WTJWeWRHbG1hV05oZEdWaGRYUm9iM0pwZEhrdk1EUUdBMVVkSHdRdE1Dc3dLYUFub0NXR0kyaDBkSEE2THk5amNtd3VZWEJ3YkdVdVkyOXRMMkZ3Y0d4bFlXbGpZVE11WTNKc01BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUEJna3Foa2lHOTJOa0JoMEVBZ1VBTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSUhLS253K1NveXE1bVhRcjFWNjJjMEJYS3BhSG9kWXU5VFdYRVBVV1BwYnBBaUVBa1RlY2ZXNitXNWwwcjBBRGZ6VENQcTJZdGJTMzl3MDFYSWF5cUJOeThiRXdnZ0x1TUlJQ2RhQURBZ0VDQWdoSmJTKy9PcGphbHpBS0JnZ3Foa2pPUFFRREFqQm5NUnN3R1FZRFZRUUREQkpCY0hCc1pTQlNiMjkwSUVOQklDMGdSek14SmpBa0JnTlZCQXNNSFVGd2NHeGxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1STXdFUVlEVlFRS0RBcEJjSEJzWlNCSmJtTXVNUXN3Q1FZRFZRUUdFd0pWVXpBZUZ3MHhOREExTURZeU16UTJNekJhRncweU9UQTFNRFl5TXpRMk16QmFNSG94TGpBc0JnTlZCQU1NSlVGd2NHeGxJRUZ3Y0d4cFkyRjBhVzl1SUVsdWRHVm5jbUYwYVc5dUlFTkJJQzBnUnpNeEpqQWtCZ05WQkFzTUhVRndjR3hsSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVFzd0NRWURWUVFHRXdKVlV6QlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJQQVhFWVFaMTJTRjFScGVKWUVIZHVpQW91L2VlNjVONEkzOFM1UGhNMWJWWmxzMXJpTFFsM1lOSWs1N3VnajlkaGZPaU10MnUyWnd2c2pvS1lUL1ZFV2pnZmN3Z2ZRd1JnWUlLd1lCQlFVSEFRRUVPakE0TURZR0NDc0dBUVVGQnpBQmhpcG9kSFJ3T2k4dmIyTnpjQzVoY0hCc1pTNWpiMjB2YjJOemNEQTBMV0Z3Y0d4bGNtOXZkR05oWnpNd0hRWURWUjBPQkJZRUZDUHlTY1JQaytUdkorYkU5aWhzUDZLNy9TNUxNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdId1lEVlIwakJCZ3dGb0FVdTdEZW9WZ3ppSnFraXBuZXZyM3JyOXJMSktzd053WURWUjBmQkRBd0xqQXNvQ3FnS0lZbWFIUjBjRG92TDJOeWJDNWhjSEJzWlM1amIyMHZZWEJ3YkdWeWIyOTBZMkZuTXk1amNtd3dEZ1lEVlIwUEFRSC9CQVFEQWdFR01CQUdDaXFHU0liM1kyUUdBZzRFQWdVQU1Bb0dDQ3FHU000OUJBTUNBMmNBTUdRQ01EclBjb05SRnBteGh2czF3MWJLWXIvMEYrM1pEM1ZOb282KzhaeUJYa0szaWZpWTk1dFpuNWpWUVEyUG5lbkMvZ0l3TWkzVlJDR3dvd1YzYkYzek9EdVFaLzBYZkN3aGJaWlB4bkpwZ2hKdlZQaDZmUnVaeTVzSmlTRmhCcGtQQ1pJZEFBQXhnZ0ZmTUlJQld3SUJBVENCaGpCNk1TNHdMQVlEVlFRRERDVkJjSEJzWlNCQmNIQnNhV05oZEdsdmJpQkpiblJsWjNKaGRHbHZiaUJEUVNBdElFY3pNU1l3SkFZRFZRUUxEQjFCY0hCc1pTQkRaWEowYVdacFkyRjBhVzl1SUVGMWRHaHZjbWwwZVRFVE1CRUdBMVVFQ2d3S1FYQndiR1VnU1c1akxqRUxNQWtHQTFVRUJoTUNWVk1DQ0NSRDhxZ0duZlYzTUEwR0NXQ0dTQUZsQXdRQ0FRVUFvR2t3R0FZSktvWklodmNOQVFrRE1Rc0dDU3FHU0liM0RRRUhBVEFjQmdrcWhraUc5dzBCQ1FVeER4Y05NVFl4TVRBNE1UQTBOakE0V2pBdkJna3Foa2lHOXcwQkNRUXhJZ1FnNXBWMEQvRjE1NVIrS0xEbm1GOHpzV2dhQ2ZzZzhhNnV1RGVEL1JadUxjd3dDZ1lJS29aSXpqMEVBd0lFUnpCRkFpQjVqbVRvcHNIUFBrZ1dESEFhMkhZYlRmWkdJMExxcHBEUlRQZmppU1BUWHdJaEFPVGRJSVBBV3dpSkNpUzJZb1I3cTAwT1NOM1Q2R3FRU3Z1ZVVNTDcrN0luQUFBQUFBQUEiLCJoZWFkZXIiOnsiZXBoZW1lcmFsUHVibGljS2V5IjoiTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFSW53a0tNMFM4bFNVSzU4OEc5WlVPZ0xMV2h0bFlyd1R4UCtwMnZZOEl2bktaeUZFZ2llT0t4cmt4dEowNmttdmJSK1o3dEZLbk5DSGF3N2xhTDh2bVE9PSIsInB1YmxpY0tleUhhc2giOiJmVFg0REExUFlPQ1V6MGZpZEUrQnNsd1laU1FoV2h5aGt2dUJtQjR1U29jPSIsInRyYW5zYWN0aW9uSWQiOiIwM2Y1OTkyYmYyMGEwM2U2NDQyMjBhNjQzYTVlM2E3NGE5N2ZiYTI4ZTg0OWY3MjhiNDg5MzJiZDhhNTZkOGJhIn19"
//									 publicKeyRef:[self.acquiringSdk publicKeyRef]];
		//encryptedPaymentData = @"eyJ2ZXJzaW9uIjoiRUNfdjEiLCJkYXRhIjoibHUyUnhma0E1TXBZclZMYXZWamN5NERZamZGQ1NBQXErek5Ic0dKN2FtWmlrY2prZWt6MGc5cmx0SmcxaG1JT1pwNGMyZFQvRWtLK2QvWHB6aWY3T1FXNWJrVGdaazVVa2Z1YjY2MXhoZXNiLzAxSGpjL0xCNVVpQjhKaFdhVWJCNmdIdHVzTkEydFI3eDRjRWkvRFhGd003OGl6bXZRNDFyYWZYa09VUnRlZUd1WmZLYVNoU0xOR2Z2QkpTMlJrSnpya0hHTUZPd0NtNDRjc056SGJBMWN6UjgraUxESndKQWpaNHd6UWtQRWpUei8xZCs4bU1jbjlJSU1kMjEzUkVjaUY0YXFrUjROTzRoeHp4WVRDMVNQazI2MEhEWlRBd2pIN0t6U1ZmaWkzREFSQmtmenVZOTB0aUtUOHZzblVKSUI3Q3R3VU8rT09lMU83a0Jtd1IvendoWW00MGFNdjhEdTBaM2RsSW5MYzB1NkFkTlZ3WFhsTS9tSjk3TWVTbmZiMUxxdUJnaE9KZjQxbmpvWT0iLCJzaWduYXR1cmUiOiJNSUFHQ1NxR1NJYjNEUUVIQXFDQU1JQUNBUUV4RHpBTkJnbGdoa2dCWlFNRUFnRUZBRENBQmdrcWhraUc5dzBCQndFQUFLQ0FNSUlENGpDQ0E0aWdBd0lCQWdJSUpFUHlxQWFkOVhjd0NnWUlLb1pJemowRUF3SXdlakV1TUN3R0ExVUVBd3dsUVhCd2JHVWdRWEJ3YkdsallYUnBiMjRnU1c1MFpXZHlZWFJwYjI0Z1EwRWdMU0JITXpFbU1DUUdBMVVFQ3d3ZFFYQndiR1VnUTJWeWRHbG1hV05oZEdsdmJpQkJkWFJvYjNKcGRIa3hFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1CNFhEVEUwTURreU5USXlNRFl4TVZvWERURTVNRGt5TkRJeU1EWXhNVm93WHpFbE1DTUdBMVVFQXd3Y1pXTmpMWE50Y0MxaWNtOXJaWEl0YzJsbmJsOVZRelF0VUZKUFJERVVNQklHQTFVRUN3d0xhVTlUSUZONWMzUmxiWE14RXpBUkJnTlZCQW9NQ2tGd2NHeGxJRWx1WXk0eEN6QUpCZ05WQkFZVEFsVlRNRmt3RXdZSEtvWkl6ajBDQVFZSUtvWkl6ajBEQVFjRFFnQUV3aFYzN2V2V3g3SWhqMmpkY0pDaElZM0hzTDF2TENnOWhHQ1YyVXIwcFVFYmcwSU8yQkh6UUg2RE14OGNWTVAzNnpJZzFyclYxTy8wa29tSlBud1BFNk9DQWhFd2dnSU5NRVVHQ0NzR0FRVUZCd0VCQkRrd056QTFCZ2dyQmdFRkJRY3dBWVlwYUhSMGNEb3ZMMjlqYzNBdVlYQndiR1V1WTI5dEwyOWpjM0F3TkMxaGNIQnNaV0ZwWTJFek1ERXdIUVlEVlIwT0JCWUVGSlJYMjIvVmRJR0dpWWwyTDM1WGhRZm5tMWdrTUF3R0ExVWRFd0VCL3dRQ01BQXdId1lEVlIwakJCZ3dGb0FVSS9KSnhFK1Q1TzhuNXNUMktHdy9vcnY5TGtzd2dnRWRCZ05WSFNBRWdnRVVNSUlCRURDQ0FRd0dDU3FHU0liM1kyUUZBVENCL2pDQnd3WUlLd1lCQlFVSEFnSXdnYllNZ2JOU1pXeHBZVzVqWlNCdmJpQjBhR2x6SUdObGNuUnBabWxqWVhSbElHSjVJR0Z1ZVNCd1lYSjBlU0JoYzNOMWJXVnpJR0ZqWTJWd2RHRnVZMlVnYjJZZ2RHaGxJSFJvWlc0Z1lYQndiR2xqWVdKc1pTQnpkR0Z1WkdGeVpDQjBaWEp0Y3lCaGJtUWdZMjl1WkdsMGFXOXVjeUJ2WmlCMWMyVXNJR05sY25ScFptbGpZWFJsSUhCdmJHbGplU0JoYm1RZ1kyVnlkR2xtYVdOaGRHbHZiaUJ3Y21GamRHbGpaU0J6ZEdGMFpXMWxiblJ6TGpBMkJnZ3JCZ0VGQlFjQ0FSWXFhSFIwY0RvdkwzZDNkeTVoY0hCc1pTNWpiMjB2WTJWeWRHbG1hV05oZEdWaGRYUm9iM0pwZEhrdk1EUUdBMVVkSHdRdE1Dc3dLYUFub0NXR0kyaDBkSEE2THk5amNtd3VZWEJ3YkdVdVkyOXRMMkZ3Y0d4bFlXbGpZVE11WTNKc01BNEdBMVVkRHdFQi93UUVBd0lIZ0RBUEJna3Foa2lHOTJOa0JoMEVBZ1VBTUFvR0NDcUdTTTQ5QkFNQ0EwZ0FNRVVDSUhLS253K1NveXE1bVhRcjFWNjJjMEJYS3BhSG9kWXU5VFdYRVBVV1BwYnBBaUVBa1RlY2ZXNitXNWwwcjBBRGZ6VENQcTJZdGJTMzl3MDFYSWF5cUJOeThiRXdnZ0x1TUlJQ2RhQURBZ0VDQWdoSmJTKy9PcGphbHpBS0JnZ3Foa2pPUFFRREFqQm5NUnN3R1FZRFZRUUREQkpCY0hCc1pTQlNiMjkwSUVOQklDMGdSek14SmpBa0JnTlZCQXNNSFVGd2NHeGxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1STXdFUVlEVlFRS0RBcEJjSEJzWlNCSmJtTXVNUXN3Q1FZRFZRUUdFd0pWVXpBZUZ3MHhOREExTURZeU16UTJNekJhRncweU9UQTFNRFl5TXpRMk16QmFNSG94TGpBc0JnTlZCQU1NSlVGd2NHeGxJRUZ3Y0d4cFkyRjBhVzl1SUVsdWRHVm5jbUYwYVc5dUlFTkJJQzBnUnpNeEpqQWtCZ05WQkFzTUhVRndjR3hsSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVFzd0NRWURWUVFHRXdKVlV6QlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJQQVhFWVFaMTJTRjFScGVKWUVIZHVpQW91L2VlNjVONEkzOFM1UGhNMWJWWmxzMXJpTFFsM1lOSWs1N3VnajlkaGZPaU10MnUyWnd2c2pvS1lUL1ZFV2pnZmN3Z2ZRd1JnWUlLd1lCQlFVSEFRRUVPakE0TURZR0NDc0dBUVVGQnpBQmhpcG9kSFJ3T2k4dmIyTnpjQzVoY0hCc1pTNWpiMjB2YjJOemNEQTBMV0Z3Y0d4bGNtOXZkR05oWnpNd0hRWURWUjBPQkJZRUZDUHlTY1JQaytUdkorYkU5aWhzUDZLNy9TNUxNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdId1lEVlIwakJCZ3dGb0FVdTdEZW9WZ3ppSnFraXBuZXZyM3JyOXJMSktzd053WURWUjBmQkRBd0xqQXNvQ3FnS0lZbWFIUjBjRG92TDJOeWJDNWhjSEJzWlM1amIyMHZZWEJ3YkdWeWIyOTBZMkZuTXk1amNtd3dEZ1lEVlIwUEFRSC9CQVFEQWdFR01CQUdDaXFHU0liM1kyUUdBZzRFQWdVQU1Bb0dDQ3FHU000OUJBTUNBMmNBTUdRQ01EclBjb05SRnBteGh2czF3MWJLWXIvMEYrM1pEM1ZOb282KzhaeUJYa0szaWZpWTk1dFpuNWpWUVEyUG5lbkMvZ0l3TWkzVlJDR3dvd1YzYkYzek9EdVFaLzBYZkN3aGJaWlB4bkpwZ2hKdlZQaDZmUnVaeTVzSmlTRmhCcGtQQ1pJZEFBQXhnZ0ZmTUlJQld3SUJBVENCaGpCNk1TNHdMQVlEVlFRRERDVkJjSEJzWlNCQmNIQnNhV05oZEdsdmJpQkpiblJsWjNKaGRHbHZiaUJEUVNBdElFY3pNU1l3SkFZRFZRUUxEQjFCY0hCc1pTQkRaWEowYVdacFkyRjBhVzl1SUVGMWRHaHZjbWwwZVRFVE1CRUdBMVVFQ2d3S1FYQndiR1VnU1c1akxqRUxNQWtHQTFVRUJoTUNWVk1DQ0NSRDhxZ0duZlYzTUEwR0NXQ0dTQUZsQXdRQ0FRVUFvR2t3R0FZSktvWklodmNOQVFrRE1Rc0dDU3FHU0liM0RRRUhBVEFjQmdrcWhraUc5dzBCQ1FVeER4Y05NVFl4TVRBNE1UQTBOakE0V2pBdkJna3Foa2lHOXcwQkNRUXhJZ1FnNXBWMEQvRjE1NVIrS0xEbm1GOHpzV2dhQ2ZzZzhhNnV1RGVEL1JadUxjd3dDZ1lJS29aSXpqMEVBd0lFUnpCRkFpQjVqbVRvcHNIUFBrZ1dESEFhMkhZYlRmWkdJMExxcHBEUlRQZmppU1BUWHdJaEFPVGRJSVBBV3dpSkNpUzJZb1I3cTAwT1NOM1Q2R3FRU3Z1ZVVNTDcrN0luQUFBQUFBQUEiLCJoZWFkZXIiOnsiZXBoZW1lcmFsUHVibGljS2V5IjoiTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFSW53a0tNMFM4bFNVSzU4OEc5WlVPZ0xMV2h0bFlyd1R4UCtwMnZZOEl2bktaeUZFZ2llT0t4cmt4dEowNmttdmJSK1o3dEZLbk5DSGF3N2xhTDh2bVE9PSIsInB1YmxpY0tleUhhc2giOiJmVFg0REExUFlPQ1V6MGZpZEUrQnNsd1laU1FoV2h5aGt2dUJtQjR1U29jPSIsInRyYW5zYWN0aW9uSWQiOiIwM2Y1OTkyYmYyMGEwM2U2NDQyMjBhNjQzYTVlM2E3NGE5N2ZiYTI4ZTg0OWY3MjhiNDg5MzJiZDhhNTZkOGJhIn19";

		[self.acquiringSdk finishAuthorizeWithPaymentId:self.paymentIdForApplePay
								   encryptedPaymentData:encryptedPaymentData
											   cardData:nil
											  infoEmail:payment.billingContact.emailAddress
												success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
													self.onCompleteSuccessPaymentInfo = paymentInfo;
													completion(PKPaymentAuthorizationStatusSuccess);
												}
												failure:^(ASDKAcquringSdkError *error) {
													self.onCompleteError = error;
													completion(PKPaymentAuthorizationStatusFailure);
												}];
	}
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
	[self.presentingViewControllerApplePay dismissViewControllerAnimated:YES completion:^{
		if (self.onCompleteSuccessPaymentInfo != nil && self.onCompleteError == nil)
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
	}];
}

@end
