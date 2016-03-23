//
//  ShopCart.h
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 12.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kShopCartUpdated;

@interface ShopCart : NSObject

+ (ShopCart *)sharedInstance;

- (void)addItem:(id)item;
- (void)deleteItem:(id)item;

- (NSArray *)allItems;
- (void)deleteAllItems;

@end
