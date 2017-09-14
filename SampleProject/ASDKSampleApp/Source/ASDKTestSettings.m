//
//  ASDKTestSettings.m
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 12.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ASDKTestSettings.h"
#import "ASDKTestKeys.h"

#define kActiveTerminal @"activeTerminal"
#define kSettingCustomButtonCancel @"SettingCustomButtonCancel"
#define kSettingCustomButtonPay @"SettingCustomButtonPay"
#define kSettingCustomNavBarColor @"SettingCustomNavBarColor"
#define kSettingMakeCharge @"MakeCharge"
#define kSettingMakeNewCard @"MakeNewCard"

@implementation ASDKTestSettings

+ (NSArray *)testTerminals
{
	return @[kASDKTestTerminalKey1, kASDKTestTerminalKey2, kASDKTestTerminalKey3];
}

+ (NSString *)testActiveTerminal
{
	NSString *result = [ASDKTestSettings valueForKey:kActiveTerminal];
	if (result == nil)
	{
		result = kASDKTestTerminalKey1;
	}
	
	return result;
}

+ (void)setActiveTestTerminal:(NSString *)value
{
	[ASDKTestSettings saveValue:value forKey:kActiveTerminal];
}

+ (NSString *)testTerminalPassword
{
	return kASDKTestPassword;
}

+ (NSString *)testPublicKey
{
	return kASDKTestPublicKey;
}

+ (void)setCustomButtonCancel:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kSettingCustomButtonCancel];
}

+ (BOOL)customButtonCancel
{
	return [[ASDKTestSettings valueForKey:kSettingCustomButtonCancel] boolValue];
}

+ (void)setCustomButtonPay:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kSettingCustomButtonPay];
}

+ (BOOL)customButtonPay
{
	return [[ASDKTestSettings valueForKey:kSettingCustomButtonPay] boolValue];
}

+ (void)setCustomNavBarColor:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kSettingCustomNavBarColor];
}

+ (BOOL)customNavBarColor
{
	return [[ASDKTestSettings valueForKey:kSettingCustomNavBarColor] boolValue];
}

+ (void)setMakeCharge:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kSettingMakeCharge];
}

+ (BOOL)makeCharge
{
	return [[ASDKTestSettings valueForKey:kSettingMakeCharge] boolValue];
}

+ (void)setMakeNewCard:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kSettingMakeNewCard];
}

+ (BOOL)makeNewCard
{
	return [[ASDKTestSettings valueForKey:kSettingMakeNewCard] boolValue];
}

+ (void)saveValue:(id)value forKey:(NSString *)key
{
	if (value)
	{
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end
