//
//  MappingRule.h
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/10.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MappingRule : NSObject

//判断缓存文件是否存在
-(BOOL)isCacheFileExistForURL:(NSURL *)url WithStoragePath:(NSString *)storagePath;

//获取缓存路径
-(NSString *)pathForCachedDataForURL:(NSURL *)url WithStoragePath:(NSString *)storagePath;

//获取缓存数据
-(NSData *)cachedDataForURL:(NSURL *)url WithFilePath:(NSString *)path;

//获取图片路径(部分目录路径)
-(NSString *)imagePathForKey:(NSString *)key;

//创建文件存储路径
-(BOOL)createStoragePath:(NSString *)path;

@end
