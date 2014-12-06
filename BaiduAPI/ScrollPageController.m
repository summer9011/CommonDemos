//
//  ScrollPageController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ScrollPageController.h"

#import "CircleScrollView.h"

@interface ScrollPageController () <CircleScrollViewDelegate> {
    BOOL isShow;
}

@property(nonatomic,strong) CircleScrollView *circleScroll;

@end

@implementation ScrollPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isShow=YES;
    
    NSArray *imageArr=@[
                        @"1.0.1",
                        @"1.0.2",
                        @"1.0.3",
                        @"1.0.4",
                        @"2.1.1",
                        @"2.1.2",
                        @"2.1.3",
                        @"2.1.4",
                        @"2.1.5",
                        @"2.1.6",
                        @"2.1.7",
                        @"2.1.8",
                        @"2.1.9",
                        @"2.2.1",
                        @"2.2.2",
                        @"2.2.3",
                        @"2.2.4",
                        @"2.2.5",
                        @"2.2.6"
                        ];
    
    _circleScroll=[[CircleScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds ImageArray:imageArr];
    _circleScroll.currentIndex=4;       //设置当前页
    _circleScroll.circleDelegate=self;
    
    _circleScroll.backgroundColor=[UIColor blackColor];
    
    [self.view addSubview:_circleScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CircleScrollViewDelegate

//单击circleScroll
-(void)didSingleTapOnCircleScroll:(UITapGestureRecognizer *)recognizer {
    NSLog(@"单击");
    
    if (isShow) {
        self.navigationController.navigationBarHidden=YES;
        isShow=NO;
    }else{
        self.navigationController.navigationBarHidden=NO;
        isShow=YES;
    }
}

//双击circleScroll
-(void)didDoubleTapOnCircleScroll:(UITapGestureRecognizer *)recognizer {
    NSLog(@"双击");
}

//完成切换
-(void)didScrollWithCurrentIndex:(int)index {
    self.navigationItem.title=[NSString stringWithFormat:@"%d / %d",index+1,_circleScroll.imageArr.count];
}

@end
