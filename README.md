# Tinkoff Acquiring SDK for iOS

![PayFormActivity1][img-pay]
![PayFormActivity2][img-pay2]
![PayFormActivity3][img-pay3]
![AttachCardActivity][img-attachCard]

Acquiring SDK позволяет интегрировать [Интернет-Эквайрингу][acquiring] в мобильные приложения для платформы iOS.

Возможности SDK:
* Прием платежей (в том числе рекуррентных)
* Сохранение банковских карт клиента
* Сканирование и распознавание карт с помощью камеры
* Получение информации о клиенте и сохраненных картах
* Управление сохраненными картами
* Поддержка английского и своя локализация
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
Привязать новую карту для оплаты

```objective-c
		[PayController attachCard:self.addNewCardCheckType // тип проверки ASDKCardCheckType
					additionalData:@{@"Email":@"a@test.ru"}
				fromViewController:self
							success:^(ASDKResponseAddCardInit *response) {
								//
						} cancelled:^{
								//
							} error:^(ASDKAcquringSdkError *error) {
								//
		}];
```


[1] Рекуррентный платеж может производиться для дальнейшего списания средств с сохраненной карты, без ввода ее реквизитов. Эта возможность, например, может использоваться для осуществления платежей по подписке.

Указать свой фал локализации

```objective-c
ASDKLocalized *loc = [ASDKLocalized sharedInstance];
[loc setLocalizedBundle:[NSBundle mainBundle]];
[loc setLocalizedTable:@"ASDKlocalizableRu"];
```

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
* Показывать экраны SDK в режиме FormSheet для экранов iPad

Например, можно указать какие элементы показывать на экране и в какой последовательности, для этого нужно сформировать массив из эелементов:
```objective-c
typedef NS_ENUM(NSInteger, TableViewCellType)
{
	CellProductTitle, // Заголовок, занвание товара
	CellProductDescription, // Описание товара
	CellAmount, // сумма
	CellPyamentCardRequisites,// поле для ввода реквизитов карты
	CellEmail, // поле для ввода email
	CellPayButton, // кнопка оплатить
	CellAttachButton, // кнопка привязать карту
	CellSecureLogos, // логотипы платежных систем
	CellEmpty20px, // пустое поле цвета фона таблицы высотой в 20 px
	CellEmpty5px, // пустое поле цвета фона таблицы высотой в 5 px
	CellEmptyFlexibleSpace // пустая строка высота которой занимает всё доступное пространство
};
// установить элементы экрана оплаты и их последовательность: 
[ASDKDesignConfiguration setPayFormItems:@[@(CellProductTitle),
										   @(CellProductDescription),
										   @(CellAmount),
										   @(CellPyamentCardRequisites),
										   @(CellEmail),
										   @(CellEmpty20px),
										   @(CellPayButton),
										   @(CellSecureLogos)
										 ]];
// изменить на кнопке оплатить надпись:
[ASDKDesignConfiguration setPayButtonTitle:[NSString stringWithFormat:@"Оплатить %.2f руб", [amount doubleValue]]];

// показывать окно модально для iPad
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
{
	[designConfiguration setModalPresentationStyle:UIModalPresentationFormSheet];
}
```

### Sample
Содержит пример интеграции Tinkoff Acquiring SDK в мобильное приложение по продаже книг.
Основные классы и файлы
_**ASDKTestKeys*_ содержит _**Terminal key**_, _**Пароль**_, _**Public key**_
_**PayController**_ фасад для _**ASDKAcquiringSdk**_ который создает экземпляр _**ASDKAcquiringSdk**_ и предоставляет(фасад) функционал для оплаты.

### Поддержка
- Просьба, по возникающим вопросам обращаться на oplata@tinkoff.ru
- Баги и feature-реквесты можно направлять в раздел [issues][issues]
- Документация на сайте, описание [API методов][server-api]

[acquiring]: https://oplata.tinkoff.ru
[applepay]: https://developer.apple.com/documentation/passkit/apple_pay
[cocoapods]: https://cocoapods.org
[img-pay]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen.png
[img-pay2]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen2.png
[img-pay3]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/payscreen3.png
[img-attachCard]: https://raw.githubusercontent.com/TinkoffCreditSystems/tinkoff-asdk-ios/master/attachCardScreen.png
[server-api]: https://oplata.tinkoff.ru/develop/api/payments/
[issues]: https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios/issues
