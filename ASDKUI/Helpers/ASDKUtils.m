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
    
    NSArray *priorityPorts = @[@"en0/ipv4", @"en0/ipv6",
                              @"en1/ipv4", @"en1/ipv6",
                              @"en2/ipv4", @"en2/ipv6"];
    
    NSString *ipAddress = nil;
    for (NSString *port in priorityPorts)
    {
        ipAddress = dict[port];
        if (ipAddress) {
            break;
        }
    }
    ipAddress = ipAddress ? ipAddress : dict.allValues.firstObject;
        
    return [self restoreFullIPAddress:ipAddress];
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

            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if ((interface->ifa_flags & (IFF_LOOPBACK | IFF_UP | IFF_RUNNING)) != (IFF_UP | IFF_RUNNING))
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

+ (NSString *)restoreFullIPAddress:(NSString *)ipAddress
{
    NSString *fullAddress = nil;
    if ([self checkIfIPv4Address:ipAddress]) { fullAddress = ipAddress; };
    if ([self checkIfIPv6Address:ipAddress]) { fullAddress = [self restoreFullIPv6Address:ipAddress]; }
    
    return fullAddress;
}

+ (BOOL)checkIfIPv4Address:(NSString *)ipAddress
{
    struct in_addr address;
    int result = inet_pton(AF_INET, [ipAddress UTF8String], &address);
    return result > 0;
}

+ (BOOL)checkIfIPv6Address:(NSString *)ipAddress
{
    struct in6_addr address;
    int result = inet_pton(AF_INET6, [ipAddress UTF8String], &address);
    return result > 0;
}

NSInteger const ipv6FullSegmentsCount = 8;
NSInteger const ipv6OneSegmentElementsCount = 4;

+ (NSString *)restoreFullIPv6Address:(NSString *)ipAddress
{
    NSArray<NSString *> *segments = [ipAddress componentsSeparatedByString:@":"];
    NSMutableArray<NSString *> *fullAddressSegments = [NSMutableArray array];
    
    for (NSString *segment in segments)
    {
        if (![segment length])
        {
            NSInteger numberOfOmmitedSegments = ipv6FullSegmentsCount - [segments count];
            for (NSInteger i=0; i<=numberOfOmmitedSegments; i++)
            {
                [fullAddressSegments addObject:@"0000"];
            }
            continue;
        }
        
        if ([segment length] < ipv6OneSegmentElementsCount)
        {
            NSInteger ommitedZeroesCount = ipv6OneSegmentElementsCount - [segment length];
            NSString *ommitedZeroes = [@"" stringByPaddingToLength:ommitedZeroesCount withString:@"0" startingAtIndex:0];
            NSString *enrichedSegment = [ommitedZeroes stringByAppendingString:segment];
            [fullAddressSegments addObject:enrichedSegment];
        }
        else
        {
            [fullAddressSegments addObject:segment];
        }
    }
    
    return [fullAddressSegments componentsJoinedByString:@":"];
}

@end
