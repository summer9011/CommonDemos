//
//  MultiThreadController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "MultiThreadController.h"

@interface MultiThreadController () {
    int tickets;
    int count;
    NSThread *ticketsThread1;
    NSThread *ticketsThread2;
    NSLock *theLock;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation MultiThreadController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*==============================================================================*/
/*                                   NSThread                                   */
/*==============================================================================*/

- (IBAction)doNSThread:(id)sender {
    /*
    NSURL *url=[NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
    
    NSThread *thread=[[NSThread alloc] initWithTarget:self selector:@selector(downloadImage:) object:url];
    thread.name=@"thread1";
    [thread start];
    NSLog(@"当前线程名 %@",[thread name]);
    */
    
    tickets=100;
    count=0;
    theLock=[[NSLock alloc] init];
    
    ticketsThread1=[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [ticketsThread1 setName:@"1"];
    [ticketsThread1 start];
    
    ticketsThread2=[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [ticketsThread2 setName:@"2"];
    [ticketsThread2 start];
}

-(void)downloadImage:(NSURL *)url {
    NSLog(@"下载图片");
    
    NSData *data=[[NSData alloc] initWithContentsOfURL:url];
    UIImage *image=[UIImage imageWithData:data scale:0.5f];
    if (image) {
        [self performSelectorOnMainThread:@selector(updateImageView:) withObject:image waitUntilDone:YES];
    }else{
        NSLog(@"不存在图片");
    }
}

-(void)updateImageView:(UIImage *)image {
    NSLog(@"更新图片View");
    
    self.imgView.image=image;
}

-(void)run {
    while (true) {
        /*
        [theLock lock];         //加上lock以后保持线程同步，使线程顺序执行，保证数据的正确性
        if (tickets>=0) {
            [NSThread sleepForTimeInterval:0.09f];
            
            count=100-tickets;
            NSLog(@"当前票数：%d，售出：%d，线程名：%@",tickets,count,[[NSThread currentThread] name]);
            tickets--;
            
        }else{
            break;
        }
        [theLock unlock];
        */
        
        @synchronized(self) {       //线程保护，避免显示的写lock
            if (tickets>=0) {
                [NSThread sleepForTimeInterval:0.09f];
                
                count=100-tickets;
                NSLog(@"当前票数：%d，售出：%d，线程名：%@",tickets,count,[[NSThread currentThread] name]);
                tickets--;
                
            }else{
                break;
            }
        }
    }
}

/*==============================================================================*/
/*                                 NSOperation                                  */
/*==============================================================================*/

- (IBAction)doNSOperation:(id)sender {
    NSURL *url=[NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
    
    NSInvocationOperation *operation=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:url];
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

/*==============================================================================*/
/*                                      GCD                                     */
/*==============================================================================*/

- (IBAction)doGCD:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url=[NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
        NSData *data=[[NSData alloc] initWithContentsOfURL:url];
        UIImage *image=[UIImage imageWithData:data scale:0.5f];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgView.image=image;
            });
        }
    });
}


@end
