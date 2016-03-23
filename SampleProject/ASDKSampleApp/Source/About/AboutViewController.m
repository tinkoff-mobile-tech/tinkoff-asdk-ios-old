//
//  AboutViewController.m
//  ASDKSampleApp
//
//  Created by e.orlova on 15.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "AboutViewController.h"
#import <ASDKUI/ASDKUI.h>

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Интернет магазин"];
    
    [self.versionLabel setText:[self sdkVersionString]];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Отмена"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(closeSelf)];
    
    [self.navigationItem setRightBarButtonItem:cancelButton];
}

- (void)closeSelf
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)sdkVersionString
{
    NSString *projectVersion = [NSString stringWithFormat:@"%s",ASDKUIVersionString];
    projectVersion = [projectVersion substringFromIndex:[projectVersion rangeOfString:@"ASDKUI-"].location+7];
    
    return [NSString stringWithFormat:@"Tinkoff Acquiring SDK v%@", projectVersion];
}


@end
