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
#import "ASDKLocalized.h"
#import <PassKit/PassKit.h>

@protocol ASDKAcquiringSdkCardRequisites <NSObject>

- (NSString*)cardNumber;
- (NSString*)cardExpireDate;

@end

@protocol ASDKAcquiringSdkCardScanner <NSObject>
/*!
 *  @discussion Сканирует карту
 *
 *  @param success блок в случае успеха
 *  @param failure блок в случае сканирования с ошибкой
 *  @param cancel  блок при отмене сканирования
 */
- (void)scanCardSuccess:(void (^)(id<ASDKAcquiringSdkCardRequisites> cardRequisites))success
                failure:(void (^)(ASDKAcquringSdkError *error))failure
                 cancel:(void (^)(void))cancel;

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
								  makeCharge:(BOOL)makeCharge
					   additionalPaymentData:(NSDictionary *)data
								 receiptData:(NSDictionary *)receiptData
									 success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								   cancelled:(void (^)(void))onCancelled
									   error:(void (^)(ASDKAcquringSdkError *error))onError;

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
                                       error:(void (^)(ASDKAcquringSdkError *error))onError;

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
					 error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (BOOL)isPayWithAppleAvailable NS_AVAILABLE_IOS(9_0);
+ (NSArray<PKPaymentNetwork> *)payWithAppleSupportedNetworks NS_AVAILABLE_IOS(9_0);

/*!
 * @bref оплата с помощью ApplePay, онлайн документация https://oplata.tinkoff.ru/landing/develop/documentation/Init
 *
 * @param amount - Сумма
 * @param orderId - Номер заказа в системе Продавца
 * @param description - Краткое описание товара
 *
 * @param customerKey - Идентификатор покупателя в системе Продавца. Если передается, то для данного покупателя будет осуществлена
 * привязка карты к данному идентификатору клиента CustomerKey. В нотификации на AUTHORIZED будет передан параметр CardId, 
 * подробнее см. метод GetGardList https://oplata.tinkoff.ru/landing/develop/documentation/GetCardList
 *
 * @param appleMerchantId - берётся из Target->Capabilities -> ApplePay Merchant IDs.
 * Создается в https://developer.apple.com/account/ios/identifier/merchant
 * Настраивается в сертификате https://developer.apple.com/account/ios/identifier/bundle  iOS App IDs -> Edit -> Apple Pay
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
 * @param additionalPaymentData - JSON объект содержащий дополнительные параметры в виде “ключ”:”значение”. 
 * Данные параметры будут переданы на страницу оплаты (в случае ее кастомизации). 
 * Максимальная длина для каждого передаваемого параметра: 
 *  Ключ – 20 знаков,
 *  Значение – 100 знаков.
 * Максимальное количество пар «ключ-значение» не может превышать 20.
 *
 * @param receiptData - JSON объект с данными чека, https://oplata.tinkoff.ru/landing/develop/documentation/Init "Структура объекта Receipt"
 *
 * @param shopsData - массив объектов Shop с данными Маркетплейса
 * @param shopsReceiptsData - массив объектов с чеками для каждого ShopCode из объекта Shops
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
					additionalPaymentData:(NSDictionary *)additionalPaymentData //JSON объект содержащий дополнительные параметры, например @{@"Email" : @"a@test.ru"}
							  receiptData:(NSDictionary *)receiptData // JSON объект с данными чека, обязательно должен быть объект Items в который вложены позиции чека Email и Taxation - Система налогообложения, значения: osn, usn_income, usn_income_outcome, envd, esn, или patent
								shopsData:(NSArray *)shopsData
						shopsReceiptsData:(NSArray *)shopsReceiptsData
								  success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
								cancelled:(void (^)(void))onCancelled
									error:(void (^)(ASDKAcquringSdkError *error))onError NS_AVAILABLE_IOS(9_0);

- (void)checkStatusTransaction:(NSString *)paymentId
					   success:(void (^)(ASDKPaymentStatus status))onSuccess
						 error:(void (^)(ASDKAcquringSdkError *error))onError;

- (void)refundTransaction:(NSString *)paymentId
				  success:(void (^)(void))onSuccess
					error:(void (^)(ASDKAcquringSdkError *error))onError;

/*!
 * @bref привязка карты без оплаты, онлайн документация https://oplata.tinkoff.ru/landing/develop/documentation/Init
 *
 * @param title - Заголовок экрана
 * @param header - заголовок для пояснения зачем надо привязывать карту
 * @param description - Краткое описание зачем надо привязывать карту
 *
 * @param customerKey - Идентификатор покупателя в системе Продавца.
 *
 * @param cardCheckType
 *  ASDKCardCheckType_NO – сохранить карту без проверок. Rebill ID для рекуррентных платежей не возвращается.
 *  ASDKCardCheckType_3DS – при сохранении карты выполнить проверку 3DS и выполнить списание, а затем отмену на 1 р. В этом случае RebillID будет только для 3DS карт. Карты, не поддерживающие 3DS, привязаны не будут.
 *  ASDKCardCheckType_HOLD – при сохранении сделать списание и затем отмену на 1 руб. RebillID для рекуррентных платежей возвращается в ответе.
 *  ASDKCardCheckType_3DSHOLD – при привязке карты выполняем проверку, поддерживает карта 3DS или нет. Если карта поддерживает 3DS, далее выполняем списание и затем отмену на 1 руб.
 *
 * @param onSuccess блок в случае успеха
 * @param onCancelled блок в случае сканирования с ошибкой
 * @param onError блок при отмене сканирования
 */

- (void)presentAttachFormFromViewController:(UIViewController *)presentingViewController
								  formTitle:(NSString *)title //Заголовок экрана
								 formHeader:(NSString *)header // заголовок для пояснения зачем надо привязывать карту
								description:(NSString *)description //описание зачем надо привязывать карту
									  email:(NSString *)email //
							  cardCheckType:(NSString *)cardCheckType //описание возможных значений в ASDKCard.h
								customerKey:(NSString *)customerKey // идетинификатор пользователя (для сохранеиня платежей и карт)
							 additionalData:(NSDictionary *)data //JSON объект содержащий дополнительные параметры, например @{@"Phone" : @"+71234567890"}
									success:(void (^)(ASDKResponseAttachCard *result))onSuccess
								  cancelled:(void (^)(void))onCancelled
									  error:(void (^)(ASDKAcquringSdkError *error))onError;

@end
