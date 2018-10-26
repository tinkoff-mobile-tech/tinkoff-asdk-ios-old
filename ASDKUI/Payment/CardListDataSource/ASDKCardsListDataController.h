//
//  ASDKCardsListDataController.h
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

#import <Foundation/Foundation.h>
#import <ASDKCore/ASDKCore.h>

@interface ASDKCardsListDataController : NSObject

@property (nonatomic, strong, readonly) NSArray *externalCards;
@property (nonatomic, strong, readonly) NSString *customerKey;

+ (instancetype)instance;
+ (instancetype)cardsListDataControllerWithAcquiringSdk:(ASDKAcquiringSdk *)acquiringSdk
                                            customerKey:(NSString *)customerKey;
+ (void)resetAcquiringSdk;

- (NSNumber *)rebillId;
- (ASDKCard *)cardWithRebillId;
- (ASDKCard *)cardWithIdentifier:(NSString *)indentifier;
- (ASDKCard *)cardByRebillId:(NSNumber *)rebillId;

- (void)updateCardsListWithSuccessBlock:(void (^)(void))onSuccess
                             errorBlock:(void (^)(ASDKAcquringSdkError *error))onError;

- (void)removeCardWithCardId:(NSNumber *)cardId
                successBlock:(void (^)(void))onSuccess
                  errorBlock:(void (^)(ASDKAcquringSdkError *error))onError;



@end
