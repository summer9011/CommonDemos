//
//  AppDelegate.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/3.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "ASIHTTPRequest.h"
#import "CustomCache.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain)BMKMapManager *_mapManager;     //百度地图
@property (nonatomic,retain)CustomCache *myCache;           //自定义缓存

@end

