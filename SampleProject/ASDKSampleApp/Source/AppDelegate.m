//
//  AppDelegate.m
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 05.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ItemsListTableViewController.h"
#import "LocalConstants.h"
#import "TransactionHistoryModelController.h"
#import "PayController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"books" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *items = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] objectForKey:@"items"];
    NSMutableArray *books = @[].mutableCopy;
    
    for (NSDictionary *item in items)
    {
        BookItem *bookItem = [[BookItem alloc] initWithCover:[UIImage imageNamed:item[@"cover"]]
                                                       title:item[@"title"]
                                                      author:item[@"author"]
                                                        cost:@([item[@"cost"] doubleValue])
                                             bookDescription:item[@"description"]];
        [books addObject:bookItem];
    }

    ItemsListTableViewController *rootViewController = [[ItemsListTableViewController alloc] initWithItems:books];
	//TransactionsTableViewController *rootViewController = [[TransactionsTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
	
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:kMainBlueColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
