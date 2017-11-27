//
//  ASDKUtilsAmount.m
//  ASDKCore
//
//  Copyright © 2017 Tinkoff Bank. All rights reserved.
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
//

#import "ASDKUtilsAmount.h"

NSString *const kSumDecimalSeparator = @",";

@implementation ASDKUtilsAmount

+ (NSNumberFormatter *)sumNumberFormatter
{
	static NSNumberFormatter *sumNumberFormatter = nil;
	
	if (sumNumberFormatter == nil)
	{
		sumNumberFormatter = [[NSNumberFormatter alloc] init];
		[sumNumberFormatter setGroupingSize:0];
		[sumNumberFormatter setDecimalSeparator:kSumDecimalSeparator];
		[sumNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[sumNumberFormatter setMaximumFractionDigits:2];
		[sumNumberFormatter setMinimumFractionDigits:2];
	}
	
	return sumNumberFormatter;
}

+ (NSString *)amountWholeDigits:(double)amount
{
	NSString *string = [[self sumNumberFormatter] stringFromNumber:[NSNumber numberWithDouble:amount]];
	NSArray *array = [string componentsSeparatedByString:kSumDecimalSeparator];
	
	if ([array count] == 2)
	{
		return [array objectAtIndex:0];
	}
	
	return string;
}

@end
