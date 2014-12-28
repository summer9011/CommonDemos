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

#define Rc 6378137
#define Rj 6356725

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
        
        self.locationManager=[[CLLocationManager alloc] init];
        self.locationManager.delegate=self;
        
        if ([CLLocationManager headingAvailable]) {
            self.locationManager.headingFilter=kCLHeadingFilterNone;
            [self.locationManager startUpdatingHeading];
        }
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
        
        //设置旋转中心点
        self.compass1.layer.anchorPoint=CGPointMake(0, 0.5);
    }
    
    UILabel *name=(UILabel *)[self.compass1 viewWithTag:103];
    
    for (NSDictionary *destination in self.currentDestinationArr) {
        name.text=destination[@"name"];
        
        double degrees=[self angleWithCenter:self.currentCenter Destination:destination];
        double rotation=-1 * M_PI_2+degreesToRadians(degrees);
        
        self.compass1.transform=CGAffineTransformMakeRotation(rotation);
        
        NSLog(@"degrees %f",degrees);
    }
    
}

-(void)show {
    
}

-(void)hidden {
    
}

-(void)reload {
    
}

//计算2个经纬度与真北之间的夹角
-(double)angleWithCenter:(NSDictionary *)center Destination:(NSDictionary *)destination {
    //中心点的数据
    double centerLat=[center[@"lat"] doubleValue];
    double centerLong=[center[@"long"] doubleValue];
    
    double mCenterRadLa=centerLat*M_PI/180.f;
    double mCenterRadLo=centerLong*M_PI/180.f;
    
    double centerEc=Rj+(Rc-Rj)*(90.f-centerLat)/90.f;
    double centerEd=centerEc*cos(mCenterRadLa);
    
    //目标点的数据
    double destinationLat=[destination[@"lat"] doubleValue];
    double destinationLong=[destination[@"long"] doubleValue];
    
    double mDestinationRadLa=destinationLat*M_PI/180.f;
    double mDestinationRadLo=destinationLong*M_PI/180.f;
    
    //计算destination相对于center的夹角
    double dx=(mDestinationRadLo-mCenterRadLo)*centerEd;
    double dy=(mDestinationRadLa-mCenterRadLa)*centerEc;
    
    double angle=0.f;
    
    angle=atan(fabs(dx/dy))*180.f/M_PI;
    
    double dLo=destinationLong-centerLong;
    double dLa=destinationLat-centerLat;
    
    //计算象限
    if (dLo>0&&dLa<=0) {
        angle=(90.f-angle)+90;
    }else if (dLo<=0&&dLa<0){
        angle=angle+180;
    }else if (dLo<0&&dLa>=0){
        angle=(90.f-angle)+270;
    }
    
    return angle;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.compassBackView.transform = CGAffineTransformMakeRotation(-1 * degreesToRadians(newHeading.magneticHeading));
}

@end
