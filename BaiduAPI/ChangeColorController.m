//
//  ChangeColorController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/4.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ChangeColorController.h"
#import "BMapKit.h"

@interface ChangeColorController ()

@property (retain, nonatomic) IBOutlet UIView *colorView;

@end

@implementation ChangeColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, _colorView.frame.size.width, _colorView.frame.size.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor redColor].CGColor,(id)[UIColor yellowColor].CGColor,(id)[UIColor greenColor].CGColor,nil];
    [_colorView.layer insertSublayer:gradient atIndex:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
