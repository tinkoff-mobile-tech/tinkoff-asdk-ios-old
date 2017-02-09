//
//  UITableViewHelpers.h
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewHelpers : NSObject

+ (UITableViewCell *)tableViewCellBySubView:(UIView *)view;
+ (void)registerCellNib:(NSString *)nibName forTable:(UITableView *)tableView;

@end
