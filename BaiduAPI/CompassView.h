//
//  CompassView.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/12/28.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompassView : UIView

-(id)initWithFrame:(CGRect)frame Center:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr;

-(void)setCenter:(NSDictionary *)center DestinationArray:(NSArray *) destinationArr;

-(void)show;

-(void)hidden;

-(void)reload;

@end
