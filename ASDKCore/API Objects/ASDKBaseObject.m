//
//  ASDKBaseObject.m
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

#import "ASDKBaseObject.h"

@implementation ASDKBaseObject
@synthesize dictionary = _dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (!dictionary)
    {
        return nil;
    }

	self = [super init];
    
	if (!self)
    {
        return nil;
    }

	_dictionary = dictionary;
    
	return self;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
	[self clearAllProperties];
	_dictionary = dictionary;
}

- (void)clearAllProperties
{
    //implement in subclasses
}

-(BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[self class]])
    {
        return NO;
    }

	ASDKBaseObject *objectAsBaseObject = (ASDKBaseObject *)object;
    
	return [self.dictionary isEqualToDictionary:objectAsBaseObject.dictionary];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ object with data:\n%@", [self class], _dictionary];
}

@end
