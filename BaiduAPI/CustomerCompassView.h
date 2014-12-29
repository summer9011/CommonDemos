//
//  CompassView.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/28.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CompassDelegate <NSObject>

@required
-(void)didClickOnOneCompass:(NSDictionary *)destination;

@optional
-(void)didShowCompassView;

-(void)didHiddenCompassView;

-(void)didReloadCompassView;

-(void)didTapOnCompassView;

@end

@interface CustomerCompassView : UIView

@property (nonatomic,strong) id<CompassDelegate> compassDelegate;

-(id)initWithFrame:(CGRect)frame Center:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr;

-(void)setCenter:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr;

-(void)show;

-(void)hidden;

-(void)reload;

@end
