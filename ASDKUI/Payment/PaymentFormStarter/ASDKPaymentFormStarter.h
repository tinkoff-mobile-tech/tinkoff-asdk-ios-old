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
								   recurrent:(BOOL)recurrent
					   additionalPaymentData:(NSDictionary *)data
                                     success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
                                   cancelled:(void (^)())onCancelled
                                       error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (BOOL)isPayWithAppleAvailable NS_AVAILABLE_IOS(9_0);
+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks NS_AVAILABLE_IOS(9_0);

/**
 * @bref оплата с помощью ApplePay, онлайн документация https://oplata.tinkoff.ru/documentation/?section=Init
 *
 * @param amount - Сумма
 * @param orderId - Номер заказа в системе Продавца
 * @param description - Краткое описание товара
 *
 * @param customerKey - Идентификатор покупателя в системе Продавца. Если передается, то для данного покупателя будет осуществлена
 * привязка карты к данному идентификатору клиента CustomerKey. В нотификации на AUTHORIZED будет передан параметр CardId, 
 * подробнее см. метод GetGardList https://oplata.tinkoff.ru/documentation/?section=GetCardList
 *
 * @param appleMerchantId - берётся из Target->Capabilities->ApplePay Merchant IDs. 
 * Создается в https://developer.apple.com/account/ios/identifier/merchant
 * Настраивается в сертификате https://developer.apple.com/account/ios/identifier/bundle  iOS App IDs-> Edit -> Apple Pay
 *
 * @param shippingMethods - доставка и стоимость доставки, 
 * например "доставка курьером стоимость 300руб." @[[PKShippingMethod summaryItemWithLabel:@"Доставка курьером" amount:[NSDecimalNumber decimalNumberWithString:@"300"]]]
 *
 * @param shippingContact - кому доставить и адрес доставки
 *
 * @param shippingEditableFields - какие поля можно показывать и редактировть на форме оплаты Apple Pay, например
 * PKAddressFieldNone - ни одного (и не показывать) 
 * PKAddressFieldPostalAddress|PKAddressFieldName|PKAddressFieldEmail|PKAddressFieldPhone - Адрес ФИО Email и Телефон
 *
 * @param additionalPaymentData - Ключ=значение дополнительных параметров через “|”, например Email=a@test.ru|Phone=+71234567890,
 * если ключи или значения содержат в себе спец символы, то получившееся значение должно быть закодировано функцией urlencode.
 * При этом, обязательным является наличие дополнительного параметра Email. Прочие можно добавлять по желанию.
 * Данные параметры будут переданы на страницу оплаты (в случае ее кастомизации). Максимальная длина для каждого передаваемого параметра:
 * Ключ – 20 знаков, Значение – 100 знаков. Максимальное количество пар «ключ-значение» не может превышать 20.
 * Пример передачи данных в параметре DATA: DATA=Phone=+71234567890|Email=a@test.com
 *
 * @param onSuccess блок в случае успеха
 * @param onCancelled блок в случае сканирования с ошибкой
 * @param onError блок при отмене сканирования
 */

- (void)payWithApplePayFromViewController:(UIViewController *)presentingViewController
								   amount:(NSNumber *)amount // цена товара
								  orderId:(NSString *)orderId // идентификатор товара
							  description:(NSString *)description // описание
							  customerKey:(NSString *)customerKey // идетинификатор пользователя (для сохранеиня платежей)
								sendEmail:(BOOL)sendEmail // отправлять чек на почту
									email:(NSString *)email
						  appleMerchantId:(NSString *)appleMerchantId // берётся из Target->Capabilities->ApplePay Merchant IDs
						  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods //доставка и стоимость доставки
						  shippingContact:(PKContact *)shippingContact //кому доставить и адрес доставки
				   shippingEditableFields:(PKAddressField)shippingEditableFields //какие поля можно показывать и редактировть на форме оплаты ApplePay
								recurrent:(BOOL)recurrent
					additionalPaymentData:(NSDictionary *)additionalPaymentData // Ключ=значение дополнительных параметров через “|”, например Email=a@test.ru|Phone=+71234567890
								  success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								cancelled:(void (^)())onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError NS_AVAILABLE_IOS(9_0);

- (void)checkStatusTransaction:(NSString *)paymentId
					   success:(void (^)(ASDKPaymentStatus status))onSuccess
						 error:(void (^)(ASDKAcquringSdkError *error))onError;

- (void)refundTransaction:(NSString *)paymentId
				  success:(void (^)())onSuccess
					error:(void (^)(ASDKAcquringSdkError *error))onError;

@end
