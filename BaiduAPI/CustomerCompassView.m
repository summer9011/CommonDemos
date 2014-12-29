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

@property (nonatomic,strong) UIView *beiView;

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
    self.alpha=0.f;
    self.backgroundColor=[UIColor clearColor];
    
    self.beiView=[[UIView alloc] initWithFrame:CGRectMake(r.size.width-75, 15, 60, 60)];
    [self addSubview:self.beiView];
    
    CGRect beiRect=self.beiView.frame;
    
    //"北"文字
    UILabel *beiLabel=[[UILabel alloc] initWithFrame:CGRectMake(beiRect.size.width/2.f-8, 5, 20, 20)];
    beiLabel.text=@"北";
    beiLabel.textColor=[UIColor colorWithRed:126/255.f green:129/255.f blue:129/255.f alpha:1.f];
    beiLabel.font=[UIFont systemFontOfSize:16];
    [self.beiView addSubview:beiLabel];
    
    //"北"箭头
    UIImageView *beiImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bei"]];
    beiImage.frame=CGRectMake(beiRect.size.width/2.f-10, 27, 20, 28);
    [self.beiView addSubview:beiImage];
    
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
    [self addSubview:self.compassBackView];
    
    //设置中心点
    CGRect compassViewRect=self.compassBackView.frame;
    UIImageView *centerPoint=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhongxin"]];
    centerPoint.frame=CGRectMake(compassViewRect.size.width/2.f-10, compassViewRect.size.height/2.f-10, 20, 20);
    [self.compassBackView addSubview:centerPoint];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap:)];
    [self.compassBackView addGestureRecognizer:singleTap];
    
}

-(void)doSingleTap:(UITapGestureRecognizer *)recognizer {
    if ([self.compassDelegate respondsToSelector:@selector(didTapOnCompassView)]) {
        [self.compassDelegate didTapOnCompassView];
    }
}

//设置指向标
-(void)setCompass {
    int i=1;
    for (NSDictionary *destination in self.currentDestinationArr) {
        switch (i) {
            case 1:
                [self initCompass:self.compass1 DestinationInfo:destination tagStart:100];
                break;
            case 2:
                [self initCompass:self.compass2 DestinationInfo:destination tagStart:200];
                break;
            case 3:
                [self initCompass:self.compass3 DestinationInfo:destination tagStart:300];
                break;
        }
        i++;
    }
    
}

