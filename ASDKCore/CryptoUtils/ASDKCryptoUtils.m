//
//  ASDKCryptoUtils.m
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

#import "ASDKCryptoUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ASDKRSAEncryptor.h"

@implementation ASDKCryptoUtils

+ (NSString *)encodeBase64:(NSData *)input
{
    return [input base64EncodedStringWithOptions:0];
}

+ (NSString *)sha256:(NSString *)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *outString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [outString appendFormat:@"%02x",result[i]];
    }
    return outString;
}

+ (NSString *)encryptRSA:(NSString *)input publicKeyPath:(NSString *)keyPath
{
    ASDKRSAEncryptor *rsaEncryptor = [[ASDKRSAEncryptor alloc] initWithPublicKeyPath:keyPath];
    NSString *encryptedString = [rsaEncryptor encryptString:input];
    
    return encryptedString;
}

+ (NSString *)encryptRSA:(NSString *)input publicKeyString:(NSString *)keyString
{
    ASDKRSAEncryptor *rsaEncryptor = [[ASDKRSAEncryptor alloc] initWithPublicKeyString:keyString];
    NSString *encryptedString = [rsaEncryptor encryptString:input];
    
    return encryptedString;
}

@end
