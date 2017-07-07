//
//  ViewController.m
//  KLIANSLiveDemo
//
//  Created by KLIANS on 16/12/5.
//  Copyright © 2016年 KLIAN. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()<customPreviewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.customPreview.cusDelegate = self;
    [self.view addSubview:appdelegate.customPreview];
    
}

#pragma mark - customPreviewDelegate代理方法 -
-(void)closeLive{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark --------
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


#pragma mark - 懒加载 -


@end
