//
//  PublishController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/25.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "PublishController.h"

@interface PublishController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation PublishController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
    
    _imgView.image=_image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doPublish:(id)sender {
    NSLog(@"发布");
    
    NSArray *VCArr=[self.navigationController viewControllers];
    [self.navigationController popToViewController:VCArr[1] animated:YES];
}

- (IBAction)doGoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
