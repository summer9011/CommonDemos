//
//  BonjourController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/18.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "BonjourController.h"

#define serviceDomain @"local."
#define serviceType @"_http._tcp."
#define serviceName @"bonjourService"
#define servicePort 8899

@interface BonjourController () <NSNetServiceDelegate,NSNetServiceBrowserDelegate>

@property(nonatomic,strong)NSNetService *service;
@property(nonatomic,strong)NSNetServiceBrowser *serviceBrowser;

@end

@implementation BonjourController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//发布服务
- (IBAction)publishService:(id)sender {
    self.service=[[NSNetService alloc] initWithDomain:serviceDomain type:serviceType name:serviceName port:servicePort];
    [self.service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.service.delegate=self;
    
    [self.service publish];
}

//查找服务
- (IBAction)searchService:(id)sender {
    self.serviceBrowser=[[NSNetServiceBrowser alloc] init];
    self.serviceBrowser.delegate=self;
    [self.serviceBrowser searchForServicesOfType:serviceType inDomain:serviceDomain];
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"netServiceWillPublish: %@",sender);
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"netServiceDidPublish: %@",sender);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"netService:didNotPublish: %@",errorDict);
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"netServiceBrowserWillSearch: %@",aNetServiceBrowser);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"netServiceBrowserDidStopSearch: %@",aNetServiceBrowser);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    NSLog(@"netServiceBrowser:didNotSearch: %@",errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"netServiceBrowser:didFindDomain:moreComing: %@",domainString);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"netServiceBrowser:didFindService:moreComing: %@",aNetService);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    NSLog(@"netServiceBrowser:didRemoveDomain:moreComing: %@",domainString);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"netServiceBrowser:didRemoveService:moreComing: %@",aNetService);
}

@end
