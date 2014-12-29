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

@interface CompassController () <CompassDelegate>

@property (nonatomic,strong) CustomerCompassView *compass;

@end

@implementation CompassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *center=@{@"lat":@"29.85413151",@"long":@"121.58188563",@"haiba":@"123"};
    
    //121.598702,29.869886
    //121.570028,29.870732
    //121.588641,29.839346
    NSDictionary *destination1=@{@"lat":@"29.869886",@"long":@"121.598702",@"name":@"目的地1",@"haiba":@"90"};
    NSDictionary *destination2=@{@"lat":@"29.870732",@"long":@"121.570028",@"name":@"目的地2",@"haiba":@"125"};
    NSDictionary *destination3=@{@"lat":@"29.839346",@"long":@"121.588641",@"name":@"目的地3",@"haiba":@"400"};
    
    NSArray *destinationArr=@[destination1,destination2,destination3];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame=CGRectMake(0, 64, 60, 30);
    [btn setTitle:@"Click" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(ddd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    CGRect r=[UIScreen mainScreen].bounds;
    self.compass=[[CustomerCompassView alloc] initWithFrame:CGRectMake(0, 94, r.size.width, r.size.height) Center:center DestinationArray:destinationArr];
    self.compass.compassDelegate=self;
    [self.view addSubview:self.compass];
    [self.compass show];
    
}

-(void)ddd {
    NSDictionary *center=@{@"lat":@"29.85413151",@"long":@"121.58188563",@"haiba":@"123"};
    
    //121.562626,29.844045
    //121.574627,29.840473
    NSDictionary *destination1=@{@"lat":@"29.844045",@"long":@"121.562626",@"name":@"哈哈1",@"haiba":@"90"};
    NSDictionary *destination2=@{@"lat":@"29.840473",@"long":@"121.574627",@"name":@"哈哈2",@"haiba":@"80"};
    NSArray *destinationArr=@[destination1,destination2];
    
    [self.compass setCenter:center DestinationArray:destinationArr];
    [self.compass reload];
}

#pragma mark - CompassDelegate

-(void)didClickOnOneCompass:(NSDictionary *)destination {
    NSLog(@"didClickOnOneCompass %@",destination);
}

-(void)didShowCompassView {
    NSLog(@"didShowCompassView");
}

-(void)didHiddenCompassView {
    NSLog(@"didHiddenCompassView");
}

-(void)didReloadCompassView {
    NSLog(@"didReloadCompassView");
}

-(void)didTapOnCompassView {
    NSLog(@"didTapOnCompassView");
}

@end
