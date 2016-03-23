/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import <Foundation/Foundation.h>

@interface RSA : NSObject

//// return base64 encoded string
//+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
//// return raw data
//+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
//// publicKey in .pem format
//+ (NSString *)encryptString:(NSString *)str publicKeyPath:(NSString *)pubKeyPath;

+ (NSString *)encryptString:(NSString *)str publicKeyRef:(SecKeyRef)pubKeyRef;

@end
