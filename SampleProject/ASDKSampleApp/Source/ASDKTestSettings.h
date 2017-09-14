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

+ (void)setCustomButtonCancel:(BOOL)value;
+ (BOOL)customButtonCancel;

+ (void)setCustomButtonPay:(BOOL)value;
+ (BOOL)customButtonPay;

+ (void)setCustomNavBarColor:(BOOL)value;
+ (BOOL)customNavBarColor;

+ (void)setMakeCharge:(BOOL)value;
+ (BOOL)makeCharge;

+ (void)setMakeNewCard:(BOOL)value;
+ (BOOL)makeNewCard;

@end
