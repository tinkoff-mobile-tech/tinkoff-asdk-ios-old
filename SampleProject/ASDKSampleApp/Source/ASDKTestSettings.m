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
#define kUseSystemKeyboard @"useSystemKeyboard"

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

+ (BOOL)useSystemKeyboard
{
	BOOL result = NO;
 
	if ([ASDKTestSettings valueForKey:kUseSystemKeyboard])
	{
		result = [[ASDKTestSettings valueForKey:kUseSystemKeyboard] boolValue];
	}
	else
	{
		[ASDKTestSettings saveValue:@(NO) forKey:kUseSystemKeyboard];
	}

	return result;
}

+ (void)setUseSystemKeyboard:(BOOL)value
{
	[ASDKTestSettings saveValue:@(value) forKey:kUseSystemKeyboard];
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
