//
//  ShopCartCell.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ShopCartCell.h"
#import "ShopCart.h"
#import "LocalConstants.h"

@implementation ShopCartCell

- (void)awakeFromNib
{
	[super awakeFromNib];
    // Initialization code
    self.itemCostLabel.textColor = kMainBlueColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
	[self.deleteButton setTitle:NSLocalizedString(@"Delete", @"УДАЛИТЬ") forState:UIControlStateNormal];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    [self.itemImageView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.itemImageView.layer setBorderWidth:0.3f];
    [self.itemImageView.layer setCornerRadius:3.0f];
    
    [self.deleteButton.layer setCornerRadius:3.0f];
}

- (void)setBookItem:(BookItem *)bookItem
{
    _bookItem = bookItem;
    
    [self configureCellWithBookItem:_bookItem];
}

- (void)configureCellWithBookItem:(BookItem *)bookItem
{
    [self.itemImageView setImage:bookItem.cover];
    [self.itemTitleLabel setText:bookItem.author];
    [self.itemCostLabel setText:[bookItem amountAsString]];
}

- (IBAction)deleteAction:(id)sender
{
    [[ShopCart sharedInstance] deleteItem:self.bookItem];
}

@end
