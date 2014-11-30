//
//  DownloadViewController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/5.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "DownloadViewController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface DownloadViewController ()

@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *progressNum;
@property (retain, nonatomic) ASINetworkQueue *myNetWorkQueue;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * 下载资源
 */
- (IBAction)doDownload:(id)sender {
    NSString *storgePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/download/putty.exe"];
    
    NSURL *url=[NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/78/15699/putty_V0.63.0.0.43510830.exe"];
    __block ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:storgePath];
    [request setDownloadProgressDelegate:_progress];
    [request startSynchronous];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
