//
//  ASDKRequestBuilder.m
//  ASDKCore
//
// Copyright (c) 2016 TCS Bank
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

#import "ASDKRequestBuilder.h"
#import "ASDKCryptoUtils.h"

@implementation ASDKRequestBuilder

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
{
	if (self = [super init])
	{
		_terminalKey = terminalKey;
		_password = password;
	}

	return self;
}

- (ASDKAcquiringRequest *)buildError:(ASDKAcquringSdkError **)error
{
    //implement in subclasses
    return nil;
}

- (NSString *)makeToken
{
    NSDictionary *parametersForToken = [self parametersForToken];
    
    NSString *token = [self makeTokenWithParameters:parametersForToken];
    
    return token;
}

- (NSString *)makeTokenWithParameters:(NSDictionary *)parameters
{
    NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableString *tokenString = [NSMutableString string];
    for (NSString *key in keys)
    {
        id parameterValue = parameters[key];
        
        if (![parameterValue isKindOfClass:[NSString class]])
        {
			if ([parameterValue isKindOfClass:[NSDictionary class]] || [parameterValue isKindOfClass:[NSArray class]])
			{
				parameterValue = @"";
				//NSData *data = [NSKeyedArchiver archivedDataWithRootObject:parameterValue];
				//parameterValue = [NSString stringWithFormat:@"%@", data];
			}
			else
			{
				parameterValue = [NSString stringWithFormat:@"%@", parameterValue];
			}
		}

        [tokenString appendString:parameterValue];
    }
    
//    NSLog(@"%@",tokenString);
    
    NSString *encodedTokenString = [ASDKCryptoUtils sha256:tokenString];
    
    return encodedTokenString;
}

- (NSDictionary *)parametersForToken
{
    return nil;
}

- (NSString *)dataStringFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *dataString = @"";
    
    for (NSString *key in dataDictionary.allKeys)
    {
        NSString *singleString = [NSString stringWithFormat:@"%@=%@",key,dataDictionary[key]];
        
        dataString = [NSString stringWithFormat:@"%@%@%@",dataString,dataString.length > 0 ? @"|" : @"", singleString];
    }
    
    return dataString.length > 0 ? dataString : nil;
}

@end
