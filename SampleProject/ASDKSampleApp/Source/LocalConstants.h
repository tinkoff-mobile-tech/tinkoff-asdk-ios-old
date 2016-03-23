//
//  LocalConstants.h
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 15.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#ifndef LocalConstants_h
#define LocalConstants_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kMainBlueColor UIColorFromRGB(0x009ecf)

#endif /* LocalConstants_h */