//初始化指向标
-(void)initCompass:(UIView *)view DestinationInfo:(NSDictionary *)info tagStart:(int)tagStart {
    CGRect compassViewRect=self.compassBackView.frame;
    float offset=30;
    
    //设置指向箭头
    if (!view) {
        
        view=[[UIView alloc] initWithFrame:CGRectMake((compassViewRect.size.width-90-offset)/2.f, compassViewRect.size.height/2.f-28.5, 90+offset, 57)];
        view.tag=tagStart;
        
        //指向箭头的背景
        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou"]];
        jiantou.frame=CGRectMake(offset, 0, 90, view.frame.size.height);
        [view addSubview:jiantou];
        
        //指向箭头的状态
        UIImageView *status=[[UIImageView alloc] initWithFrame:CGRectMake(6+offset, 13, 20, 12)];
        status.tag=tagStart+1;
        [view addSubview:status];
        
        //设置距离
        UILabel *miles=[[UILabel alloc] initWithFrame:CGRectMake(28+offset, 13, 60, 15)];
        miles.textColor=[UIColor colorWithRed:73/255.f green:76/255.f blue:77/255.f alpha:1.f];
        miles.tag=tagStart+2;
        miles.font=[UIFont systemFontOfSize:13];
        [view addSubview:miles];
        
        //设置名字
        UILabel *destinationName=[[UILabel alloc] initWithFrame:CGRectMake(8+offset, 26, view.frame.size.width-20, 20)];
        destinationName.textColor=[UIColor colorWithRed:28/255.f green:166/255.f blue:253/255.f alpha:1.f];
        destinationName.tag=tagStart+3;
        [view addSubview:destinationName];
        
        //点击事件
        UIButton *button=[UIButton buttonWithType:UIButtonTypeSystem];
        button.tag=tagStart+4;
        button.frame=CGRectMake(offset, 0, 90, view.frame.size.height);
        [button addTarget:self action:@selector(doClickOnCompass:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=[UIColor clearColor];
        [view addSubview:button];
    }
    
    view.frame=CGRectMake((compassViewRect.size.width-90-offset)/2.f, compassViewRect.size.height/2.f-28.5, 90+offset, 57);
    //设置旋转中心点
    view.layer.anchorPoint=CGPointMake(0, 0.5);
    
    view.hidden=NO;
    
    [self.compassBackView addSubview:view];
    
    //上下坡状态
    UIImageView *status=(UIImageView *)[view viewWithTag:tagStart+1];
    if ([self.currentCenter[@"haiba"] doubleValue]>[info[@"haiba"] doubleValue]) {
        status.image=[UIImage imageNamed:@"status_down"];
    }else{
        status.image=[UIImage imageNamed:@"status_up"];
    }
    
    //center与destination之间的距离
    UILabel *miles=(UILabel *)[view viewWithTag:tagStart+2];
    CLLocation *center=[[CLLocation alloc] initWithLatitude:[self.currentCenter[@"lat"] doubleValue] longitude:[self.currentCenter[@"long"] doubleValue]];
    CLLocation *destination=[[CLLocation alloc] initWithLatitude:[info[@"lat"] doubleValue] longitude:[info[@"long"] doubleValue]];
    CLLocationDistance meters=[center distanceFromLocation:destination];
    if (meters>1000) {
        miles.text=[NSString stringWithFormat:@"%.2fkm",meters/1000];
    }else{
        miles.text=[NSString stringWithFormat:@"%dm",(int)meters];
    }
    
    //目的地名字
    UILabel *destinationName=(UILabel *)[view viewWithTag:tagStart+3];
    destinationName.text=info[@"name"];
    
    double degrees=[self angleWithCenter:self.currentCenter Destination:info];
    double rotation=-1 * M_PI_2+degreesToRadians(degrees);
    
    view.transform=CGAffineTransformMakeRotation(rotation);
    
    NSLog(@"degrees %f",degrees);
}

-(void)doClickOnCompass:(UIButton *)button {
    if ([self.compassDelegate respondsToSelector:@selector(didClickOnOneCompass:)]) {
        int index;
        switch (button.tag) {
            case 104:
                index=0;
                break;
            case 204:
                index=1;
                break;
            case 304:
                index=2;
                break;
            default:
                break;
        }
        
        NSDictionary *destination=self.currentDestinationArr[index];
        
        [self.compassDelegate didClickOnOneCompass:destination];
    }
}

-(void)show {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=1.f;
    } completion:^(BOOL finished) {
        if ([self.compassDelegate respondsToSelector:@selector(didShowCompassView)]) {
            [self.compassDelegate didShowCompassView];
        }
    }];
}

-(void)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0.f;
    } completion:^(BOOL finished) {
        if ([self.compassDelegate respondsToSelector:@selector(didHiddenCompassView)]) {
            [self.compassDelegate didHiddenCompassView];
        }
    }];
}

-(void)reload {
    UIView *view1=[self.compassBackView viewWithTag:100];
    [view1 removeFromSuperview];
    UIView *view2=[self.compassBackView viewWithTag:200];
    [view2 removeFromSuperview];
    UIView *view3=[self.compassBackView viewWithTag:300];
    [view3 removeFromSuperview];
    
    [self setCompass];
    
    if ([self.compassDelegate respondsToSelector:@selector(didReloadCompassView)]) {
        [self.compassDelegate didReloadCompassView];
    }
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
    self.beiView.transform = CGAffineTransformMakeRotation(-1 * degreesToRadians(newHeading.magneticHeading));
}

@end
