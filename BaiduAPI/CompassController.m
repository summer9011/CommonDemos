//
//  CompassController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/24.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CompassController.h"

#import "CustomerCompassView.h"
#import <CoreLocation/CoreLocation.h>

@interface CompassController ()

@end

@implementation CompassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *center=@{@"lat":@"29.85413151",@"long":@"121.58188563"};
    
    //121.561764,29.863873
    //121.582461,29.872642
    //121.598702,29.869886
    NSDictionary *destination1=@{@"lat":@"29.869886",@"long":@"121.598702",@"name":@"小普陀"};
    
    NSArray *destinationArr=@[destination1];
    
    CGRect r=[UIScreen mainScreen].bounds;
    CustomerCompassView *compass=[[CustomerCompassView alloc] initWithFrame:CGRectMake(0, 64, r.size.width, r.size.height) Center:center DestinationArray:destinationArr];
    
    [self.view addSubview:compass];
    
//    CLLocation *location=[[CLLocation alloc] initWithLatitude:29.85413151 longitude:121.58188563];
//    NSLog(@"%f",location.course);
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
