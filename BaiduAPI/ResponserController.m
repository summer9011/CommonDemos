//
//  ResponserController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/9.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ResponserController.h"

@interface ResponserController ()

@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UITextField *textFiled2;

@end

@implementation ResponserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)singleTap:(UITapGestureRecognizer *)recongnizer {
    [_textFiled resignFirstResponder];
    [_textFiled2 resignFirstResponder];
}

- (IBAction)doSure:(id)sender {
    [_textFiled resignFirstResponder];
}

- (IBAction)doBecomeFirst:(id)sender {
    [_textFiled becomeFirstResponder];
}

- (IBAction)doSure2:(id)sender {
    [_textFiled2 resignFirstResponder];
}

- (IBAction)doBecomeFirst2:(id)sender {
    [_textFiled2 becomeFirstResponder];
}

@end
