//
//  ASDKAcquringApiError.h
//  ASDKCore
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

#import "ASDKAcquringSdkError.h"
#import "ASDKAcquiringResponse.h"

typedef enum
{
    kASDKApiErrorCodeEmptyCardList = 7
} kASDKApiErrorCode;

@interface ASDKAcquringApiError : ASDKAcquringSdkError

@property (nonatomic, strong) ASDKAcquiringResponse *apiResponse;

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *parameters;

+ (instancetype)errorWithAcquringResponse:(ASDKAcquiringResponse *)response urlString:(NSString *)urlString parameters:(NSDictionary *)parameters code:(NSInteger)code;

@end
