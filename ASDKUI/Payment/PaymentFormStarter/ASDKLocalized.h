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
//#define LOC(key)                                    [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:@"ASDKLocalizable"]

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

@end

NS_ASSUME_NONNULL_END
