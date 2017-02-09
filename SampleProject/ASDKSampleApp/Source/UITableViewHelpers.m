//
//  UITableViewHelpers.m
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import "UITableViewHelpers.h"

@implementation UITableViewHelpers

+ (UITableViewCell *)tableViewCellBySubView:(UIView *)view
{
	if ([view isKindOfClass:[UITableViewCell class]])
	{
		return (UITableViewCell *)view;
	}
	else while ((view = view.superview))
	{
		if ([view isKindOfClass:[UITableViewCell class]])
		{
			return (UITableViewCell *)view;
		}
	}
	
	return nil;
}

+ (void)registerCellNib:(NSString *)nibName forTable:(UITableView *)tableView;
{
	UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
	[tableView registerNib:nib forCellReuseIdentifier:nibName];
}

@end
