//
//  ClientController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/21.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ClientController.h"
#import "AsyncSocket.h"

@interface ClientController () <AsyncSocketDelegate,UITableViewDataSource,UITableViewDelegate> {
    NSString *receiverID;           //接收者的ID
    AsyncSocket *asyncSocket;
}

@property (weak, nonatomic) IBOutlet UITextField *ipTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (weak, nonatomic) IBOutlet UIButton *getListBtn;
@property (weak, nonatomic) IBOutlet UITableView *receiverList;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation ClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _getListBtn.enabled=NO;
    _sendBtn.enabled=NO;
    
    [_receiverList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    asyncSocket=[[AsyncSocket alloc] initWithDelegate:self];
    
}

//Do connect to socketServer
- (IBAction)doConnect:(id)sender {
    if (_ipTF.text&&_portTF.text) {
        unsigned short port=[_portTF.text intValue];
        
        NSError *error;
        if (![asyncSocket connectToHost:_ipTF.text onPort:port error:&error]) {
            NSLog(@"Connect Error %@",error);
        }else{
            _connectBtn.enabled=NO;
            _getListBtn.enabled=YES;
        }
    }
}

//Do get available receiver list
- (IBAction)doGetList:(id)sender {
    
}

//Do send data to socketServer
- (IBAction)doSendData:(id)sender {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //conf the cell
    
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - AsyncSocketDelegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"onSocketDidDisconnect:");
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"onSocket:didAcceptNewSocket:");
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket {
    NSLog(@"onSocket:wantsRunLoopForNewSocket:");
    
    return [NSRunLoop currentRunLoop];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"onSocket:didConnectToHost:%@ port:%d",host,port);
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"onSocket:didReadData:withTag:");
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"onSocket:didReadPartialDataOfLength:tag:");
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"onSocket:didWriteDataWithTag:");
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"onSocket:didWritePartialDataOfLength:tag:");
}

- (void)onSocketDidSecure:(AsyncSocket *)sock {
    NSLog(@"onSocketDidSecure:");
}

@end
