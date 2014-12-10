//
//  CustomASIDownloadCache.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/6.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASICacheDelegate.h"

@interface CustomASIDownloadCache : NSObject <ASICacheDelegate> {
        // The default cache policy for this cache
        // Requests that store data in the cache will use this cache policy if their cache policy is set to ASIUseDefaultCachePolicy
        // Defaults to ASIAskServerIfModifiedWhenStaleCachePolicy
        ASICachePolicy defaultCachePolicy;

        // The directory in which cached data will be stored
        // Defaults to a directory called 'ASIHTTPRequestCache' in the temporary directory
        NSString *storagePath;

        // Mediates access to the cache
        NSRecursiveLock *accessLock;

        // When YES, the cache will look for cache-control / pragma: no-cache headers, and won't reuse store responses if it finds them
        BOOL shouldRespectCacheControlHeaders;
}

// Returns a static instance of an ASIDownloadCache
// In most circumstances, it will make sense to use this as a global cache, rather than creating your own cache
// To make ASIHTTPRequests use it automatically, use [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
+ (id)sharedCache;

// A helper function that determines if the server has requested data should not be cached by looking at the request's response headers
+ (BOOL)serverAllowsResponseCachingForRequest:(ASIHTTPRequest *)request;

// A list of file extensions that we know won't be readable by a webview when accessed locally
// If we're asking for a path to cache a particular url and it has one of these extensions, we change it to '.html'
+ (NSArray *)fileExtensionsToHandleAsHTML;

@property (assign, nonatomic) ASICachePolicy defaultCachePolicy;
@property (retain, nonatomic) NSString *storagePath;
@property (atomic, retain) NSRecursiveLock *accessLock;
@property (atomic, assign) BOOL shouldRespectCacheControlHeaders;

#pragma mark - 自定义的缓存路径及名字

//自定义的文件名(exp: a.exe 或者 home/example/file.exe)  默认值: 固定字符串-当前年月日 (exp: file-201411061426)
@property (nonatomic,retain,readonly) NSString *customFileName;

@end
