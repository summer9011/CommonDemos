//
//  CollectionCell.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/19.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "CollectionCell.h"

@implementation CollectionCell

//重写init
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CollectionCell" owner:self options:nil];
        if (arrayOfViews.count < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
