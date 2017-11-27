//
//  ASDKAttachCardViewController.h
//  ASDKUI
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

#import "ASDKBaseTableViewController.h"
#import <ASDKCore/ASDKCore.h>
#import "ASDKBaseTableViewController.h"

@class ASDKResponseAttachCard;
@class ASDKAcquringApiError;

@interface ASDKAttachCardViewController : ASDKBaseTableViewController

@property (nonatomic, strong) ASDKAcquiringSdk *acquiringSdk;

- (instancetype)initWithCardCheckType:(NSString *)cardCheckType
							formTitle:(NSString *)title
						   formHeader:(NSString *)header
						  description:(NSString *)description
								email:(NSString *)email
						  customerKey:(NSString *)customerKey
					   additionalData:(NSDictionary *)data
							  success:(void (^)(ASDKResponseAttachCard *paymentInfo))success
							cancelled:(void (^)(void))cancelled
								error:(void (^)(ASDKAcquringSdkError *error))error;

@end
