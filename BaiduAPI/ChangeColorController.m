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

- (IBAction)doRonate:(id)sender {
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(150, 110, 30, 100)];
    view.backgroundColor=[UIColor redColor];
    [self.view addSubview:view];
    
    view.layer.anchorPoint=CGPointMake(0.5, 1);
    
    [UIView animateWithDuration:1 animations:^{
        view.transform=CGAffineTransformMakeRotation(-1 * M_PI_2);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}


@end
