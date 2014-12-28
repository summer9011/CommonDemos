//
//  CompassView.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/28.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CustomerCompassView.h"
#import <CoreLocation/CoreLocation.h>

#define degreesToRadians(x) (M_PI * x / 180.0)

@interface CustomerCompassView () <CLLocationManagerDelegate> {
    CGRect r;
}

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSMutableDictionary *currentCenter;
@property (nonatomic,strong) NSMutableArray *currentDestinationArr;

@property (nonatomic,strong) UIView *compassBackView;
@property (nonatomic,strong) UIView *compass1;
@property (nonatomic,strong) UIView *compass2;
@property (nonatomic,strong) UIView *compass3;

@end

@implementation CustomerCompassView

-(id)initWithFrame:(CGRect)frame Center:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr {
    self=[super initWithFrame:frame];
    if (self) {
        r=frame;
        
        self.currentCenter=[NSMutableDictionary dictionary];
        self.currentDestinationArr=[NSMutableArray array];
        
        [self setCenter:center DestinationArray:destinationArr];
        
        [self initSelfView];
        [self setCompass];
        
        /*
        self.locationManager=[[CLLocationManager alloc] init];
        self.locationManager.delegate=self;
        
        if ([CLLocationManager headingAvailable]) {
            self.locationManager.headingFilter=kCLHeadingFilterNone;
            [self.locationManager startUpdatingHeading];
        }
         */
    }
    return self;
}

//设置中心点和目的地点
-(void)setCenter:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr {
    [self.currentCenter removeAllObjects];
    [self.currentDestinationArr removeAllObjects];
    
    [self.currentCenter setValuesForKeysWithDictionary:center];
    [self.currentDestinationArr addObjectsFromArray:destinationArr];
}

-(void)initSelfView {
    self.backgroundColor=[UIColor colorWithWhite:0.f alpha:0.3f];
    
    //"北"文字
    UILabel *beiLabel=[[UILabel alloc] initWithFrame:CGRectMake(r.size.width-15, 5, 10, 10)];
    beiLabel.text=@"北";
    beiLabel.textColor=[UIColor colorWithRed:126/255.f green:129/255.f blue:129/255.f alpha:1.f];
    beiLabel.font=[UIFont systemFontOfSize:11];
    [self addSubview:beiLabel];
    
    //"北"箭头
    UIImageView *beiImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bei"]];
    beiImage.frame=CGRectMake(r.size.width-15, 20, 10, 10);
    [self addSubview:beiImage];
    
    //设置指向View
    float x,y,edge;
    
    if (r.size.width>r.size.height) {
        edge=r.size.height;
        y=0.f;
        x=(r.size.width-r.size.height)/2.f;
    }else{
        edge=r.size.width;
        x=0.f;
        y=(r.size.height-r.size.width-64)/2.f;
    }
    
    self.compassBackView=[[UIView alloc] initWithFrame:CGRectMake(x, y, edge, edge)];
    self.compassBackView.backgroundColor=[UIColor brownColor];
    [self addSubview:self.compassBackView];
    
}

//设置指向标
-(void)setCompass {
    CGRect compassViewRect=self.compassBackView.frame;
    
    //设置中心点
    UIView *centerPoint=[[UIView alloc] initWithFrame:CGRectMake(compassViewRect.size.width/2.f-5, compassViewRect.size.height/2.f-5, 10, 10)];
    centerPoint.backgroundColor=[UIColor yellowColor];
    [self.compassBackView addSubview:centerPoint];
    
    //设置指向箭头
    if (!self.compass1) {
        self.compass1=[[UIView alloc] initWithFrame:CGRectMake(compassViewRect.size.width/2.f-45, compassViewRect.size.height/2.f-30, 90, 60)];
        self.compass1.backgroundColor=[UIColor blueColor];
        [self.compassBackView addSubview:self.compass1];
        
        //指向箭头的背景
//        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou"]];
//        jiantou.frame=self.compass1.frame;
//        [self.compass1 addSubview:jiantou];
        
        //指向箭头的状态
        UIView *status=[[UIView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        status.backgroundColor=[UIColor redColor];
        status.tag=101;
        [self.compass1 addSubview:status];

        //设置距离
        UILabel *miles=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 20)];
        miles.backgroundColor=[UIColor redColor];
        miles.tag=102;
        miles.text=@"100m";
        miles.font=[UIFont systemFontOfSize:12];
        [self.compass1 addSubview:miles];
        
        //设置名字
        UILabel *destinationName=[[UILabel alloc] initWithFrame:CGRectMake(10, 35, self.compass1.frame.size.width-20, 20)];
        destinationName.backgroundColor=[UIColor redColor];
        destinationName.tag=103;
        destinationName.text=@"小普陀";
        [self.compass1 addSubview:destinationName];
        
        self.compass1.layer.anchorPoint=CGPointMake(0, 0.5);
        
        self.compass1.transform=CGAffineTransformMakeRotation(-1 * M_PI_2);
        
    }
    
    UILabel *name=(UILabel *)[self.compass1 viewWithTag:103];
    
    for (NSDictionary *destination in self.currentDestinationArr) {
        name.text=destination[@"name"];
        
        double diffLat=[self.currentCenter[@"lat"] doubleValue]-[destination[@"lat"] doubleValue];
        double diffLong=[self.currentCenter[@"long"] doubleValue]-[destination[@"long"] doubleValue];
        
        double degrees=atan(diffLong/diffLat);
        NSLog(@"%f",degrees);
        
        //根据中心点旋转
        
    }
    
}

-(void)show {
    
}

-(void)hidden {
    
}

-(void)reload {
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.compassBackView.transform = CGAffineTransformMakeRotation(-1 * degreesToRadians(newHeading.magneticHeading));
}

@end
