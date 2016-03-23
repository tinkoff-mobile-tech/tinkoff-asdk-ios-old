//
//  ShopCartTableViewController.h
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopCartTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;

@end
