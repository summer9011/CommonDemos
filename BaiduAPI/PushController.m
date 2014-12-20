//
//  PushController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/18.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "PushController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PushController () <MKMapViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (nonatomic,strong) MKPointAnnotation *annotation;
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation PushController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    [_locationManager requestWhenInUseAuthorization];
    
}

- (IBAction)doPin:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Pin"]) {
        
        CLLocationCoordinate2D center;
        center.latitude=29.85413151;
        center.longitude=121.58188563;
        
        _annotation=[[MKPointAnnotation alloc] init];
        _annotation.coordinate=_mapView.centerCoordinate=center;
        [_mapView addAnnotation:_annotation];
        
        [sender setTitle:@"Notify" forState:UIControlStateNormal];
        
    }else if ([sender.titleLabel.text isEqualToString:@"Notify"]){
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification *localNotify=[[UILocalNotification alloc] init];
        localNotify.alertBody=@"you arrive here";
        localNotify.regionTriggersOnce=true;
        localNotify.region=[[CLCircularRegion alloc] initWithCenter:_annotation.coordinate radius:50 identifier:@"region"];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotify];
        
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }else if ([sender.titleLabel.text isEqualToString:@"Cancel"]){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        [sender setTitle:@"Pin" forState:UIControlStateNormal];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"aaa"];
    pin.animatesDrop=YES;
    return pin;
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"ready to go");
    }
}

@end