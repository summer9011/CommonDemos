//
//  GameController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/20.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "GameController.h"
#import <GameKit/GameKit.h>

#define GAMIMG 0    //游戏进行中
#define GAMED 1     //游戏结束

@interface GameController () <GKPeerPickerControllerDelegate,GKSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayer1;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayer2;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnClick;

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) GKPeerPickerController *picker;
@property (nonatomic,strong) GKSession *session;

@property (nonatomic,assign) int timeCount;

@end

@implementation GameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timeCount=30;
    _btnClick.enabled=NO;
}

- (IBAction)doClick:(id)sender {
    int count=[_lblPlayer2.text intValue];
    _lblPlayer2.text=[NSString stringWithFormat:@"%d",++count];
    
    NSString *sendStr=[NSString stringWithFormat:@"{\"code\":%d,\"count\":%d}",GAMIMG,count];
    NSData *data=[sendStr dataUsingEncoding:NSUTF8StringEncoding];
    if (_session) {
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}

- (IBAction)doConnect:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"连接"]) {
        NSLog(@"连接");
        
        _picker=[[GKPeerPickerController alloc] init];
        
        _picker.delegate=self;
        _picker.connectionTypesMask=GKPeerPickerConnectionTypeNearby;
        
        [_picker show];
    }else if ([sender.titleLabel.text isEqualToString:@"断开连接"]){
        NSLog(@"断开连接");
        
        [_session disconnectPeerFromAllPeers:@"quit"];
        _session.delegate=nil;
    }
    
}

//清除UI画面上的数据
-(void)cleanUI {
    _lblTimer.text=@"30s";
    _lblPlayer1.text=@"0";
    _lblPlayer2.text=@"0";
}

//更新计时器
-(void)updateTime{
    _timeCount--;
    
    if (_timeCount==0) {
        [_timer invalidate];
        
        _timeCount=30;
        _btnClick.enabled=NO;
    }
    
    _lblTimer.text=[NSString stringWithFormat:@"%ds",_timeCount];
    
}

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    NSLog(@"从一个Peer接收到数据");
    
    id jsonObj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *code=jsonObj[@"code"];
    if ([code intValue]==GAMIMG) {
        NSNumber *count=jsonObj[@"count"];
        _lblPlayer1.text=[NSString stringWithFormat:@"%@",count];
        
    }else if ([code intValue]==GAMED){
        [self cleanUI];
    }
}

#pragma mark - GKPeerPickerControllerDelegate

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    NSLog(@"搜索连接类型为：%d的设备",type);
    
    return nil;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    NSLog(@"选择连接到某个Peer");
    
    _session=session;
    _session.delegate=self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    _picker.delegate=nil;
    [_picker dismiss];
    
    _btnClick.enabled=YES;
    [_btnConnect setTitle:@"断开连接" forState:UIControlStateNormal];
    _timer=[NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    NSLog(@"peerPickerControllerDidCancel:");
    
    _picker.delegate=nil;
    _picker=nil;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSLog(@"session状态改变");
    
    if (state==GKPeerStateConnected) {
        NSLog(@"connected");
        
        _btnClick.enabled=YES;
        [_btnConnect setTitle:@"断开连接" forState:UIControlStateNormal];
        
    }else if (state==GKPeerStateDisconnected){
        NSLog(@"disconnected");
        
        [self cleanUI];
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"session:didReceiveConnectionRequestFromPeer:");
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"session:connectionWithPeerFailed:withError:");
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"session:didFailWithError:");
}

@end
