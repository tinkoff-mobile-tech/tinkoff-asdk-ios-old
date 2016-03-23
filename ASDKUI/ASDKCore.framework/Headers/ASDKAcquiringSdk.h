//
//  ASDKAcquiringSdk.h
//  ASDKCore
//
//  Created by spb-EOrlova on 02.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASDKAcquringApiError.h"

#import "ASDKInitResponse.h"
#import "ASDKFinishAuthorizeResponse.h"
#import "ASDKChargeResponse.h"
#import "ASDKGetStateResponse.h"

@protocol ASDKAcquiringSdkLoggerDelegate <NSObject>

- (void)print:(NSString *)logString;

@end

@interface ASDKAcquiringSdk : NSObject

@property (nonatomic, readwrite) BOOL debug;

@property (nonatomic, strong) NSString *terminalKey;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *publicKey;

@property (nonatomic, weak) id<ASDKAcquiringSdkLoggerDelegate>logger;

+ (ASDKAcquiringSdk *)initWithTerminalKey:(NSString *)terminalKey
                                 password:(NSString *)password
                                publicKey:(NSString *)publicKey;

+ (ASDKAcquiringSdk *)instance;

+ (void)initWithAmount:(NSNumber *)amount
               orderId:(NSString *)orderId
           description:(NSString *)description
               payForm:(NSString *)payForm
           customerKey:(NSString *)customerKey
             recurrent:(BOOL)recurrent
                  data:(NSDictionary *)data
               success:(void (^)(ASDKInitResponse *initResponse))success
               failure:(void (^)(ASDKAcquringApiError *error))failure;

+ (void)finishAuthorizeWithPaymentId:(NSNumber *)paymentId
                           sendEmail:(BOOL)sendEmail
                            cardData:(NSString *)cardData
                                data:(NSDictionary *)data
                             success:(void (^)(ASDKFinishAuthorizeResponse *finishAuthorizeResponse))success
                             failure:(void (^)(ASDKAcquringApiError *error))falure;

+ (void)chargeWithPaymentId:(NSNumber *)paymentId
                   rebillId:(NSNumber *)rebillId
                    success:(void (^)(ASDKChargeResponse *chargeResponse))success
                    failure:(void (^)(ASDKAcquringApiError *error))falure;

+ (void)getStateWithPaymentId:(NSNumber *)paymentId
                      success:(void (^)(ASDKGetStateResponse *chargeResponse))success
                      failure:(void (^)(ASDKAcquringApiError *error))falure;


@end
