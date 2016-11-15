//
//  BookItemCell.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "BookItemCell.h"
#import "LocalConstants.h"

NSString *const kDetailsInfoNotification = @"kDetailsInfoNotification";

#define kSeparatorLineHeight		1.0f / [[UIScreen mainScreen] scale]

@interface BookItemCell ()

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *bordersHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buySectionHeight;
@property (weak, nonatomic) IBOutlet UIView *buySection;

@end

@implementation BookItemCell

+ (instancetype)cell
{
    BookItemCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"BookItemCell" owner:self options:nil] objectAtIndex:0];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    self.itemCostLabel.textColor = kMainBlueColor;
    [self.imageItemContainerView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.imageItemContainerView.layer setBorderWidth:kSeparatorLineHeight];
    [self.imageItemContainerView.layer setCornerRadius:3.0f];
	
	[self.itemDetailsButton setTitle:NSLocalizedString(@"Details", @"ПОДРОБНЕЕ") forState:UIControlStateNormal];
    [self.itemDetailsButton.layer setCornerRadius:3.0f];
    
    for (NSLayoutConstraint *heightConstraint in self.bordersHeightConstraint)
    {
        [heightConstraint setConstant:kSeparatorLineHeight];
    }
}

- (void)setShouldHideBuySection:(BOOL)shouldHideBuySection
{
    _shouldHideBuySection = shouldHideBuySection;
    
    self.buySectionHeight.constant = !_shouldHideBuySection ? 64 : 0;
    self.buySection.hidden = _shouldHideBuySection ? YES : NO;
}

- (void)setBookItem:(BookItem *)bookItem
{
    _bookItem = bookItem;
    
    [self configureCellWithBookItem:_bookItem];
}

- (void)configureCellWithBookItem:(BookItem *)item
{
    [self.itemImageView setImage:item.cover];
    [self.itemTitleLabel setText:item.title];
    [self.itemSubtitleLabel setText:item.author];
    [self.itemDescriptionLabel setText:item.bookDescription];
    [self.itemCostLabel setText:[item amountAsString]];
}

- (IBAction)itemDetailsButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDetailsInfoNotification object:nil userInfo:@{@"bookItem" : self.bookItem}];
}

- (CGFloat)cellHeightWithWidth:(CGFloat)width
{
    CGFloat height = 359;
    
    NSString *descriptionString = self.bookItem.bookDescription;
    
    if (descriptionString.length > 0)
    {
        CGRect frame = CGRectMake(0,0,width,3000);
        
        height += [descriptionString boundingRectWithSize:frame.size
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{
                                                            NSFontAttributeName : self.itemDescriptionLabel.font
                                                            }
                                                  context:nil].size.height;
        
        height += 8;
    }
    
    if (self.shouldHideBuySection)
    {
        height -= 64;
    }
    
    return height;
}

@end
