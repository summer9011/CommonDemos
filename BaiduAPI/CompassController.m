//
//  CompassController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/24.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CompassController.h"

#import "CompassView.h"

@interface CompassController ()

@end

@implementation CompassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect r=[UIScreen mainScreen].bounds;
    
    NSDictionary *center=@{};
    
    NSArray *destinationArr=@[];
    
    CompassView *compass=[[CompassView alloc] initWithFrame:CGRectMake(0, (r.size.height-r.size.width)/2.f-64, r.size.width, r.size.width) Center:center DestinationArray:destinationArr];
    
    [self.view addSubview:compass];
    
}

@end
