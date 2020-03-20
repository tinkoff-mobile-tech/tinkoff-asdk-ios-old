//
//  ASDKUtils.m
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

#import "ASDKUtils.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation ASDKUtils

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)colorWithInteger:(NSInteger)rgbValue alpha:(CGFloat)alpha
{
    return [UIColor	colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0f
                           green:((CGFloat)((rgbValue & 0xFF00)	  >> 8))  / 255.0f
                            blue:((CGFloat) (rgbValue & 0xFF))			  / 255.0f
                           alpha:alpha];
}

+ (UIColor *)colorWithInteger:(NSInteger)rgbValue {
    return [self colorWithInteger:rgbValue alpha:1.f];
}

+ (UIColor *)colorWithIntegerShadeOfGrey:(NSInteger)greyHex {
    return [UIColor colorWithWhite:greyHex/255.f alpha:1.f];
}

+ (NSString *)getIPAddress
{
	NSDictionary *dict = [self getIPAddresses];
	
	if ([dict objectForKey:@"en0/ipv4"])
	{
		return [dict objectForKey:@"en0/ipv4"];
	}
	else if ([dict objectForKey:@"en1/ipv4"])
	{
		return [dict objectForKey:@"en1/ipv4"];
	}
	else
	{
		return dict.allValues.firstObject;
	}
	
	return nil;
}

+ (NSDictionary *)getIPAddresses
{
	NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
	struct ifaddrs *interfaces;
	if (!getifaddrs(&interfaces))
	{
		struct ifaddrs *interface;
		for (interface=interfaces; interface; interface=interface->ifa_next)
		{
			if (!(interface->ifa_flags & IFF_UP))
			{
				continue;
			}
			
			const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
			char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
			if (addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6))
			{
				NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
				NSString *type;
				if (addr->sin_family == AF_INET)
				{
					if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN))
					{
						type = IP_ADDR_IPv4;
					}
				}
				else
				{
					const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
					if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN))
					{
						type = IP_ADDR_IPv6;
					}
				}
				
				if (type)
				{
					NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
					addresses[key] = [NSString stringWithUTF8String:addrBuf];
				}
			}
		}
		
		freeifaddrs(interfaces);
	}
	
	return [addresses count] ? addresses : nil;
}

@end
