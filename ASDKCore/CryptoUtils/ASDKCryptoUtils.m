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
    NSData *inputData = [input dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    
    CC_SHA256(inputData.bytes, (UInt32)inputData.length, digest);
    
    NSMutableString *outString = [[NSMutableString alloc] init];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [outString appendFormat:@"%02x", digest[i]];
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
