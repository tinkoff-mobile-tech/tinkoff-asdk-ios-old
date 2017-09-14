# Tinkoff Acquiring SDK for iOS

![PayFormActivity][img-pay]
![PayFormActivityUserSettings][img-pay2]

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
					   receiptData:@{@"Email":@"a@test.ru", @"Taxation":@"osn",
										@"Items":@[@{@"Name":@"Название товара 1",@"Price":@100,@"Quantity":@1, @"Amount":@100, @"Tax":@"vat10"},
										@{@"Name":@"Название товара 2",@"Price":@100,@"Quantity":@1,@"Amount":@100, @"Tax":@"vat118"}]}
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
								receiptData:@{@"Email":@"a@test.ru", @"Taxation":@"osn",
												@"Items":@[@{@"Name":@"Название товара 1",@"Price":@100,@"Quantity":@1, @"Amount":@100, @"Tax":@"vat10"},
												@{@"Name":@"Название товара 2",@"Price":@100,@"Quantity":@1,@"Amount":@100, @"Tax":@"vat118"}]}
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

**Настройка экрана Оплата**

для настройки элементов экрана оплаты нужно использовать ASDKDesignConfiguration:

* Настройка цветов для кнопок и заголовка в навигационной панели.
* Настройка кнопки оплатить.
* Настройка отображения элементов экрана.
* Установить свои логотипы платежных систем или то, что потребуется.  

Например, можно указать какие элементы показывать на экране и в какой последовательности, для этого нужно сформировать массив из эелементов:
```objective-c
typedef NS_ENUM(NSInteger, PayFormItems)
{
	PayFormItems_ProductTitle, // Заголовок, занвание товара 
	PayFormItems_ProductDescription, // Описание товара
	PayFormItems_Amount, // сумма
	PayFormItems_PyamentCardRequisites,// поле для ввода реквизитов карты
	PayFormItems_Email, // поле для ввода email
	PayFormItems_PayButton, // кнопка оплатить
	PayFormItems_SecureLogos, // логотипы платежных систем
	PayFormItems_Empty20px, // пустое поле цвета фона таблицы высотой в 20 px
	PayFormItems_Empty5px // пустое поле цвета фона таблицы высотой в 5 px
};
// установить элементы экрана оплаты и их последовательность: 
[ASDKDesignConfiguration setPayFormItems:@[@(PayFormItems_ProductTitle),
										   @(PayFormItems_ProductDescription),
										   @(PayFormItems_Amount),
										   @(PayFormItems_PyamentCardRequisites),
										   @(PayFormItems_Email),
										   @(PayFormItems_Empty20px),
										   @(PayFormItems_PayButton),
										   @(PayFormItems_SecureLogos)
										 ]];
// изменить на кнопке оплатить надпись:
[ASDKDesignConfiguration setPayButtonTitle:[NSString stringWithFormat:@"Оплатить %.2f руб", [amount doubleValue]]];
```

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
[img-pay2]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen2.png
[server-api]: https://oplata.tinkoff.ru/landing/develop/documentation/termins_and_operations
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
