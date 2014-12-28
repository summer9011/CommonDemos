//
//  CompassView.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/28.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CompassView.h"
#import <CoreLocation/CoreLocation.h>

#define degreesToRadians(x) (M_PI * x / 180.0)

@interface CompassView () <CLLocationManagerDelegate> {
    CGRect r;
}

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSMutableDictionary *center;
@property (nonatomic,strong) NSMutableArray *destinationArr;

@property (nonatomic,strong) UIView *compassView;
@property (nonatomic,strong) UIView *compass1;
@property (nonatomic,strong) UIView *compass2;
@property (nonatomic,strong) UIView *compass3;

@end

@implementation CompassView

-(id)initWithFrame:(CGRect)frame Center:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr {
    self=[super initWithFrame:frame];
    if (self) {
        r=frame;
        self.center=[NSMutableDictionary dictionary];
        self.destinationArr=[NSMutableArray array];
        
        [self.center addEntriesFromDictionary:center];
        [self.destinationArr addObjectsFromArray:destinationArr];
        
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

-(void)initSelfView {
    self.backgroundColor=[UIColor clearColor];
    
    UIView *backView=[[UIView alloc] initWithFrame:r];
    backView.backgroundColor=[UIColor colorWithWhite:0.f alpha:0.5f];
    [self addSubview:backView];
    
    UILabel *beiLabel=[[UILabel alloc] initWithFrame:CGRectMake(r.size.width-15, 5, 10, 10)];
    beiLabel.text=@"北";
    beiLabel.textColor=[UIColor colorWithRed:126/255.f green:129/255.f blue:129/255.f alpha:1.f];
    beiLabel.font=[UIFont systemFontOfSize:11];
    [self addSubview:beiLabel];
    
    UIImageView *beiImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bei"]];
    beiImage.frame=CGRectMake(r.size.width-15, 20, 10, 10);
    [self addSubview:beiImage];
    
    float x,y,edge;
    
    if (r.size.width>r.size.height) {
        x=(r.size.width-r.size.height)/2;
        y=0.f;
    }else{
        x=0.f;
        y=(r.size.height-r.size.width)/2;
    }
    
    NSLog(@"%f,%f,%f",x,y,edge);
    
    self.compassView=[[UIView alloc] initWithFrame:CGRectMake(x, y, edge, edge)];
    self.compassView.backgroundColor=[UIColor clearColor];
    [self addSubview:self.compassView];
    
}

//设置指向标
-(void)setCompass {
    CGRect compassViewRect=self.compassView.frame;
    
    if (!self.compass1) {
        self.compass1=[[UIView alloc] initWithFrame:CGRectMake((compassViewRect.size.width-45)/2.f, (compassViewRect.size.height/2-30)/2, 45, 30)];
        
        UIImageView *jiantou=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou"]];
        jiantou.frame=self.compass1.frame;
        [self.compass1 addSubview:jiantou];
        
        UIImageView *status=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up"]];
        status.tag=101;
        status.frame=CGRectMake(30, 30, 10, 6);
        [self.compass1 addSubview:status];
        
        UILabel *miles=[[UILabel alloc] initWithFrame:CGRectMake(56, 30, 80, 20)];
        miles.text=@"100m";
        miles.font=[UIFont systemFontOfSize:11];
        [self.compass1 addSubview:miles];
        
        UILabel *destinationName=[[UILabel alloc] initWithFrame:CGRectMake(30, 30, compassViewRect.size.width-60, 30)];
        destinationName.text=@"小普陀";
        [self.compass1 addSubview:destinationName];
        
        self.compass1.transform=CGAffineTransformMakeRotation(M_PI_2);
        
    }
    
//    for (NSDictionary *destination in self.destinationArr) {
//        
//    }
}

-(void)setCenter:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr {
    [self.center removeAllObjects];
    [self.destinationArr removeAllObjects];
    
    [self.center addEntriesFromDictionary:center];
    [self.destinationArr addObjectsFromArray:destinationArr];
}

-(void)show {
    
}

-(void)hidden {
    
}

-(void)reload {
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.compassView.transform = CGAffineTransformMakeRotation(-1 * degreesToRadians(newHeading.magneticHeading));
}

@end
