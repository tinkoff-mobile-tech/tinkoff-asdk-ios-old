//
//  ASDKLocalized.h
//  ASDKUI
//
//  Created by v.budnikov on 19.11.2018.
//  Copyright © 2018 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LOC(key) [[ASDKLocalized sharedInstance] localizedStringForKey:(key)]

#define SMSLocaleIdentifierRU @"ru_ru"
#define SMSLocaleIdentifierEN @"en_en"

@interface ASDKLocalized : NSObject

+ (instancetype)sharedInstance;

/*!
 *  @discussion Локализация для строк
 *
 *  @param key - ключ строки локализации
 *  @param bundle - где расположен файл со строками логаказации
 *  @param table - название файла строк локализации
 */
- (NSString *)localizedStringForKey:(NSString *)key bundle:(NSBundle *)bundle localizedTable:(NSString *)table;
- (NSString *)localizedStringForKey:(NSString *)key bundle:(NSBundle *)bundle;
- (NSString *)localizedStringForKey:(NSString *)key;

/*!
 *  @discussion Принудительно устанавливает локаль для локализации, незасисимо от локали устрйоства
 *
 *  @param language - принудительная локаль, например "ru","en"
 */
- (void)forceSetLanguage:(NSString *)language;

/*!
 *  @discussion установить название файла локализации который будет использоваться по умолчанию
 *
 *  @param table - название файла строк локализации
 */
- (void)setLocalizedTable:(NSString *)table;

/*!
 *  @discussion установить bundle где расположен файл локализации который будет использоваться по умолчанию
 *
 *  @param bundle - расположение файла локализации
 */
- (void)setLocalizedBundle:(NSBundle *)bundle;

/*!
 *  @discussion локализация для смс
 *
 *  @param localeIdentifier - значения в формате "ru_ru" для смс на русском или "en_en" для смс на английском
 * 	по умолчанию инициализируется как [[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] lowercaseString];
 */
- (void)setSMSLocaleIdentifier:(NSString *)localeIdentifier;
- (NSString *)localeIdentifier;

@end

NS_ASSUME_NONNULL_END
