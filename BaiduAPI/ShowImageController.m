//
//  ShowImageController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/19.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "ShowImageController.h"
#import "CollectionCell.h"
#import "HandleController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ShowImageController ()

@property (strong, nonatomic) IBOutlet UICollectionView *collection;
@property(nonatomic,assign)float width;
@property(nonatomic,retain)NSMutableArray *photoArr;
@property(nonatomic,retain)ALAssetsLibrary *library;
@property(nonatomic,retain)UIImagePickerController *imgPicker;

@end

@implementation ShowImageController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
    
    CGRect r=[UIScreen mainScreen].bounds;
    float w=r.size.width;
    _width=(w-3*2)/4.0f;
    //设置导航的view
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 64)];
    view.backgroundColor=[UIColor whiteColor];
    //导航上的返回按钮
    UIButton *back=[UIButton buttonWithType:UIButtonTypeSystem];
    back.frame=CGRectMake(10, 20, 44, 44);
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:back];
    //导航上的下一步按钮
    UIButton *done=[UIButton buttonWithType:UIButtonTypeSystem];
    done.frame=CGRectMake(r.size.width-10-64, 20, 64, 44);
    [done setTitle:@"下一步" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneToGoHead) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:done];
    
    [self.view addSubview:view];
    
    //获取图片
    _photoArr=[[NSMutableArray alloc] init];
    _library=[[ALAssetsLibrary alloc] init];
    [self getPhotos];
    
    _collection.frame=CGRectMake(r.origin.x, r.origin.y+64, r.size.width, r.size.height-64);
    
    _imgPicker=[[UIImagePickerController alloc] init];
    _imgPicker.delegate=(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    
    //注册cell
    [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)backToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneToGoHead {
    NSLog(@"选中图片下一步操作");
}

-(void)getPhotos {
    [_photoArr removeAllObjects];
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group!=nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [_photoArr addObject:result.defaultRepresentation.url];
                }
            }];
        }
        [_collection reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"enumerateGroupsWithTypes error %@",error);
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photoArr count]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if ((int)indexPath.row==0) {        //拍照
        cell.imageView.image=[UIImage imageNamed:@"camera"];
    }else{
        [_library assetForURL:[_photoArr objectAtIndex:indexPath.row-1] resultBlock:^(ALAsset *asset) {
            cell.imageView.image=[UIImage imageWithCGImage:asset.thumbnail];
        } failureBlock:^(NSError *error) {
            NSLog(@"assetForURL error %@",error);
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_width,_width);
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ((int)indexPath.row==0) {        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            _imgPicker.showsCameraControls=NO;
            _imgPicker.cameraOverlayView=[self CustomImagePickerView];
            [self presentViewController:_imgPicker animated:YES completion:nil];
        }else{
            NSLog(@"无法使用相机");
        }
    }else{
        //进入到图片处理页
        [self gotoImageHandle:[_photoArr objectAtIndex:indexPath.row-1]];
    }
    
    return YES;
}

-(void)gotoImageHandle:(NSURL *)url {
    //进入到图片处理页
    [_library assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation=[asset defaultRepresentation];
        UIImage *image=[UIImage imageWithCGImage:representation.fullScreenImage];
        
        HandleController *handle=[[HandleController alloc] initWithNibName:@"HandleController" bundle:nil];
        handle.image=image;
        [self.navigationController pushViewController:handle animated:YES];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"goto HandleVC assetForURL error %@",error);
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //拍照
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
        UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
        NSMutableDictionary *metaData=[info objectForKey:UIImagePickerControllerMediaMetadata];
        
        //保存相片到相册
        [_library writeImageToSavedPhotosAlbum:image.CGImage metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
            //进入到图片处理页
            [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation=[asset defaultRepresentation];
                UIImage *image=[UIImage imageWithCGImage:representation.fullScreenImage];
                
                HandleController *handle=[[HandleController alloc] initWithNibName:@"HandleController" bundle:nil];
                handle.image=image;
                [self.navigationController pushViewController:handle animated:YES];
                
                [_imgPicker dismissViewControllerAnimated:NO completion:nil];
                
            } failureBlock:^(NSError *error) {
                NSLog(@"goto HandleVC assetForURL error %@",error);
            }];
        }];
    }
}

//自定义拍照的页面
-(UIView *)CustomImagePickerView {
    //自定义的拍照View
    UIView *view=[[UIView alloc] init];
    view.frame=self.view.bounds;
    view.backgroundColor=[UIColor clearColor];
    //拍照
    UIButton *takePic=[UIButton buttonWithType:UIButtonTypeSystem];
    takePic.frame=CGRectMake(self.view.bounds.size.width/2-40, self.view.bounds.size.height-40+10, 80, 40);
    [takePic setTitle:@"拍照" forState:UIControlStateNormal];
    [takePic addTarget:self action:@selector(doTakePicture) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:takePic];
    //返回
    UIButton *goBack=[UIButton buttonWithType:UIButtonTypeSystem];
    goBack.frame=CGRectMake(10, self.view.bounds.size.height-40+10, 80, 40);
    [goBack setTitle:@"返回" forState:UIControlStateNormal];
    [goBack addTarget:self action:@selector(goBackPicList) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:goBack];
    
    return view;
}

//拍照
-(void)doTakePicture {
    [_imgPicker takePicture];
}

//返回
-(void)goBackPicList {
    //重新加载图片列表
    [self getPhotos];
    [_imgPicker dismissViewControllerAnimated:YES completion:nil];
}


@end
