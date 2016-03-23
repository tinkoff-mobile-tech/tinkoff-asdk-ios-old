//
//  TestScanClass.h
//  ASDKSampleApp
//
//  Created by Макс Жданов on 07.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASDKUI/ASDKUI.h>

@interface ASDKCardIOScanner : NSObject <ASDKAcquiringSdkCardScanner>

+ (instancetype)scanner;

@end
