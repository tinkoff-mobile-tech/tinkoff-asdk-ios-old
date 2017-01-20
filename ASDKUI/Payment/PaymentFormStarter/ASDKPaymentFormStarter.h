//
//  ASDKPaymentFormStarter.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ASDKCore/ASDKCore.h>
#import "ASDKDesignConfiguration.h"
#import <PassKit/PassKit.h>

@protocol ASDKAcquiringSdkCardScanner <NSObject>
/*!
 *  @discussion Сканирует карту
 *
 *  @param success блок в случае успеха
 *  @param failure блок в случае сканирования с ошибкой
 *  @param cancel  блок при отмене сканирования
 */
- (void)scanCardSuccess:(void (^)(NSString *cardNumber))success
                failure:(void (^)(ASDKAcquringSdkError *error))failure
                 cancel:(void (^)())cancel;

@end

@interface ASDKPaymentFormStarter : NSObject

@property (nonatomic, strong) id<ASDKAcquiringSdkCardScanner> cardScanner;

/*!
 *  @brief конфигурация дизайна
 */
@property (nonatomic, strong) ASDKDesignConfiguration *designConfiguration;

+ (instancetype)instance;

/*!
 *  Создаем инстанс стартера
 *
 *  @param acquiringSdk движок
 *
 *  @return инстанс
 */
+ (instancetype)paymentFormStarterWithAcquiringSdk:(ASDKAcquiringSdk *)acquiringSdk;


- (void)presentPaymentFormFromViewController:(UIViewController *)presentingViewController
                                     orderId:(NSString *)orderId
                                      amount:(NSNumber *)amount
                                       title:(NSString *)title
                                 description:(NSString *)description
                                      cardId:(NSString *)cardId
                                       email:(NSString *)email
                                 customerKey:(NSString *)customerKey
					   additionalPaymentData:(NSDictionary *)data
                                     success:(void (^)(NSString *paymentId))onSuccess
                                   cancelled:(void (^)())onCancelled
                                       error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (BOOL)isPayWithAppleAvailable NS_AVAILABLE_IOS(10_2) __WATCHOS_AVAILABLE(3.0);
+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks NS_AVAILABLE_IOS(10_2) __WATCHOS_AVAILABLE(3.0);

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
					additionalPaymentData:(NSDictionary *)data
								  success:(void (^)(NSString *paymentId))onSuccess
								cancelled:(void (^)())onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError NS_AVAILABLE_IOS(10_2) __WATCHOS_AVAILABLE(3.0);

@end
