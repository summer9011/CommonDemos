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
#import "ASIFormDataRequest.h"

@interface DownloadViewController ()

@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *progressNum;
@property (retain, nonatomic) ASINetworkQueue *myNetWorkQueue;

@property (retain, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//下载资源
- (IBAction)doDownload:(id)sender {
    NSString *storgePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/download/putty.exe"];
    
    NSURL *url=[NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/78/15699/putty_V0.63.0.0.43510830.exe"];
    __block ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:storgePath];
    [request setDownloadProgressDelegate:_progress];
    [request startSynchronous];
    
}

//选择图片并上传
- (IBAction)doUploadImage:(id)sender {
    _imagePicker=[[UIImagePickerController alloc] init];
    _imagePicker.delegate=self;
    _imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    NSURL *url=[NSURL URLWithString:@"http://api.youwandao.com/memory/add"];
    ASIFormDataRequest *formDataRequest=[ASIFormDataRequest requestWithURL:url];
    [formDataRequest setPostValue:@"a46f51ffd7f043feab709a668c01f666" forKey:@"appkey"];
    [formDataRequest setPostValue:@"077e674c6cc7853aa7e3b23af650e3ac" forKey:@"access_token"];
    [formDataRequest setPostValue:@"测试" forKey:@"desc"];
    [formDataRequest setPostValue:@"10" forKey:@"roadid"];
    
    NSData *imgData=UIImageJPEGRepresentation(image, 0.7);
    [formDataRequest addData:imgData withFileName:@"memory.jpg" andContentType:@"image/jpeg" forKey:@"pic"];
    
    [formDataRequest setDelegate:self];
    [formDataRequest setDidFinishSelector:@selector(requestFinishedOnAddImage:)];
    [formDataRequest setTimeOutSeconds:10];
    [formDataRequest setRequestMethod:@"POST"];
    [formDataRequest startAsynchronous];
}

-(void)requestFinishedOnAddImage:(ASIHTTPRequest *)request {
    NSLog(@"%@",request.responseString);
    [_imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
