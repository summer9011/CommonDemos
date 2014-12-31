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


@property (nonatomic,strong) CBPeripheralManager *peripheralManager;
@property (nonatomic,strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic,strong) CBMutableService *customService;

@end

static NSString * const kServiceUUID=@"66DAEB9F-99E6-4F3C-A726-EEE92E9AA558";
static NSString * const kCharacteristicUUID=@"6CDF1ACA-9931-4038-B438-DFEC4066F256";

@implementation BLEController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//成为中心
- (IBAction)clickBeCenter:(id)sender {
    [self unabled];
    self.centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}

//成为外设
- (IBAction)clickBePeripheral:(id)sender {
    [self unabled];
    self.peripheralManager=[[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
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
    NSLog(@"中心更新蓝牙状态: %ld",central.state);
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            //搜寻所有的服务
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@"YES"}];
            break;
            
        default:
            NSLog(@"central manager should change state");
            
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"centralManager:willRestoreState:");
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager:didRetrievePeripherals:");
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"centralManager:didRetrieveConnectedPeripherals:");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"发现外设:%@",peripheral);
    if (self.peripheral!=peripheral) {
        self.peripheral=peripheral;
        
        NSLog(@"连接到外设:%@",peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
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

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    NSLog(@"peripheralDidUpdateName:");
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral {
    NSLog(@"peripheralDidInvalidateServices:");
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    NSLog(@"peripheral:didModifyServices:");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"peripheralDidUpdateRSSI:error:");
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"peripheral:didReadRSSI:error:");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"外设找到了自己提供的服务 错误%@",error);
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    NSLog(@"peripheral:didDiscoverIncludedServicesForService:error:");
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
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"peripheral:didWriteValueForCharacteristic:error:");
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"peripheral:didDiscoverDescriptorsForCharacteristic:error:");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"peripheral:didUpdateValueForDescriptor:error:");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    NSLog(@"peripheral:didWriteValueForDescriptor:error:");
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"外设更新蓝牙状态: %ld",peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            break;
            
        default:
            NSLog(@"peripheral manager should change state");
            
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    NSLog(@"peripheralManager:willRestoreState:");
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
    NSLog(@"peripheralManager:central:didSubscribeToCharacteristic:");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"peripheralManager:central:didUnsubscribeFromCharacteristic:");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"peripheralManager:didReceiveReadRequest:");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"peripheralManager:didReceiveWriteRequests:");
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers:");
}

@end
