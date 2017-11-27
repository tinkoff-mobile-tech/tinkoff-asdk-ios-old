//
//  ASDKRequestSubmitRandomAmount.m
//  ASDKCore
//
//  Created by v.budnikov on 16.10.17.
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

#import "ASDKRequestSubmitRandomAmount.h"
#import "ASDKUtilsAmount.h"

@implementation ASDKRequestSubmitRandomAmount

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
							  token:(NSString *)token
						 requestKey:(NSString *)requestKey
							 amount:(NSNumber *)amount
{
	if (self = [super initWithTerminalKey:terminalKey token:token])
	{
		_requestKey = requestKey;
		_amount = [ASDKUtilsAmount amountWholeDigits:amount.doubleValue];
	}
	
	return self;
}

@end
