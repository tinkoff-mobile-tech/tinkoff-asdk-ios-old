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
//
@property (nonatomic, strong) void (^onSuccess)(NSString *paymentId);
@property (nonatomic, strong) void (^onCancelled)();
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

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
	return [PKPaymentAuthorizationViewController canMakePayments] &&
	[PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[ASDKPaymentFormStarter payWithAppleSupportedNetworks]];
}

+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks
{
	return  @[//PKPaymentNetworkAmex,
			  //PKPaymentNetworkChinaUnionPay,
			  //PKPaymentNetworkDiscover,
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
								 recurent:(BOOL)recurent
								sendEmail:(BOOL)sendEmail
									email:(NSString *)email
						  appleMerchantId:(NSString *)appleMerchantId
						  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods
						  shippingContact:(PKContact *)shippingContact
								  success:(void (^)(NSString *paymentId))onSuccess
								cancelled:(void (^)())onCancelled
									error:(void(^)(ASDKAcquringSdkError *error))onError
{
	self.onSuccess = onSuccess;
	self.onError = onError;
	self.onCancelled = onCancelled;

	PKPaymentRequest *paymentRequest = [PKPaymentRequest new];
	paymentRequest.merchantIdentifier = appleMerchantId;
	paymentRequest.countryCode = @"RU";
	paymentRequest.currencyCode = @"RUB";
	paymentRequest.supportedNetworks = [ASDKPaymentFormStarter payWithAppleSupportedNetworks];
	paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
	//paymentSummaryItems
	NSMutableArray *paymentSummaryItems = [NSMutableArray new];//
	[paymentSummaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:description amount:[NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]]]];
	for (PKShippingMethod *method in shippingMethods)
 	{
		[paymentSummaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:method.identifier amount:[NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]]]];
	}
	
	paymentRequest.paymentSummaryItems = paymentSummaryItems;
	
	//paymentRequest.shippingMethods = shippingMethods;
	
	PKAddressField addressField = PKAddressFieldNone;
	
	//if (sendEmail == YES)
	{
		addressField |= PKAddressFieldEmail;
	}
	
	//if (contact && contact.postalAddress)
	{
		if (addressField == PKAddressFieldNone)
		{
			addressField = PKAddressFieldPostalAddress;
			addressField |= PKAddressFieldPhone;
		}
		else
		{
			addressField |= PKAddressFieldPostalAddress;
			addressField |= PKAddressFieldPhone;
		}
		
		addressField = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldEmail|PKAddressFieldName;
	}
	
	paymentRequest.requiredBillingAddressFields = addressField;
	paymentRequest.requiredShippingAddressFields = addressField;
	
	paymentRequest.shippingContact = shippingContact;
	
	PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
	viewController.delegate = self;

	if (viewController)
	{
		self.presentingViewControllerApplePay = presentingViewController;
		[self.presentingViewControllerApplePay presentViewController:viewController animated:YES completion:^{
			
		}];
	}
	else
	{
		onError(nil);
	}
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
					   didAuthorizePayment:(PKPayment *)payment
								completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
	if (completion)
	{
		NSString *paymentDataString = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];
		
		[self.acquiringSdk finishAuthorizeWithPaymentId:paymentDataString
											   cardData:@""
											  infoEmail:payment.billingContact.emailAddress
												success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
													completion(PKPaymentAuthorizationStatusSuccess);
													self.onSuccess(paymentDataString);
												}
												failure:^(ASDKAcquringSdkError *error) {
													completion(PKPaymentAuthorizationStatusFailure);
													self.onError(error);
												}];
	}
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
	[self.presentingViewControllerApplePay dismissViewControllerAnimated:YES completion:^{
		
	}];
}

@end
