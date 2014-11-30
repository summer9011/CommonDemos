//
//  CustomCache.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/7.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASICacheDelegate.h"

@interface CustomCache : NSObject <ASICacheDelegate> {
    
    ASICachePolicy defaultCachePolicy;
    
    NSString *storagePath;
    
    NSRecursiveLock *accessLock;
    
    BOOL shouldRespectCacheControlHeaders;
}

+ (id)sharedCache;

+ (BOOL)serverAllowsResponseCachingForRequest:(ASIHTTPRequest *)request;

+ (NSArray *)fileExtensionsToHandleAsHTML;

@property (assign, nonatomic) ASICachePolicy defaultCachePolicy;
@property (retain, nonatomic) NSString *storagePath;
@property (atomic, retain) NSRecursiveLock *accessLock;
@property (atomic, assign) BOOL shouldRespectCacheControlHeaders;

@end
