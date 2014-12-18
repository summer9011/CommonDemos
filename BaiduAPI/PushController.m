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

@property(nonatomic,strong)CLLocationManager *locationManager;

@end

@implementation PushController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.positonLabel.text=@"0,0";
    self.statusLabel.text=@"No";
    
    self.locationManager=[[CLLocationManager alloc] init];
    
    self.locationManager.delegate=self;
    
    if ([UIDevice currentDevice].systemVersion.floatValue>=8.0) {
        [self.locationManager requestAlwaysAuthorization];       //始终定位
    }
    
}

-(void)initLocationNotify:(NSString *)msg {
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *notify=[[UILocalNotification alloc] init];
    notify.alertBody=msg;
    notify.alertAction=msg;
    notify.soundName=UILocalNotificationDefaultSoundName;
    NSDictionary *info=[NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    notify.userInfo=info;
    
    notify.regionTriggersOnce=NO;
    
    //29.83644036,+121.55019026
    CLLocationCoordinate2D center;
    center.latitude=29.83644036;
    center.longitude=121.55019026;
    CLLocationDistance radius;
    radius=5;
    notify.region=[[CLRegion alloc] initCircularRegionWithCenter:center radius:radius identifier:@"region"];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"locations %@",locations);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status==kCLAuthorizationStatusAuthorizedAlways||status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"开始监听");
        [self initLocationNotify:@"inside"];
    }
}

/*
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self initLocationNotify:@"inside"];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self initLocationNotify:@"outside"];
}
*/

@end
