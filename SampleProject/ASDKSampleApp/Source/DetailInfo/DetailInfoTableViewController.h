//
//  DetailInfoTableViewController.h
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookItem.h"

@interface DetailInfoTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;

- (instancetype)initWithItem:(BookItem *)item;

@end
