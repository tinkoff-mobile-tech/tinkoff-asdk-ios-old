//
//  BookItem.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "BookItem.h"

@implementation BookItem

- (instancetype)initWithCover:(UIImage *)cover
                        title:(NSString *)title
                       author:(NSString *)author
                         cost:(NSNumber *)cost
              bookDescription:(NSString *)description
{
    self = [super init];
    
    if (self)
    {
        _cover = cover;
        _title = title;
        _author = author;
        _cost = cost;
        _bookDescription = description;
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    BookItem *another = [[BookItem alloc] initWithCover:self.cover
                                                  title:self.title
                                                 author:self.author
                                                   cost:self.cost
                                        bookDescription:self.bookDescription];
    
    return another;
}

- (NSString *)amountAsString
{
    return [[NSString stringWithFormat:@"%.2f ₽",self.cost.doubleValue]  stringByReplacingOccurrencesOfString:@"." withString:@","];
}

@end
