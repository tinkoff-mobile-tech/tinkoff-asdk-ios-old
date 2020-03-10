//
//  ASDK3DSViewController.h
//  ASDKUI
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

#import <UIKit/UIKit.h>
#import <ASDKCore/ASDKAcquiringSdk.h>
#import <ASDKCore/ASDKThreeDsData.h>
#import <ASDKCore/ASDKAcquringSdkError.h>
#import "ASDKBaseViewController.h"

#define kASDKSubmit3DSAuthorization @"Submit3DSAuthorization"
#define kASDKSubmit3DSAuthorizationV2 @"Submit3DSAuthorizationV2"
#define kASDKComplete3DSMethodv2 @"Complete3DSMethodv2"

@interface ASDK3DSViewController : ASDKBaseViewController

- (instancetype)initWithPaymentId:(NSString *)paymentId
                      threeDsData:(ASDKThreeDsData *)data
                     acquiringSdk:(ASDKAcquiringSdk *)acquiringSdk;

- (instancetype)initWithAddCardRequestKey:(NSString *)requestKey
							  threeDsData:(ASDKThreeDsData *)data
							 acquiringSdk:(ASDKAcquiringSdk *)acquiringSdk;

- (void)showFromViewController:(UIViewController *)viewController
                       success:(void (^)(NSString *result))success
                       failure:(void (^)(ASDKAcquringSdkError *statusError))failure
                        cancel:(void (^)(void))cancel;

@end
