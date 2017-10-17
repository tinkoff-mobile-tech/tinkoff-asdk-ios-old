//
//  ASDKRequestAttachCard.h
//  ASDKCore
//
//  Created by v.budnikov on 12.10.17.
//  Copyright © 2017 Tinkoff Bank. All rights reserved.
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
//

#import "ASDKAcquiringRequest.h"

@interface ASDKRequestAttachCard : ASDKAcquiringRequest

@property (nonatomic, copy) NSString *cardData;
@property (nonatomic, copy) NSString *requestKey;
@property (nonatomic, copy) NSDictionary *additionalData;

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
							  token:(NSString *)token
						   cardData:(NSString *)cardData
						 requestKey:(NSString *)requestKey
					 additionalData:(NSDictionary *)data NS_DESIGNATED_INITIALIZER;

@end
