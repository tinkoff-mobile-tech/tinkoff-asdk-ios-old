//
//  ASDKTestSettings.h
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 12.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASDKTestSettings : NSObject

+ (NSArray *)testTerminals;
+ (NSString *)testActiveTerminal;
+ (void)setActiveTestTerminal:(NSString *)value;
+ (NSString *)testTerminalPassword;
+ (NSString *)testPublicKey;

+ (BOOL)useSystemKeyboard;
+ (void)setUseSystemKeyboard:(BOOL)value;

@end
