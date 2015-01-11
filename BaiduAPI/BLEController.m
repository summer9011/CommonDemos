//
//  BLEController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/29.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "BLEController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEController () <CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *beCenter;
@property (weak, nonatomic) IBOutlet UIButton *bePeripheral;

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) NSMutableData *data;
@property (weak, nonatomic) IBOutlet UIButton *centralDisconnect;


@property (nonatomic,strong) CBPeripheralManager *peripheralManager;
@property (nonatomic,strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic,strong) CBMutableService *customService;
@property (nonatomic,strong) CBCentral *receiverCentral;
@property (weak, nonatomic) IBOutlet UIButton *sendDataBtn;

@property (nonatomic,assign) int count;

@end

static NSString * const kServiceUUID=@"66DAEB9F-99E6-4F3C-A726-EEE92E9AA558";
static NSString * const kCharacteristicUUID=@"6CDF1ACA-9931-4038-B438-DFEC4066F256";

@implementation BLEController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.count=0;
}

//成为中心
- (IBAction)clickBeCenter:(id)sender {
    [self unabled];
    self.centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.centralDisconnect.enabled=YES;
}

//成为外设
- (IBAction)clickBePeripheral:(id)sender {
    [self unabled];
    self.peripheralManager=[[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

//外设发送数据
- (IBAction)peripheraManagerSendData:(id)sender {
    self.count++;
    NSLog(@"%d",self.count);
    
    NSString *str=[NSString stringWithFormat:@"%d",self.count];
    [self.peripheralManager updateValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.customCharacteristic onSubscribedCentrals:@[self.receiverCentral]];
}

//中央断开与周边连接
- (IBAction)centralDisconnectAll:(id)sender {
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    
    self.beCenter.enabled=YES;
    self.centralDisconnect.enabled=NO;
}

-(void)unabled {
    self.beCenter.enabled=NO;
    self.bePeripheral.enabled=NO;
}

//外设设置服务和特征
-(void)setupService {
    //创建特征
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    self.customCharacteristic=[[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    //创建服务
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    self.customService=[[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    //给服务设置特征
    [self.customService setCharacteristics:@[self.customCharacteristic]];
    //发布服务
    [self.peripheralManager addService:self.customService];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            //搜寻所有的服务
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"central manager should change state");
            
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"搜索外设");
    
    if (self.peripheral!=peripheral) {
        self.peripheral=peripheral;
        
        NSLog(@"连接到外设:%@",peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
        
        [self.centralManager stopScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"成功连接到外设:%@",peripheral);
    
    //清空data
    [self.data setLength:0];
    [self.peripheral setDelegate:self];
    
    //请求外设寻找服务
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接到外设:%@失败:%@",peripheral,error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"断开与外设:%@ 的连接 错误:%@",peripheral,error);
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"外设修改了服务 :%@",invalidatedServices);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service :%@",[error localizedDescription]);
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"找到的serviceUUID %@",service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            [service.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"发现了外设 %@ 的特征 错误 %@",service.UUID,error);
    if (error) {
        NSLog(@"Error discovering characteristic :%@",[error localizedDescription]);
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"外设更新了特征 %@ 的值",characteristic);
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
        return;
    }
    
    [self.data appendData:characteristic.value];
    
    NSString *data=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",data);
    if (data&&![data isEqualToString:@""]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Data值" message:data delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"特征 %@ 更新了值 错误 %@",characteristic,error);
    if (error) {
        NSLog(@"Error change notification state: %@",[error localizedDescription]);
    }
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@",characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }else{
        NSLog(@"Notification stopped on %@ disconnecting",characteristic);
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            break;
            
        default:
            NSLog(@"peripheral manager should change state");
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"开始广播外设:%@ 错误:%@",peripheral,error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"外设添加服务:%@ 错误:%@",service,error);
    
    if (!error) {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:@"ICServer",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUUID]]}];
    }
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"中央预定该服务");
    
    self.receiverCentral=central;
    
    self.sendDataBtn.enabled=YES;
}

@end
