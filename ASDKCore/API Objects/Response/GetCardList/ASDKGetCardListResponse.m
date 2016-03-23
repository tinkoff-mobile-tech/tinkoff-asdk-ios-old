//
//  ASDKGetCardListResponse.m
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



#import "ASDKGetCardListResponse.h"
#import "ASDKCard.h"

@implementation ASDKGetCardListResponse

- (NSArray *)cards
{
    if (!_cards)
    {
        NSArray *arrayWithDictionaries = (NSArray *)_dictionary;
        
        NSMutableArray *cards = [NSMutableArray array];
        
        for (NSDictionary *cardDic in arrayWithDictionaries)
        {
            ASDKCard *card = [[ASDKCard alloc] initWithDictionary:cardDic];
            
            [cards addObject:card];
        }
        
        _cards = [NSArray arrayWithArray:cards];
    }
    
    return _cards;
}

- (void)clearAllProperties
{
    _cards = nil;
}

@end
