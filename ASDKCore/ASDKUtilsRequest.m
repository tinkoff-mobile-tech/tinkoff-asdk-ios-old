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
//

#import "ASDKUtilsRequest.h"
#import <UIKit/UIKit.h>

@implementation ASDKUtilsRequest

+ (NSDictionary *)defaultHTTPHeaders
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	[result setValue:@"application/json; charset=utf-8;" forKey:@"Content-Type"];
	[result setValue:@"text/html,application/xhtml+xml;q=0.9,*/*;q=0.8" forKey:@"Accept"];
	[result setValue:@"gzip,deflate" forKey:@"Accept-Encoding"];
	
	[result setValue:[NSString stringWithFormat:@"%@/%@(%@)/TinkoffAcquiringSDK/%@(%@)",
					   [[UIDevice currentDevice] localizedModel],
					   [[UIDevice currentDevice] systemName],
					   [[UIDevice currentDevice] systemVersion],
					   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
					   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] forKey:@"User-Agent"];
	
	return result;
}

@end
