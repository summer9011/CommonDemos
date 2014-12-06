//
//  CircleScrollView.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleScrollView;
@protocol CircleScrollViewDelegate <NSObject>

//单击circleScroll
-(void)didSingleTapOnCircleScroll:(UITapGestureRecognizer *)recognizer;
//双击circleScroll
-(void)didDoubleTapOnCircleScroll:(UITapGestureRecognizer *)recognizer;
//完成切换
-(void)didScrollWithCurrentIndex:(int)index;
//加载更多图片
-(void)willAppendMoreImage:(CircleScrollView *)cicleScrollView;

@end

@interface CircleScrollView : UIScrollView

@property(nonatomic,strong)NSMutableArray *imageArr;                       //图片数组
@property(nonatomic,assign)int currentIndex;                        //当前图片的下标

@property(nonatomic,strong)UIScrollView *leftScroll;                //左边的scroll
@property(nonatomic,strong)UIScrollView *centerScroll;              //中间的scroll
@property(nonatomic,strong)UIScrollView *rightScroll;               //右边的scroll

@property(nonatomic,strong)id<CircleScrollViewDelegate> circleDelegate;

-(id)initWithFrame:(CGRect)frame ImageArray:(NSArray *)imageArr CurrentIndex:(int)index;

@end
