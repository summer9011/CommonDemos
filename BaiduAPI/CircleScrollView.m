//
//  CircleScrollView.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CircleScrollView.h"

typedef NS_ENUM(int, PagePosition){
    PageLeft,
    PageCenter,
    PageRight
};

@interface CircleScrollView () {
    BOOL doubleClickZoom;
    CGSize size;
}

@end

@implementation CircleScrollView

-(id)initWithFrame:(CGRect)frame ImageArray:(NSArray *)imageArr CurrentIndex:(int)index {
    self=[super initWithFrame:frame];
    if (self) {
        self.imageArr=(NSMutableArray *)imageArr;
        self.currentIndex=index;
        doubleClickZoom=NO;
        size=self.frame.size;
        [self initSelfScroll];
        [self initScrollViews];
    }
    return self;
}

-(void)initSelfScroll {
    //单击显示隐藏顶部和底部
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleClick:)];
    [singleTap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTap];
    
    //双击放大缩小centerScroll
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    
    //监测是否为双击，
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    self.pagingEnabled=YES;
    self.contentSize=CGSizeMake(size.width*3, size.height);
    self.contentOffset=CGPointMake(size.width, 0);
    
    self.delegate=(id<UIScrollViewDelegate>)self;
}

-(void)initScrollViews {
    CGRect imgRect=CGRectMake(0, 0, size.width, size.height);
    UIImageView *leftImg=[[UIImageView alloc] initWithFrame:imgRect];
    UIImageView *centerImg=[[UIImageView alloc] initWithFrame:imgRect];
    UIImageView *rightImg=[[UIImageView alloc] initWithFrame:imgRect];
    
    self.leftScroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.centerScroll=[[UIScrollView alloc] initWithFrame:CGRectMake(size.width, 0, size.width, size.height)];
    self.rightScroll=[[UIScrollView alloc] initWithFrame:CGRectMake(size.width*2, 0, size.width, size.height)];
    
    self.leftScroll.minimumZoomScale=1.0f;
    self.leftScroll.maximumZoomScale=2.0f;
    self.leftScroll.delegate=(id<UIScrollViewDelegate>)self;
    
    self.centerScroll.minimumZoomScale=1.0f;
    self.centerScroll.maximumZoomScale=2.0f;
    self.centerScroll.delegate=(id<UIScrollViewDelegate>)self;
    
    self.rightScroll.minimumZoomScale=1.0f;
    self.rightScroll.maximumZoomScale=2.0f;
    self.rightScroll.delegate=(id<UIScrollViewDelegate>)self;
    
    [self.leftScroll addSubview:leftImg];
    [self.centerScroll addSubview:centerImg];
    [self.rightScroll addSubview:rightImg];
    
    [self addSubview:self.leftScroll];
    [self addSubview:self.centerScroll];
    [self addSubview:self.rightScroll];
    
    //初始化当前的
    [self setImageViewContent:leftImg And:centerImg And:rightImg];
}

//设置leftScroll,centerScroll,rightScroll的UIImageView
-(void)setImageViewContent:(UIImageView *)leftView And:(UIImageView *)centerView And:(UIImageView *)rightView {
    int left,center,right;
    if (self.currentIndex<=0) {
        left=self.currentIndex;
        center=self.currentIndex+1;
        right=self.currentIndex+2;
    }else if (self.currentIndex>=self.imageArr.count-1){
        left=self.imageArr.count-3;
        center=self.imageArr.count-2;
        right=self.imageArr.count-1;
    }else{
        left=self.currentIndex-1;
        center=self.currentIndex;
        right=self.currentIndex+1;
    }
    
    leftView.image=[UIImage imageNamed:self.imageArr[left]];
    leftView.contentMode=UIViewContentModeScaleAspectFit;
    
    centerView.image=[UIImage imageNamed:self.imageArr[center]];
    centerView.contentMode=UIViewContentModeScaleAspectFit;
    
    rightView.image=[UIImage imageNamed:self.imageArr[right]];
    rightView.contentMode=UIViewContentModeScaleAspectFit;
}

//单击显示与隐藏头部和底部的view
-(void)singleClick:(UITapGestureRecognizer *)recognizer {
    [self.circleDelegate didSingleTapOnCircleScroll:recognizer];
}

//双击放大图片
-(void)doubleClick:(UITapGestureRecognizer *)recognizer {
    [self.circleDelegate didDoubleTapOnCircleScroll:recognizer];
    if (doubleClickZoom) {
        doubleClickZoom=NO;
        if (self.currentIndex==0) {
            [self.leftScroll setZoomScale:1.f animated:YES];
        }else if (self.currentIndex==self.imageArr.count-1){
            [self.rightScroll setZoomScale:1.f animated:YES];
        }else{
            [self.centerScroll setZoomScale:1.f animated:YES];
        }
    }else{
        doubleClickZoom=YES;
        if (self.currentIndex==0) {
            [self.leftScroll setZoomScale:2.f animated:YES];
        }else if (self.currentIndex==self.imageArr.count-1){
            [self.rightScroll setZoomScale:2.f animated:YES];
        }else{
            [self.centerScroll setZoomScale:2.f animated:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self]) {
        self.contentInset=UIEdgeInsetsZero;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self]) {
        self.leftScroll.zoomScale=1.f;
        self.centerScroll.zoomScale=1.f;
        self.rightScroll.zoomScale=1.f;
        int page=floorf(scrollView.contentOffset.x/size.width);
        
        CGPoint p;
        switch (page) {
            case 0:
                [self moveScrollView:PageLeft];
                if (self.currentIndex<=0) {
                    p=CGPointZero;
                }else{
                    p=CGPointMake(size.width, 0);
                }
                scrollView.contentOffset=p;
                break;
            case 1:
                if (self.currentIndex==0) {
                    [self moveScrollView:PageRight];
                }else if (self.currentIndex==self.imageArr.count-1){
                    [self moveScrollView:PageLeft];
                }
                break;
            case 2:
                [self moveScrollView:PageRight];
                if (self.currentIndex>=self.imageArr.count-1) {
                    p=CGPointMake(size.width*2, 0);
                }else{
                    p=CGPointMake(size.width, 0);
                }
                scrollView.contentOffset=p;
                break;
        }
        [self.circleDelegate didScrollWithCurrentIndex:self.currentIndex];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (![scrollView isEqual:self]) {
        scrollView.contentInset=UIEdgeInsetsZero;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView.subviews[0];
}

//移动scrollView
-(void)moveScrollView:(PagePosition) positon {
    switch (positon) {
        case PageLeft:             //向左移动scrollView
            if (self.currentIndex>0) {
                self.currentIndex--;
            }
            break;
        case PageRight:            //向右移动scrollView
            if (self.currentIndex<self.imageArr.count-1) {
                self.currentIndex++;
            }
            break;
        case PageCenter:
            break;
    }
    
    if (self.currentIndex==self.imageArr.count-1) {
        [self loadMoreMemory];
    }else{
        [self resetScrollViews];
    }
}

-(void)resetScrollViews {
    UIImageView *leftImg=self.leftScroll.subviews[0];
    UIImageView *centerImg=self.centerScroll.subviews[0];
    UIImageView *rightImg=self.rightScroll.subviews[0];
    
    //重新生成数据
    [self setImageViewContent:leftImg And:centerImg And:rightImg];
}

//加载更多留念
-(void)loadMoreMemory {
    [self.circleDelegate willAppendMoreImage:self];
    
    [self resetScrollViews];
    self.contentOffset=CGPointMake(size.width, 0);
}

@end
