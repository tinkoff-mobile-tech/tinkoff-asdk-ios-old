//
//  TCSP2PBaseObject.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASDKBaseObject : NSObject
{
    @protected
	NSDictionary *_dictionary;
}
@property (nonatomic, strong) NSDictionary * dictionary;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (void)clearAllProperties;
@end
