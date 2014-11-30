//
//  JCTiledViewController.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/12.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTiledScrollView.h"

@interface JCTiledViewController : UIViewController <JCTileSource,JCTiledScrollViewDelegate>

@property (strong, nonatomic) JCTiledScrollView *scrollView;

@end
