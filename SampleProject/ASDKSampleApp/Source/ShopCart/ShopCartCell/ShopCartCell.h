//
//  ShopCartCell.h
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookItem.h"

@interface ShopCartCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *itemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemCostLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

@property (nonatomic, strong) BookItem *bookItem;

@end
