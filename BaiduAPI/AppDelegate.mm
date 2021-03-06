//
//  AppDelegate.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/3.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize _mapManager;
@synthesize myCache;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //百度地图初始化
    _mapManager=[[BMKMapManager alloc] init];
    BOOL ret=[_mapManager start:@"WLumMDBITuX04y7T4d4iTjZU" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //初始化缓存配置
    CustomCache *cache=[[CustomCache alloc] init];
    myCache=cache;
    NSString *cachePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/resource"];
    //设置缓存路径
    [myCache setStoragePath:cachePath];
    //忽略响应头的cache-control或no-cache头
    [myCache setShouldRespectCacheControlHeaders:NO];
    //设置缓存策略为默认
    [myCache setDefaultCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy];
    
//    NSLog(@"ASI缓存目录 %@",cachePath);
    
    //ios8注册消息通知,注册远程通知
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    }
    
    
    return YES;
}

//远程推送通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"remoteNotification register success: %@", deviceToken);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"deviceToken" message:[NSString stringWithFormat:@"%@", deviceToken] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification %@", userInfo[@"aps"]);
    
    //收到通知推送处理业务逻辑
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:@"push"];
    [userDefaults synchronize];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"remoteNotification register error %@", [error localizedDescription]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"remoteNotification" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"didReceiveLocalNotification" message:notification.alertAction delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [userDefaults valueForKey:@"push"];
    if (userInfo) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"push userinfo" message:[NSString stringWithFormat:@"%@", userInfo] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [userDefaults removeObjectForKey:@"push"];
    [userDefaults synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    self.backgroundSessionCompletionHandler = completionHandler;
    //add notification
    [self presentNotification];
}

-(void)presentNotification{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Download Complete!";
    localNotification.alertAction = @"Background Transfer Download!";
    //On sound
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //increase the badge number of application plus 1
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

///**
// *返回网络错误
// *@param iError 错误号
// */
//- (void)onGetNetworkState:(int)iError {
//    NSLog(@"onGetNetworkState %d",iError);
//}
//
///**
// *返回授权验证错误
// *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
// */
//- (void)onGetPermissionState:(int)iError {
//    NSLog(@"onGetPermissionState %d",iError);
//}

@end
