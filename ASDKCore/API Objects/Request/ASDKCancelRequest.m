//
//  ASDKCancelRequest.m
//  ASDKCore
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 TCS Bank. All rights reserved.
//

#import "ASDKCancelRequest.h"

@implementation ASDKCancelRequest

- (ASDKCancelRequest *)initWithTerminalKey:(NSString *)terminalKey
								 paymentId:(NSString *)paymentId
									 token:(NSString *)token
{
	ASDKCancelRequest *request = [[ASDKCancelRequest alloc] init];
	
	if (request)
	{
		request.terminalKey = terminalKey;
		request.paymentId = paymentId;
		request.token = token;
	}
	
	return request;
}

@end
