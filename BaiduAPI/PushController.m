//
//  PushController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/18.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "PushController.h"
#import <CoreLocation/CoreLocation.h>

@interface PushController () <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation PushController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    
    if ([UIDevice currentDevice].systemVersion.floatValue>=8.0) {
        [_locationManager requestAlwaysAuthorization];
    }
}

-(void)initNotify {
    CLLocationCoordinate2D center;
    center.latitude=29.85413151;
    center.longitude=121.58188563;
    CLLocationDistance radius;
    radius=50;
    
    CLCircularRegion *region=[[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:@"Notify"];
    
    UILocalNotification *localNotify=[[UILocalNotification alloc] init];
    localNotify.alertBody=[NSString stringWithFormat:@"you are arrived in (%f,%f) !",center.latitude,center.longitude];
    localNotify.regionTriggersOnce=NO;
    localNotify.region=region;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotify];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"start notify");
            [self initNotify];
            break;
            
        default:
            [_locationManager requestAlwaysAuthorization];
            break;
    }
}

@end