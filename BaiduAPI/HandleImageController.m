//
//  HandleImageController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/19.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "HandleImageController.h"
#import "ShowImageController.h"

@interface HandleImageController ()

@end

@implementation HandleImageController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//获取图片
- (IBAction)getImage:(id)sender {
    ShowImageController *show=[[ShowImageController alloc] initWithNibName:@"ShowImageController" bundle:nil];
    [self.navigationController pushViewController:show animated:YES];
}


@end
