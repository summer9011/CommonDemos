//
//  ClientController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/21.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ClientController.h"
#import "AsyncSocket.h"

#import <AudioToolbox/AudioToolbox.h>

#define IP @"192.168.1.101"
#define PORT 8480

@interface ClientController () <AsyncSocketDelegate,UITableViewDataSource,UITableViewDelegate> {
    NSString *ownerID;                      //当前的用户ID
    
    NSMutableArray *userList;               //用户列表
    NSMutableArray *recevierList;           //接收者列表
    
    NSTimer *heartBeatTimer;
    
    AsyncSocket *asyncSocket;
    
    UITextView *msgView;
    
    int tmpCount;
    
    SystemSoundID soundID;
}

@property (weak, nonatomic) IBOutlet UITextField *IPText;
@property (weak, nonatomic) IBOutlet UITextField *Porttext;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITableView *receiverList;
@property (weak, nonatomic) IBOutlet UIButton *disConnectBtn;

@end

@implementation ClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userList=[NSMutableArray array];
    recevierList=[NSMutableArray array];
    tmpCount=0;
    
    [_receiverList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    asyncSocket=[[AsyncSocket alloc] initWithDelegate:self];
    
    self.connectBtn.enabled=YES;
    self.disConnectBtn.enabled=NO;
}

//连接
- (IBAction)doConnect:(id)sender {
    NSString *ip;
    short port;
    
    if (self.IPText.text&&self.Porttext.text&&![self.IPText.text isEqualToString:@""]&&![self.Porttext.text isEqualToString:@""]) {
        ip=self.IPText.text;
        port=[self.Porttext.text intValue];
    }else{
        ip=IP;
        port=PORT;
    }
    
    NSError *error;
    if (![asyncSocket connectToHost:ip onPort:port error:&error]) {
        NSLog(@"error %@",error);
    }
    
}

//断开
- (IBAction)doDisConnect:(id)sender {
    [heartBeatTimer invalidate];
    [userList removeAllObjects];
    [recevierList removeAllObjects];
    tmpCount=0;
    
    [asyncSocket disconnect];
}

//心跳检测
-(void)longConnectToSocket {
    NSString *str=[NSString stringWithFormat:@"{\"code\":%d,\"msg\":\"%@\",\"clientid\":%d}\n",2,@"",0];
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:data withTimeout:-1 tag:2];
}

-(void)initSendDataView {
    [heartBeatTimer setFireDate:[NSDate distantFuture]];
    
    CGRect r=[UIScreen mainScreen].bounds;
    
    UIView *sendView=[[UIView alloc] initWithFrame:CGRectMake(10, 74, r.size.width-20, r.size.height-84)];
    sendView.backgroundColor=[UIColor blackColor];
    sendView.tag=10;
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame=CGRectMake(10, 10, 80, 30);
    [backBtn setTitle:@"回到列表" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToList) forControlEvents:UIControlEventTouchUpInside];
    [sendView addSubview:backBtn];
    
    msgView=[[UITextView alloc] initWithFrame:CGRectMake(10, 50, sendView.frame.size.width-20, sendView.frame.size.height-100)];
    msgView.textColor=[UIColor redColor];
    [sendView addSubview:msgView];
    
    UIButton *sendBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame=CGRectMake(sendView.frame.size.width/2-40, sendView.frame.size.height-40, 80, 30);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    [sendView addSubview:sendBtn];
    
    
    [self.view addSubview:sendView];
}

-(void)sendData {
    
    NSString *str=[NSString stringWithFormat:@"{\"code\":%d,\"msg\":\"%d\",\"clientid\":%d}\n",5,tmpCount,[recevierList[0] intValue]];
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:data withTimeout:-1 tag:5];
    
    tmpCount++;
}

-(void)backToList {
    NSString *str=[NSString stringWithFormat:@"{\"code\":%d,\"msg\":\"%d\",\"clientid\":%d}\n",6,tmpCount,[recevierList[0] intValue]];
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:data withTimeout:-1 tag:6];
    
    [self clearData];
    
}

