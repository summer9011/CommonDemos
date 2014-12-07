//
//  TableCellDeleteController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "TableCellDeleteController.h"

@interface TableCellDeleteController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableA;

@end

@implementation TableCellDeleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableA.dataSource=(id<UITableViewDataSource>)self;
    self.tableA.delegate=(id<UITableViewDelegate>)self;
    
    [self.tableA registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doEdit:(id)sender {
    if (self.tableA.isEditing) {
        [self.tableA setEditing:NO animated:YES];
    }else{
        [self.tableA setEditing:YES animated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView=[[UIView alloc] init];
    headerView.backgroundColor=[UIColor redColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView=[[UIView alloc] init];
    footerView.backgroundColor=[UIColor greenColor];
    return footerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //标记
//    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
//    if (cell.accessoryType==UITableViewCellAccessoryNone) {
//        cell.accessoryType=UITableViewCellAccessoryCheckmark;
//    }else{
//        cell.accessoryType=UITableViewCellAccessoryNone;
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
}
 
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"1111");
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%d",indexPath.row+1];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tableView:commitEditingStyle:forRowAtIndexPath:");
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"tableView:moveRowAtIndexPath:toIndexPath:");
}

@end
