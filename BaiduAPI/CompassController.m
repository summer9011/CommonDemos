//
//  CompassController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/24.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CompassController.h"
#import <CoreLocation/CoreLocation.h>

#define degreesToRadians(x) (M_PI * x / 180.0)

@interface CompassController () <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIView *headingView;

@end

@implementation CompassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager=[[CLLocationManager alloc] init];
    self.locationManager.delegate=self;
    
    NSLog(@"%d",[CLLocationManager headingAvailable]);
    
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter=kCLHeadingFilterNone;
        [self.locationManager startUpdatingHeading];
    }
    
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //根据角度旋转图片 ，newHeading.magneticHeading为夹角
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * degreesToRadians(newHeading.magneticHeading));
    self.headingView.transform = transform;
}

@end
