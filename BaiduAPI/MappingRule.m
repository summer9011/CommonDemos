//
//  MappingRule.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/10.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "MappingRule.h"
#import <CommonCrypto/CommonDigest.h>
#include "PrefixHeader.pch"

@implementation MappingRule

//判断缓存文件是否存在
-(BOOL)isCacheFileExistForURL:(NSURL *)url WithStoragePath:(NSString *)storagePath {
    //判断是否存在相应文件
    NSString *resourcePath=[self pathForCachedDataForURL:url WithStoragePath:storagePath];
    if (resourcePath) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        //资源文件存在
        BOOL isDir=NO;
        if([fileManager fileExistsAtPath:resourcePath isDirectory:&isDir]){
            return YES;
        }
    }
    return NO;
}

//获取缓存路径
-(NSString *)pathForCachedDataForURL:(NSURL *)url WithStoragePath:(NSString *)storagePath {
    NSString *str=[url absoluteString];
    if ([str containsString:API_DOMAIN]) {
        return [storagePath stringByAppendingPathComponent:@"c/d/road2.json"];
    }
    return nil;
}

//获取缓存数据
-(NSData *)cachedDataForURL:(NSURL *)url WithFilePath:(NSString *)path {
    //解析json文件
    NSData *jsonData=[[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    //分解URL
    NSString *urlString=[url absoluteString];
    NSArray *urlArr=[urlString componentsSeparatedByString:@"?"];
    NSString *mainUrl=[urlArr objectAtIndex:0];
    NSString *queryUrl=[mainUrl stringByReplacingOccurrencesOfString:API_DOMAIN withString:@""];
    
    //get参数
    NSString *paramUrl;
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    if ([urlArr count]==1) {
        NSLog(@"没有get参数");
        return nil;
    }else{
        paramUrl=[urlArr objectAtIndex:1];
        NSArray *paramArr=[paramUrl componentsSeparatedByString:@"&"];
        for (NSString *param in paramArr) {
            NSArray *paramKV=[param componentsSeparatedByString:@"="];
            //设置get参数至Dictionary
            if ([paramKV count]==2) {
                NSString *key=[paramKV objectAtIndex:0];
                NSString *val=[paramKV objectAtIndex:1];
                [params setObject:val forKey:key];
            }
        }
    }
    
    //根据不同规则读取不同数据
    if ([queryUrl isEqualToString:@"/dest"]) {
        NSArray *dests=[jsonDic objectForKey:@"dests"];
        for (NSDictionary *dest in dests) {
            if ([[dest objectForKey:@"destid"] intValue]==[[params objectForKey:@"destid"] intValue]) {
                return [NSKeyedArchiver archivedDataWithRootObject:dest];
            }
        }
    }
    if ([queryUrl isEqualToString:@"/memory/list"]) {
        NSArray *dests=[jsonDic objectForKey:@"dests"];
        for (NSDictionary *dest in dests) {
            if ([[dest objectForKey:@"destid"] intValue]==[[params objectForKey:@"destid"] intValue]) {
                return [NSKeyedArchiver archivedDataWithRootObject:[dest objectForKey:@"memorys"]];
            }
        }
    }
    if ([queryUrl isEqualToString:@"/memory"]) {
        NSArray *dests=[jsonDic objectForKey:@"dests"];
        for (NSDictionary *dest in dests) {
            if ([[dest objectForKey:@"memorys"] count]>0) {
                for (NSDictionary *memory in [dest objectForKey:@"memorys"]) {
                    if ([[memory objectForKey:@"memoryid"] intValue]==[[params objectForKey:@"memoryid"] intValue]) {
                        return [NSKeyedArchiver archivedDataWithRootObject:memory];
                    }
                }
            }
        }
    }
    
    return nil;
}

//获取图片路径(部分目录路径)
-(NSString *)imagePathForKey:(NSString *)key {
    NSString *filename;
    if([key isEqualToString:@"http://www.iyi8.com/uploadfile/2014/0821/20140821123403289.jpg"]){
        filename=@"a/b/a.jpg";
    }else{
        NSLog(@"重定义命名规则");
        
        const char *str = [key UTF8String];
        if (str == NULL) {
            str = "";
        }
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    }
    return filename;
}

//创建文件存储路径
-(BOOL)createStoragePath:(NSString *)path {
    //创建文件存储路径
    NSMutableArray *pathArr=(NSMutableArray *)[path componentsSeparatedByString:@"/"];
    [pathArr removeLastObject];
    NSString *pathWithoutName=[pathArr componentsJoinedByString:@"/"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    //资源文件存在
    BOOL isDir=YES;
    if(![fileManager fileExistsAtPath:pathWithoutName isDirectory:&isDir]){
        BOOL isCreate=[fileManager createDirectoryAtPath:pathWithoutName withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreate) {
            return NO;
        }
    }
    return YES;
}

@end
