//
//  EXIFViewController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/14.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "EXIFViewController.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@interface EXIFViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic,retain)UIImagePickerController *imgPicker;
@property (nonatomic,retain)CLLocationManager *locationManager;
@property (nonatomic,retain)CLLocation *location;

@end

@implementation EXIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imgPicker=[[UIImagePickerController alloc] init];
    _imgPicker.delegate=(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=(id<CLLocationManagerDelegate>)self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//开始拍照
- (IBAction)takePhoto:(id)sender {
    //更新当前地理位置
    [_locationManager startUpdatingLocation];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imgPicker animated:YES completion:^{
            NSLog(@"进入拍照");
        }];
    }else{
        NSLog(@"无法使用相机");
    }
    
    NSLog(@"close location");
}

//获取图片属性
- (IBAction)getProperties:(id)sender {
    _imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imgPicker animated:YES completion:^{
        NSLog(@"获取图片");
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //关闭更新位置
    [_locationManager stopUpdatingLocation];
    
    if (picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary) {         //从相册中获取
        NSURL *assetURL=[info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *representation=[asset defaultRepresentation];
            NSLog(@"representation %@",[representation metadata]);
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"gps" message:[NSString stringWithFormat:@"%@",[[representation metadata] objectForKey:(NSString *)kCGImagePropertyGPSDictionary]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            
            UIAlertView *alert2=[[UIAlertView alloc] initWithTitle:@"tiff" message:[NSString stringWithFormat:@"%@",[[representation metadata] objectForKey:(NSString *)kCGImagePropertyTIFFDictionary]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert2 show];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"error %@",error);
        }];
    }else if (picker.sourceType==UIImagePickerControllerSourceTypeCamera){          //拍照保存到相册
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //图片
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        //图片属性
        NSMutableDictionary *metaData=[info objectForKey:UIImagePickerControllerMediaMetadata];
        
        //设置GPS信息
        if (_location) {
            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [formatter setDateFormat:@"HH:mm:ss.SS"];
            
            NSDictionary *GPS=@{
                                (NSString *)kCGImagePropertyGPSAltitude:[NSNumber numberWithDouble:_location.altitude],
                                (NSString *)kCGImagePropertyGPSAltitudeRef:@"0",
                                (NSString *)kCGImagePropertyGPSLatitude:[NSNumber numberWithDouble:_location.coordinate.latitude],
                                (NSString *)kCGImagePropertyGPSLatitudeRef:(_location.coordinate.latitude>=0?@"N":@"S"),
                                (NSString *)kCGImagePropertyGPSLongitude:[NSNumber numberWithDouble:_location.coordinate.longitude],
                                (NSString *)kCGImagePropertyGPSLongitudeRef:(_location.coordinate.longitude >= 0?@"E":@"W"),
                                (NSString *)kCGImagePropertyGPSTimeStamp:[formatter stringFromDate:[_location timestamp]]
                                };
            [metaData setObject:GPS forKey:(NSString *)kCGImagePropertyGPSDictionary];
            NSLog(@"metaData %@",GPS);
        }
        
        //保存相片到相册 注意:必须使用[image CGImage]不能使用强制转换: (__bridge CGImageRef)image,否则保存照片将会报错
        [library writeImageToSavedPhotosAlbum:image.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
            } else {
                NSLog(@"Success");
            }
        }];
        
        //压缩图片后并保存到相册
        UIImage *resizeImage=[self imageWithImage:image scaledToSize:CGSizeMake(300,300)];
        [library writeImageToSavedPhotosAlbum:resizeImage.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
            } else {
                NSLog(@"resizeImg Success");
            }
        }];
        
        //退出
        [picker dismissViewControllerAnimated:YES completion:^{
            _imgView.image=resizeImage;
            NSLog(@"退出拍照");
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //关闭更新位置
    [_locationManager stopUpdatingLocation];
    //退出
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"退出");
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _location = [locations lastObject];
    NSLog(@"location %@",[locations lastObject]);
}

//压缩图片
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
//设置图片附加信息
-(NSData *)saveImageWithImageData:(NSData *)data Properties:(NSDictionary *)properties {
    
    NSMutableDictionary *dataDic=[NSMutableDictionary dictionaryWithDictionary:properties];
    //修改图片Orientation
    dataDic[(NSString *)kCGImagePropertyOrientation]=[NSNumber numberWithInt:kCGImagePropertyOrientationUp];
    
    //设置properties属性
    CGImageSourceRef imageRef =CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CFStringRef uti=CGImageSourceGetType(imageRef);
    
    NSMutableData *data1=[NSMutableData data];
    CGImageDestinationRef destination=CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data1, uti, 1, NULL);
    if (!destination) {
        NSLog(@"error");
        return nil;
    }
    
    CGImageDestinationAddImageFromSource(destination, imageRef, 0, (__bridge CFDictionaryRef)dataDic);
    BOOL check=CGImageDestinationFinalize(destination);
    if (!check) {
        NSLog(@"error");
        return nil;
    }
    CFRelease(destination);
    CFRelease(uti);
    
    return data1;
}
 */

@end
