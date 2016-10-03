//
//  BookItemCell.h
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookItem.h"

extern NSString *const kDetailsInfoNotification;

@interface BookItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *itemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemSubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemCostLabel;
@property (nonatomic, weak) IBOutlet UIButton *itemDetailsButton;
@property (weak, nonatomic) IBOutlet UIView *imageItemContainerView;

@property (nonatomic, strong) BookItem *bookItem;

@property (nonatomic, readwrite) BOOL shouldHideBuySection;

+ (instancetype)cell;
- (CGFloat)cellHeightWithWidth:(CGFloat)width;

@end
