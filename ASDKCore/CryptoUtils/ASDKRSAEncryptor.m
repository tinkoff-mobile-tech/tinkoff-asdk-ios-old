//
//  ASDKRSAEncryptor.m
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

#import "ASDKRSAEncryptor.h"

@implementation ASDKRSAEncryptor
{
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
    
    NSNumber *keyLengthBits;
}

#pragma mark - Init

- (instancetype)initWithPublicKeyPath:(NSString *)keyPath
{
    self = [super init];
    if (self)
    {
        _publicKeyPath = keyPath;
        [self preparePublicKeyDataWithKeyPath:keyPath];
    }
    
    return self;
}

- (instancetype)initWithPublicKeyString:(NSString *)publicKeyString
{
    self = [super init];
    if (self)
    {
        [self preparePublicKeyDataWithKeyString:publicKeyString];
    }
    
    return self;
}

- (void)preparePublicKeyDataWithKeyPath:(NSString *)publicKeyPath
{
    NSData *publicKeyData = [NSData dataWithContentsOfFile:publicKeyPath];
    
    [self preparePublicKeyData:publicKeyData];
}

- (void)preparePublicKeyDataWithKeyString:(NSString *)publicKeyString
{
    NSData *publicKeyData = [publicKeyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self preparePublicKeyData:publicKeyData];
}

- (void)preparePublicKeyData:(NSData *)publicKeyData
{
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, ( __bridge CFDataRef) publicKeyData);
    if (certificate == nil)
    {
        return;
    }
    
    policy = SecPolicyCreateBasicX509();
    OSStatus returnCode = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (returnCode != noErr)
    {
        return;
    }
    
    SecTrustResultType trustResultType;
    returnCode = SecTrustEvaluate(trust, &trustResultType);
    if (returnCode != noErr)
    {
        return;
    }
    
    publicKey = SecTrustCopyPublicKey(trust);
    if (publicKey == nil)
    {
        return;
    }
    
    NSInteger keyLength = SecKeyGetBlockSize(publicKey);
    keyLengthBits = @(keyLength);
    maxPlainLen = keyLength - 12;
}

#pragma mark - Encrypt

- (NSString *)encryptString:(NSString *)string
{
    NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainLen = [inputData length];
    
    if (plainLen > maxPlainLen)
    {
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [inputData getBytes:plain length:plainLen];
    
    size_t cipherLen = [keyLengthBits integerValue];
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain, plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode == noErr)
    {
        result = [NSData dataWithBytes:cipher length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return [result base64EncodedStringWithOptions:0];
}

- (void)dealloc
{
    CFRelease(certificate);
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(publicKey);
}

@end
