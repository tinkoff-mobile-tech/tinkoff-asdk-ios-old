//
//  ASDKThreeDsData.m
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



#import "ASDKThreeDsData.h"
#import "ASDKApiKeys.h"

@implementation ASDKThreeDsData

- (NSURL *)ACSUrl
{
    if (!_ACSUrl)
    {
        NSString *urlString = _dictionary[kASDKASCUrl];
        _ACSUrl = [NSURL URLWithString:urlString];
    }
    
    return _ACSUrl;
}

- (NSString *)MD
{
    if (!_MD)
    {
        _MD = _dictionary[kASDKMD];
    }
    
    return _MD;
}

- (NSString *)paReq
{
    if (!_paReq)
    {
        _paReq = _dictionary[kASDKPaReq];
    }
    
    return _paReq;
}

- (void)clearAllProperties
{
    _ACSUrl = nil;
    _MD = nil;
    _paReq = nil;
}

@end
