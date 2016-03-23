/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import "RSA.h"
#import <Security/Security.h>

@implementation RSA

static NSString *base64_encode_data(NSData *data){
	data = [data base64EncodedDataWithOptions:0];
	NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return ret;
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef{
	const uint8_t *srcbuf = (const uint8_t *)[data bytes];
	size_t srclen = (size_t)data.length;
	
	size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
	void *outbuf = malloc(block_size);
	size_t src_block_size = block_size - 11;
	
	NSMutableData *ret = [[NSMutableData alloc] init];
	for(int idx=0; idx<srclen; idx+=src_block_size){
		//NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
		size_t data_len = srclen - idx;
		if(data_len > src_block_size){
			data_len = src_block_size;
		}
		
		size_t outlen = block_size;
		OSStatus status = noErr;
		status = SecKeyEncrypt(keyRef,
							   kSecPaddingPKCS1,
							   srcbuf + idx,
							   data_len,
							   outbuf,
							   &outlen
							   );
		if (status != 0) {
			NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
			ret = nil;
			break;
		}else{
			[ret appendBytes:outbuf length:outlen];
		}
	}
	
	free(outbuf);
	CFRelease(keyRef);
	return ret;
}
//
//+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
//	NSData *data = [RSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
//	NSString *ret = base64_encode_data(data);
//	return ret;
//}
//
//+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
//	if(!data || !pubKey){
//		return nil;
//	}
//	SecKeyRef keyRef = [RSA addPublicKey:pubKey];
//	if(!keyRef){
//		return nil;
//	}
//	return [RSA encryptData:data withKeyRef:keyRef];
//}
//
//+ (NSString *)encryptString:(NSString *)str publicKeyPath:(NSString *)pubKeyPath
//{
//    NSData *keyData = [NSData dataWithContentsOfFile:pubKeyPath];
//    NSString *keyString = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",keyString);
//    
//    return [RSA encryptString:str publicKey:keyString];
//}

+ (NSString *)encryptString:(NSString *)str publicKeyRef:(SecKeyRef)pubKeyRef
{
    if(!pubKeyRef || !str){
        return nil;
    }
    
    NSData *data = [RSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] withKeyRef:pubKeyRef];
    
    NSString *ret = base64_encode_data(data);
    return ret;

}

@end
