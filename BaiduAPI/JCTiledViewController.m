//
//  JCTiledViewController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/12.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "JCTiledViewController.h"
#import "JCTiledView.h"

#define viewSize CGSizeMake(1280,1280)
//#define viewSize CGSizeMake(1024,512)

@interface JCTiledViewController ()

@end

@implementation JCTiledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor lightGrayColor];
    
    CGRect r=self.view.bounds;
    self.scrollView=[[JCTiledScrollView alloc] initWithFrame:r contentSize:viewSize];     //retainCount  2
    self.scrollView.dataSource=self;
    self.scrollView.tiledScrollViewDelegate=self;
    self.scrollView.zoomScale=1.0f;
    
    //设置可缩放的层级数(2=>可缩放2级)
    self.scrollView.levelsOfZoom=2;
    
    //设置可调用图片的层级数(3级level=>2)
    self.scrollView.levelsOfDetail=2;
    
    //显示块分割线
    self.scrollView.tiledView.shouldAnnotateRect=NO;
    
    [self.view addSubview:self.scrollView];
    
    [self tiledScrollViewDidZoom:self.scrollView];
    
    
//    CGRect r=self.view.bounds;
//    _scrollView=[[JCTiledScrollView alloc] initWithFrame:r contentSize:viewSize];       //retainCount  1
//    _scrollView.dataSource=self;
//    _scrollView.tiledScrollViewDelegate=self;
//    _scrollView.zoomScale=1.0f;
//    
//    //设置可缩放的层级数(2=>可缩放2级)
//    _scrollView.levelsOfZoom=2;
//    
//    //设置可调用图片的层级数(3级level=>2)
//    _scrollView.levelsOfDetail=2;
//    
//    //显示块分割线
//    _scrollView.tiledView.shouldAnnotateRect=NO;
//    
//    [self.view addSubview:_scrollView];
//    
//    [self tiledScrollViewDidZoom:_scrollView];
}

- (void)viewDidUnload {
    _scrollView = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.scrollView refreshAnnotations];
//    [_scrollView refreshAnnotations];
    
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"in");
    
    _scrollView = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>6.0) {
        if (self.isViewLoaded&&!self.view.window) {
            NSLog(@"clear");
            self.view=nil;
        }
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [self.scrollView removeAllAnnotations];
    }
}

#pragma mark - JCTiledScrollViewDelegate

- (void)tiledScrollViewDidZoom:(JCTiledScrollView *)scrollView
{
//    NSLog(@"正在缩放");
}

- (void)tiledScrollView:(JCTiledScrollView *)scrollView didReceiveSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
//    CGPoint tapPoint = [gestureRecognizer locationInView:(UIView *)scrollView.tiledView];
//    NSLog(@"单击%f,%f移到中心",tapPoint.x,tapPoint.y);
}

- (JCAnnotationView *)tiledScrollView:(JCTiledScrollView *)scrollView viewForAnnotation:(id<JCAnnotation>)annotation
{
//    NSLog(@"tiledScrollView:viewForAnnotation:");
    
//    NSString static *reuseIdentifier = @"JCAnnotationReuseIdentifier";
//    DemoAnnotationView *view = (DemoAnnotationView *)[scrollView dequeueReusableAnnotationViewWithReuseIdentifier:reuseIdentifier];
//    
//    if (!view)
//    {
//        view = [[DemoAnnotationView alloc] initWithFrame:CGRectZero annotation:annotation reuseIdentifier:@"Identifier"];
//        view.imageView.image = [UIImage imageNamed:@"marker-red.png"];
//        [view sizeToFit];
//    }
//    
//    return view;
    
    return nil;
}

#pragma mark - JCTileSource

- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
//    NSLog(@"在 level %d, x %d, y %d上增加图片",scale, column, row);
    if (scale==1) {
        scale=1;
    }
    if (scale==2) {
        scale=2;
    }
    if (scale==4) {
        scale=3;
    }
    
    NSURL *imgUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/map2/%d.%d.%d.png",scale, column, row]];
    return [UIImage imageWithData: [NSData dataWithContentsOfURL:imgUrl]];
    
//    NSString *str=[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.%d.%d.png",scale, column, row]];
//    return [UIImage imageWithContentsOfFile:str];
}

@end