-(void)clearData {
    [recevierList removeAllObjects];
    [heartBeatTimer setFireDate:[NSDate date]];
    
    UIView *sendView=[self.view viewWithTag:10];
    [sendView removeFromSuperview];
    msgView=nil;
    tmpCount=0;
}

//播放音效
-(void)playSound:(NSString *)latter {
    NSString *path = [[NSBundle mainBundle] pathForResource:latter ofType:@"wav"];
    if (path) {
        SystemSoundID theSoundID;
        OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
        if (error == kAudioServicesNoError) {
            soundID = theSoundID;
        }else {
            NSLog(@"Failed to create sound ");
        }
    }else{
        NSLog(@"no wav file :%@",latter);
    }
    
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //conf the cell
    NSString *ID=[NSString stringWithFormat:@"%@",userList[indexPath.row]];
    
    if ([ownerID isEqualToString:ID]) {
        cell.textLabel.textColor=[UIColor redColor];
        cell.textLabel.text=[NSString stringWithFormat:@"%@ (自己)",ID];
    }else{
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.text=ID;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    
    if ([ownerID intValue]!=[cell.textLabel.text intValue]) {
        [recevierList removeAllObjects];
        [recevierList addObject:cell.textLabel.text];
        
        NSString *str=[NSString stringWithFormat:@"{\"code\":%d,\"msg\":\"%@\",\"clientid\":%d}\n",4,@"",[cell.textLabel.text intValue]];
        NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
        
        [asyncSocket writeData:data withTimeout:-1 tag:3];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"不能和自己发送消息" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma mark - AsyncSocketDelegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"断开连接");
    
    self.connectBtn.enabled=YES;
    self.disConnectBtn.enabled=NO;
    
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"连接到 %@:%d",host,port);
    
    self.connectBtn.enabled=NO;
    self.disConnectBtn.enabled=YES;
    
    [sock readDataWithTimeout:-1 tag:1];
    
    heartBeatTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    [heartBeatTimer fire];
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"onSocket:didReadPartialDataOfLength:tag:");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *tempArr=[str componentsSeparatedByString:@"\n"];
    
    NSMutableArray *strArr=[tempArr mutableCopy];
    [strArr removeLastObject];
    
    for (NSString *str in strArr) {
        NSLog(@"%@",str);
        NSError *error;
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        
        switch ([dic[@"code"] intValue]) {
            case 1:             //获取欢迎
                ownerID=dic[@"currentid"];
                
                break;
            case 2:{            //获取用户列表
                dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                NSArray *arr=[NSJSONSerialization JSONObjectWithData:[dic[@"msg"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                
                [userList removeAllObjects];
                [userList addObjectsFromArray:arr];
                
                [self.receiverList reloadData];
            }
                break;
                
            case 3:             //心跳检测
                break;
            case 4:{            //建立聊天窗口
                if (dic[@"from"]) {
                    [recevierList removeAllObjects];
                    [recevierList addObject:[NSString stringWithFormat:@"%@",dic[@"from"]]];
                }
                
                [self initSendDataView];
            }
                break;
            case 5:{            //发送数据
                NSDate *current=[NSDate date];
                double diff=current.timeIntervalSince1970-[dic[@"clickTime"] doubleValue];
                
                NSString *oldStr=msgView.text;
                if ([oldStr isEqualToString:@""]) {
                    msgView.text=[NSString stringWithFormat:@"(%@,%f)",dic[@"msg"],diff];
                }else{
                    msgView.text=[NSString stringWithFormat:@"%@;(%@,%f)",oldStr,dic[@"msg"],diff];
                }
                [self playSound:dic[@"msg"]];
            }
                break;
            case 6:{            //一方退出
                if (dic[@"clientid"]) {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"ID:%@ 已退出",dic[@"clientid"]] message:@"队友都走了，你还留着干什么？" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                    alert.delegate=self;
                    [alert show];
                }
                
            }
                break;
        }
    }
    
    
    
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self clearData];
}

@end
