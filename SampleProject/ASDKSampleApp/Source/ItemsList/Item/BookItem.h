//
//  BookItem.h
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookItem : NSObject

@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSNumber *cost;
@property (nonatomic, strong) NSString *bookDescription;

- (instancetype)initWithCover:(UIImage *)cover
                        title:(NSString *)title
                       author:(NSString *)author
                         cost:(NSNumber *)cost
              bookDescription:(NSString *)description;

- (NSString *)amountAsString;

@end
