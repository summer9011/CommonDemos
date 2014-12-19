//
//  MapDemoListController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/3.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "MapDemoListController.h"

#import "LocationViewController.h"
#import "ASICacheViewController.h"
#import "ChangeColorController.h"
#import "DownloadViewController.h"
#import "WebViewController.h"
#import "CustomMapController.h"
#import "JCTiledViewController.h"
#import "EXIFViewController.h"
#import "HandleController.h"
#import "ScrollPageController.h"
#import "TableCellDeleteController.h"
#import "MultiThreadController.h"
#import "ResponserController.h"

@interface MapDemoListController ()

@end

@implementation MapDemoListController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"自定义Baidu地图";
            break;
        case 1:
            cell.textLabel.text=@"ASI和SDWI缓存";
            break;
        case 2:
            cell.textLabel.text=@"CAGradientLayer渐变色";
            break;
        case 3:
            cell.textLabel.text=@"ASI断点续传下载和上传图片";
            break;
        case 4:
            cell.textLabel.text=@"WebView例子NSURLCache";
            break;
        case 5:
            cell.textLabel.text=@"自定义地图";
            break;
        case 6:
            cell.textLabel.text=@"JCTiledView";
            break;
        case 7:
            cell.textLabel.text=@"图片压缩保留exif";
            break;
        case 8:
            cell.textLabel.text=@"从相册中获取图像并处理";
            break;
        case 9:
            cell.textLabel.text=@"ScrollView循环左右滑动";
            break;
        case 10:
            cell.textLabel.text=@"TableView删除功能";
            break;
        case 11:
            cell.textLabel.text=@"多线程例子";
            break;
        case 12:
            cell.textLabel.text=@"FirstResponser";
            break;
        case 13:
            cell.textLabel.text=@"基于地理位置的消息推送";
            break;
        case 14:
            cell.textLabel.text=@"Bonjour服务发现";
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *board=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id VC;
    
    switch (indexPath.row) {
        case 0:
            VC=[board instantiateViewControllerWithIdentifier:@"LocationVC"];
            break;
        case 1:
            VC=[board instantiateViewControllerWithIdentifier:@"ASICacheVC"];
            break;
        case 2:
            VC=[board instantiateViewControllerWithIdentifier:@"ChangeColorVC"];
            break;
        case 3:
            VC=[board instantiateViewControllerWithIdentifier:@"DownloadVC"];
            break;
        case 4:
            VC=[board instantiateViewControllerWithIdentifier:@"WebVC"];
            break;
        case 5:
            VC=[board instantiateViewControllerWithIdentifier:@"CustomMapVC"];
            break;
        case 6:
            VC=[board instantiateViewControllerWithIdentifier:@"JCTiledVC"];
            break;
        case 7:
            VC=[board instantiateViewControllerWithIdentifier:@"EXIFVC"];
            break;
        case 8:
            VC=[board instantiateViewControllerWithIdentifier:@"HandleImageVC"];
            break;
        case 9:
            VC=[board instantiateViewControllerWithIdentifier:@"ScrollPageVC"];
            break;
        case 10:
            VC=[board instantiateViewControllerWithIdentifier:@"TableCellDeleteVC"];
            break;
        case 11:
            VC=[board instantiateViewControllerWithIdentifier:@"MultiThreadVC"];
            break;
        case 12:
            VC=[board instantiateViewControllerWithIdentifier:@"ResponserVC"];
            break;
        case 13:
            VC=[board instantiateViewControllerWithIdentifier:@"PushVC"];
            break;
        case 14:
            VC=[board instantiateViewControllerWithIdentifier:@"BonjourVC"];
            break;
    }
    
    [self.navigationController pushViewController:VC animated:YES];
}

@end
