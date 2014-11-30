//
//  CustomMapController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/10.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CustomMapController.h"

@interface CustomMapController ()

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) UIView *myView;
@property (retain, nonatomic) NSArray *levelArr;
@property (assign, nonatomic) CGFloat prevScale;

@end

const CGSize viewSize={1280,1280};
const UIEdgeInsets Inset={0,0,0,0};

const float minZoom=0.3f;
const float maxZoom=2.5f;

const float cut1=0.6f;
const float cut2=1.3f;

@implementation CustomMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置缩放级别对应的图片数
    NSDictionary *dic1=[[NSDictionary alloc] initWithObjectsAndKeys:@"5",@"x",@"5",@"y", nil];
    NSDictionary *dic2=[[NSDictionary alloc] initWithObjectsAndKeys:@"10",@"x",@"10",@"y", nil];
    NSDictionary *dic3=[[NSDictionary alloc] initWithObjectsAndKeys:@"20",@"x",@"20",@"y", nil];
    _levelArr=[[NSArray alloc] initWithObjects:dic1,dic2,dic3, nil];
    
    //UIView
    _myView=[[UIView alloc] init];
    _myView.tag=1;
    _myView.frame=CGRectMake(0, 0, viewSize.width, viewSize.height);
    [self addMapOnView:_myView WithLevel:1 AndScale:1.0f];
    [_scrollView addSubview:_myView];
    _scrollView.backgroundColor=[UIColor lightGrayColor];
    _scrollView.minimumZoomScale=minZoom;
    _scrollView.maximumZoomScale=maxZoom;
    _prevScale=_scrollView.zoomScale=minZoom;
    [self resetScrollViewContent:_scrollView WithView:_myView];
    _scrollView.contentInset=Inset;
    _scrollView.contentOffset=CGPointMake(-(self.view.bounds.size.width-_myView.frame.size.width)/2,0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//添加地图到View上
-(void)addMapOnView:(UIView *)view WithLevel:(int)level AndScale:(float)scale {
    NSDictionary *levelNum=[_levelArr objectAtIndex:level-1];
    int levelX=[[levelNum objectForKey:@"x"] intValue];
    int levelY=[[levelNum objectForKey:@"y"] intValue];
    
    float pieceSize=viewSize.height/levelY;
    for (int y=0; y<levelY; y++) {
        for (int x=0; x<levelX; x++) {
            UIImageView *imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.%d.%d",level,x,y]]];
            imgView.frame=CGRectMake(x*pieceSize, y*pieceSize, pieceSize, pieceSize);
            [view addSubview:imgView];
        }
    }
}

//重新设置scrollview的contentSize,contentOffset
-(void)resetScrollViewContent:(UIScrollView *)scrollView WithView:(UIView *)view {
    scrollView.contentSize=CGSizeMake(view.frame.size.width, view.frame.size.height);
}

/*============================================     scrollView任意变化调用     ==============================================*/

//任何offset变化均调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f",scrollView.zoomScale);
}

/*============================================     UIView缩放     ==============================================*/

//缩放变化
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    float scale=scrollView.zoomScale;
    UIView *view=[scrollView viewWithTag:1];
//    NSLog(@"结束缩放 %f",scale);
    
    //判断缩放前的scale与缩放后的scale是否在同一个缩放区间
    BOOL needScale=NO;
    if (_prevScale<=cut1&&scale<=cut1) {
        needScale=NO;
    }else if((_prevScale>cut1&&_prevScale<=cut2)&&(scale>cut1&&scale<=cut2)){
        needScale=NO;
    }else if ((_prevScale>cut2&&_prevScale<=maxZoom)&&(scale>cut2&&scale<=maxZoom)){
        needScale=NO;
    }else {
        needScale=YES;
    }
    
    if (needScale) {
        //释放view里面的所有imageView
        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (scale<=cut1) {
            [self addMapOnView:view WithLevel:1 AndScale:scale];
        }else if (scale<=cut2){
            [self addMapOnView:view WithLevel:2 AndScale:scale];
        }else {
            [self addMapOnView:view WithLevel:3 AndScale:scale];
        }
    }
    
    [self resetScrollViewContent:scrollView WithView:view];
    _prevScale=scale;
}

//设置要缩放的UIView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _myView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
}

//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    NSLog(@"结束缩放 %f",scale);
//    
//    //判断缩放前的scale与缩放后的scale是否在同一个缩放区间
//    BOOL needScale=NO;
//    if (_prevScale<=cut1&&scale<=cut1) {
//        needScale=NO;
//    }else if((_prevScale>cut1&&_prevScale<=cut2)&&(scale>cut1&&scale<=cut2)){
//        needScale=NO;
//    }else if ((_prevScale>cut2&&_prevScale<=maxZoom)&&(scale>cut2&&scale<=maxZoom)){
//        needScale=NO;
//    }else {
//        needScale=YES;
//    }
//    
//    if (needScale) {
//        //释放view里面的所有imageView
//        [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        if (scale<=cut1) {
//            [self addMapOnView:view WithLevel:1 AndScale:scale];
//        }else if (scale<=cut2){
//            [self addMapOnView:view WithLevel:2 AndScale:scale];
//        }else {
//            [self addMapOnView:view WithLevel:3 AndScale:scale];
//        }
//    }
//    
//    [self resetScrollViewContent:scrollView WithView:view];
//    _prevScale=scale;
}


/*============================================     UIView拖动     ==============================================*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"将要开始拖动");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"%f,%f",targetContentOffset->x,targetContentOffset->y);
//    
//    UIView *view=[scrollView viewWithTag:1];
//    NSLog(@"%f,%f",view.frame.size.width,view.frame.size.height);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"结束拖动");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"将要开始减速");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"结束减速");
}


@end
