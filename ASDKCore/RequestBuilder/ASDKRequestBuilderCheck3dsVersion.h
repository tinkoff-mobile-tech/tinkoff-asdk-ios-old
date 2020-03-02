//
//  ASDKRequestBuilderCheck3dsVersion.h
//  ASDKCore
//
//  Created by v.budnikov on 17.02.2020.
//  Copyright © 2020 TCS Bank. All rights reserved.
//

#import "ASDKRequestBuilder.h"
#import "ASDKRequestCheck3dsVersion.h"

@interface ASDKRequestBuilderCheck3dsVersion : ASDKRequestBuilder

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						  paymentId:(NSString *)paymentId
						   cardData:(NSString *)cardData NS_DESIGNATED_INITIALIZER;

@end
