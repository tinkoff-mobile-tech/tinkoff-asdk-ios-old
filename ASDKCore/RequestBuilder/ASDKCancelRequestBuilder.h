//
//  ASDKCancelRequestBuilder.h
//  ASDKCore
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 TCS Bank. All rights reserved.
//

#import "ASDKRequestBuilder.h"
#import "ASDKCancelRequest.h"

@interface ASDKCancelRequestBuilder : ASDKRequestBuilder

+ (ASDKCancelRequestBuilder *)builderWithPaymentId:(NSString *)paymentId
									   terminalKey:(NSString *)terminalKey
										  password:(NSString *)password;

@end
