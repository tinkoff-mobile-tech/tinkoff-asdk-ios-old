//
//  ASDKCancelRequest.h
//  ASDKCore
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 TCS Bank. All rights reserved.
//

#import "ASDKAcquiringRequest.h"

@interface ASDKCancelRequest : ASDKAcquiringRequest

@property (nonatomic, strong) NSString *paymentId;

- (ASDKCancelRequest *)initWithTerminalKey:(NSString *)terminalKey
								 paymentId:(NSString *)paymentId
									 token:(NSString *)token;
@end
