# Tinkoff Acquiring SDK for iOS

![PayFormActivity][img-pay]

Acquiring SDK позволяет интегрировать [Интернет-Эквайрингу][acquiring] в мобильные приложения для платформы iOS.

Возможности SDK:
* Прием платежей (в том числе рекуррентных)
* Сохранение банковских карт клиента
* Сканирование и распознавание карт с помощью камеры
* Получение информации о клиенте и сохраненных картах
* Управление сохраненными картами
* Поддержка английского
* Оплата с помощью [ApplePay][applepay]

### Требования
Для работы Tinkoff Acquiring SDK необходим iOS версии 8.0 и выше.

### Подключение
Для подключения SDK мы рекомендуем использовать [Cocoa Pods][cocoapods]. Добавьте в файл Podfile зависимости
```c
pod 'CardIO'
pod 'ASDKCore', :podspec =>  "https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/ASDKCore.podspec"
pod 'ASDKUI', :podspec =>  "https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/ASDKUI.podspec"
```

Либо, если вы не используете [Cocoa Pods][cocoapods], можно добавить _**ASDKUI.xcodeproj**_ в ваш проект.

### Подготовка к работе
Для начала работы с SDK вам понадобятся:
* Terminal key
* Пароль
* Public key

которые выдаются после подключения к [Интернет-Эквайрингу][acquiring].

### Пример работы
Тестовое приложение _**ASDKSampleApp**_
оплата товара по реквизитам карты/ с ранее сохраненной карты

```objective-c
	BookItem *item;
	
    [PayController buyItemWithName:self.item.title
                       description:self.item.bookDescription
                            amount:self.item.cost
			 additionalPaymentData:@{@"Email":@"a@test.ru", @"Phone":@"+71234567890"}
                fromViewController:self
                           success:^(NSString *paymentId) {  NSLog(@"%@",paymentId);  }
                         cancelled:^  { NSLog(@"Canceled"); }
                             error:^(ASDKAcquringSdkError *error) { NSLog(@"%@",error); }];
```
оплата товара через Apple Pay

```objective-c

	BookItem *item;
	
	if ([PayController isPayWithAppleAvailable])
	{
		PKContact *shippingContact = [[PKContact alloc] init];
		shippingContact.emailAddress = @"test@gmail.com";
		shippingContact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:@"+74956481000"];
		CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc] init];
		[postalAddress setStreet:@"Головинское шоссе, дом 5, корп. 1,"];
		[postalAddress setCountry:@"Россия"];
		[postalAddress setCity:@"Москва"];
		[postalAddress setPostalCode:@"125212"];
		[postalAddress setISOCountryCode:@"643"];
		shippingContact.postalAddress = [postalAddress copy];
		
		[PayController buyWithApplePayAmount:self.item.cost
								 description:self.item.title
									   email:shippingContact.emailAddress
							 appleMerchantId:@"merchant.tcsbank.ApplePayTestMerchantId"
							 shippingMethods:nil //example @[[PKShippingMethod summaryItemWithLabel:@"Доставка" amount:[NSDecimalNumber decimalNumberWithString:@"300"]]]
							 shippingContact:shippingContact
					  shippingEditableFields:PKAddressFieldPostalAddress|PKAddressFieldName|PKAddressFieldEmail|PKAddressFieldPhone //PKAddressFieldNone
					   additionalPaymentData:nil
						  fromViewController:self
									 success:^(NSString *paymentId) { NSLog(@"%@", paymentId); }
								   cancelled:^{ NSLog(@"Canceled"); }
									   error:^(ASDKAcquringSdkError *error) {  NSLog(@"%@", error); }];
	}
```
[1] Рекуррентный платеж может производиться для дальнейшего списания средств с сохраненной карты, без ввода ее реквизитов. Эта возможность, например, может использоваться для осуществления платежей по подписке.


### Структура
SDK состоит из следующих модулей:

**ASDKCore**

Является базовым модулем для работы с Tinkoff Acquiring API. Модуль реализует протокол взаимодействия с сервером и позволяет не осуществлять прямых обращений в API, ASDKAcquiringApi.

Основной класс модуля - AcquiringSdk - предоставляет фасад для взаимодействия с Tinkoff Acquiring API. Для работы необходимы ключи и пароль продавца (см. **Подготовка к работе**).

**ASDKUI**

Содержит интерфейс, необходимый для приема платежей через мобильное приложение.

Основной класс - _**ASDKPaymentFormViewController**_ - экран с формой оплаты, который позволяет:

* просматривать информацию о платеже
* вводить или сканировать реквизиты карты для оплаты
* проходить 3DS подтверждение
* управлять списком ранее сохраненных карт

### Sample
Содержит пример интеграции Tinkoff Acquiring SDK в мобильное приложение по продаже книг.
Основные классы и файлы
_**ASDKTestKeys*_ содержит _**Terminal key**_, _**Пароль**_, _**Public key**_
_**PayController**_ фасад для _**ASDKAcquiringSdk**_ который создает экземпляр _**ASDKAcquiringSdk**_ и предоставляет(фасад) функционал для оплаты.

### Поддержка
- Просьба, по возникающим вопросам обращаться на card_acquiring@tinkoff.ru
- Баги и feature-реквесты можно направлять в раздел [issues][issues]
- Докментация на сайте, описание [API методов][server-api]

[acquiring]: https://t.tinkoff.ru/
[applepay]: https://oplata.tinkoff.ru/landing/develop/applepay
[cocoapods]: https://cocoapods.org
[img-pay]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen.png
[server-api]: https://oplata.tinkoff.ru/landing/develop/documentation/termins_and_operations
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
