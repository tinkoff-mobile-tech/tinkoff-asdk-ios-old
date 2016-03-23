//
//  ShopCart.m
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 12.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ShopCart.h"

@interface ShopCart ()

@property (nonatomic, strong) NSMutableArray *items;

@end

NSString * const kShopCartUpdated = @"kShopCartUpdated";

@implementation ShopCart

static ShopCart *__sharedInstance = nil;

+ (ShopCart *)sharedInstance
{
    if (__sharedInstance == nil) {
        __sharedInstance = [[ShopCart alloc] init];
        __sharedInstance.items = [NSMutableArray array];
    }
    return __sharedInstance;
}

- (void)addItem:(id)item
{
    if (item)
    {
        [self.items addObject:item];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShopCartUpdated object:nil];
    }
    
}
- (void)deleteItem:(id)item
{
    if (item)
    {
        [self.items removeObject:item];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShopCartUpdated object:nil];
    }
}

- (void)deleteAllItems
{
    [self.items removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShopCartUpdated object:nil];
}

- (NSArray *)allItems
{
    return self.items;
}

@end
