//
//  ASICacheViewController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/4.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ASICacheViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "UIImage+GIF.h"

#define IMG_URL @"http://www.iyi8.com/uploadfile/2014/0821/20140821123403289.jpg"

@interface ASICacheViewController ()

@property (retain, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation ASICacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 * ASI请求数据
 */
- (IBAction)doRequest:(id)sender {
    
//    NSURL *url=[NSURL URLWithString:@"http://api.youwandao.com/dest?destid=43057"];
    NSURL *url=[NSURL URLWithString:@"http://api.youwandao.com/memory/list?destid=43097"];
//    NSURL *url=[NSURL URLWithString:@"http://api.youwandao.com/memory?memoryid=75"];
    
    __block ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [request setDownloadCache:appDelegate.myCache];
    //设置缓存存储策略为本地永久缓存
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    //完成请求
    [request setCompletionBlock:^{
        if (request.didUseCachedResponse) {
            NSLog(@"data from cache");
            NSDictionary *dic=[NSKeyedUnarchiver unarchiveObjectWithData:[request responseData]];
            NSLog(@"%@",dic);
        }else{
            NSLog(@"data from network");
            NSLog(@"%@",[request responseString]);
        }
    }];
    //请求失败
    [request setFailedBlock:^{
        NSLog(@"failed");
        NSError *error=[request error];
        NSLog(@"%@",error);
    }];
    
    [request startAsynchronous];
}

/*
 * ASI清除缓存
 */
- (IBAction)clearCache:(id)sender {
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myCache clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    NSLog(@"ASI clear success!");
}

/*
 * SDWI请求图片数据
 */
- (IBAction)doSDWIRequest:(id)sender {
    NSURL *imgUrl=[NSURL URLWithString:IMG_URL];
    
    /*
    //SDImageCache会将图片至内存和磁盘，无图片缓存时，第一次先请求，之后访问内存；有图片缓存时，第一次访问磁盘，之后访问内存
    [_imgView sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"back"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"image %@, error %@, cacheType %ld, imageURL %@",image,error,cacheType,imageURL);
    }];
    */
    
    //gif动图
    UIImage *gifImage=[UIImage sd_animatedGIFNamed:@"moving"];
    [_imgView sd_setImageWithURL:imgUrl placeholderImage:gifImage];
    
}

/*
 * SDWI清除缓存
 */
- (IBAction)clearSDWICache:(id)sender {
    //清除磁盘上的图片缓存
    [[SDImageCache sharedImageCache] clearDisk];
    //清除内存中的图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    
    _imgView.image=nil;
    
    NSLog(@"SDWI clear success!");
}

- (IBAction)clearImage:(id)sender {
    _imgView.image=nil;
}

@end
