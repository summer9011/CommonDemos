//
//  ClientController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/21.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ClientController.h"
#import "AsyncSocket.h"

@interface ClientController () {
    NSString *receiverID;           //接收者的ID
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
}

//Do connect to socketServer
- (IBAction)doConnect:(id)sender {
    
}

//Do get available receiver list
- (IBAction)doGetList:(id)sender {
}

//Do send data to socketServer
- (IBAction)doSendData:(id)sender {
}

@end
