//
//  HandleController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/19.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "HandleController.h"
#import "PublishController.h"
//滤镜
#import "GPUImage.h"
#import "GrayscaleContrastFilter.h"
//裁剪
#import "NLCropViewLayer.h"

#define TOP_NAVI_HEIGHT 64
#define TAB_BAR_HEIGHT 60
#define EFFECT_IMAGE_SIZE 40
#define EFFECT_IMAGE_OFFSET 10

#define MIN_IMG_SIZE 30
#define IMAGE_BOUNDRY_SPACE 10
enum rectPoint {LeftTop = 0, RightTop=1, LeftBottom = 2, RightBottom = 3, MoveCenter = 4, NoPoint = 1};
@interface HandleController () {
    NLCropViewLayer* _cropView;
    enum rectPoint _movePoint;
    CGRect _cropRect;
    CGRect _translatedCropRect;
    CGPoint _lastMovePoint;
    CGPoint _coordinateOffset;      //2个坐标系之间的原点的差值
    CGFloat _imgScale;
    int currentColorMatrix;         //当前滤镜效果
    
    GPUImageOutput<GPUImageInput> *filter;
    GPUImagePicture *staticPicture;
}

@property(nonatomic,assign)CGSize imageScrollSize;
@property(nonatomic,assign)CGRect resizeImageRect;
@property(nonatomic,assign)int transform;

@property(nonatomic,strong)GPUImageView *imageView;                  //编辑图ImageView
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroll;     //展现图片的scrollView
@property (weak, nonatomic) IBOutlet UIScrollView *effectScroll;    //展现效果的scrollView

@end

@implementation HandleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    self.navigationController.navigationBarHidden=YES;
    
    //设置图像效果列表
    _effectScroll.contentSize=CGSizeMake((EFFECT_IMAGE_SIZE+EFFECT_IMAGE_OFFSET)*(12)+EFFECT_IMAGE_OFFSET, _effectScroll.frame.size.height);
    _effectScroll.backgroundColor=[UIColor colorWithWhite:0.3f alpha:0.3f];
    
    //设置旋转按钮
    UIButton *ronationBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    ronationBtn.frame=CGRectMake(EFFECT_IMAGE_OFFSET, EFFECT_IMAGE_OFFSET+2.5, EFFECT_IMAGE_SIZE-5, EFFECT_IMAGE_SIZE-5);
    [ronationBtn setBackgroundImage:[UIImage imageNamed:@"rotation"] forState:UIControlStateNormal];
    [ronationBtn addTarget:self action:@selector(doRonation) forControlEvents:UIControlEventTouchUpInside];
    [_effectScroll addSubview:ronationBtn];
    
    //设置裁剪按钮
    UIButton *cutBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    cutBtn.tag=200;
    cutBtn.frame=CGRectMake(EFFECT_IMAGE_OFFSET+(EFFECT_IMAGE_SIZE+EFFECT_IMAGE_OFFSET), EFFECT_IMAGE_OFFSET+2.5, EFFECT_IMAGE_SIZE-5, EFFECT_IMAGE_SIZE-5);
    [cutBtn setBackgroundImage:[UIImage imageNamed:@"cut"] forState:UIControlStateNormal];
    [cutBtn addTarget:self action:@selector(doCutImage) forControlEvents:UIControlEventTouchUpInside];
    [_effectScroll addSubview:cutBtn];
    
    //图片效果按钮
    for (int i=0; i<10; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame=CGRectMake(EFFECT_IMAGE_OFFSET+(EFFECT_IMAGE_SIZE+EFFECT_IMAGE_OFFSET)*(i+2), EFFECT_IMAGE_OFFSET, EFFECT_IMAGE_SIZE, EFFECT_IMAGE_SIZE);
        [btn.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [btn.layer setBorderWidth:2.0];
        [btn.layer setCornerRadius:5.0];
        [btn.layer setMasksToBounds:YES];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i+1]] forState:UIControlStateNormal];
        btn.tag=100+i;
        [btn addTarget:self action:@selector(doChangeImageStyle:) forControlEvents:UIControlEventTouchUpInside];
        [_effectScroll addSubview:btn];
    }
    
    _imageScrollSize=CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-TOP_NAVI_HEIGHT-TAB_BAR_HEIGHT);
    
    //图片效果处理类
    filter=[[GPUImageRGBFilter alloc] init];
    _imageView=[[GPUImageView alloc] init];
    
//    _image=image;
    currentColorMatrix=-1;
    _transform=1;
    
    [self initStaticPicture];
    
    //设置2个坐标系之间的距离
    _coordinateOffset=_resizeImageRect.origin;
    
    _imageScroll.minimumZoomScale=1.0f;
    _imageScroll.maximumZoomScale=2.0f;
    [_imageScroll addSubview:_imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
-(void)setHandleControllerImage:(UIImage *)image {
    _image=image;
    currentColorMatrix=-1;
    _transform=1;
    
    [self initStaticPicture];
    
    //设置2个坐标系之间的距离
    _coordinateOffset=_resizeImageRect.origin;
}
*/

-(void)initStaticPicture {
    [self resizeImageScroll:_image];
    
    staticPicture = [[GPUImagePicture alloc] initWithImage:_image smoothlyScaleOutput:YES];
    [self setFilter:currentColorMatrix];
    [staticPicture addTarget:filter];
    [filter addTarget:_imageView];
    [staticPicture processImage];
}

//设置图片效果
-(void)doChangeImageStyle:(id)sender {
    UIButton *button=(UIButton *)sender;
    
    [self removeAllTargets];
    
    [self setFilter:(int)button.tag];
    currentColorMatrix=(int)button.tag;
    
    [staticPicture addTarget:filter];
    [filter addTarget:_imageView];
    [staticPicture processImage];
}

//设置当前过滤项
-(void) setFilter:(int) index {
    switch (index) {
        case 101:{
            filter = [[GPUImageContrastFilter alloc] init];
            [(GPUImageContrastFilter *) filter setContrast:1.75];
        } break;
        case 102: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess.acv"];
        } break;
        case 103: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"02.acv"];
        } break;
        case 104: {
            filter = [[GrayscaleContrastFilter alloc] init];
        } break;
        case 105: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"17.acv"];
        } break;
        case 106: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"aqua.acv"];
        } break;
        case 107: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"yellow-red.acv"];
        } break;
        case 108: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"06.acv"];
        } break;
        case 109: {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"purple-green.acv"];
        } break;
        default:
            filter = [[GPUImageRGBFilter alloc] init];
            break;
    }
}

//返回
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//下一步
- (IBAction)nextStep:(id)sender {
    NSLog(@"下一步");
    
    GPUImageOutput<GPUImageInput> *processUpTo;
    processUpTo = filter;
    
    [staticPicture processImage];
    
    UIImage *currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutput];
    
    PublishController *publish=[[PublishController alloc] initWithNibName:@"PublishController" bundle:nil];
    publish.image=currentFilteredVideoFrame;
    [self.navigationController pushViewController:publish animated:YES];
}

//重新设定scrollView
-(void)resizeImageScroll:(UIImage *)image {
    _imageScroll.zoomScale=1.0f;
    _imgScale=1.0f;
    
    _resizeImageRect=[self resizeImageToFitScreen:image];
    _imageView.frame=CGRectMake(0, 0, _resizeImageRect.size.width, _resizeImageRect.size.height);
    _imageScroll.contentSize=_resizeImageRect.size;
    [self resizeImageScrollInset:_imageView.frame.size];
    _imageScroll.contentOffset=CGPointMake(-_resizeImageRect.origin.x, -_resizeImageRect.origin.y);
}

//使图片适应屏幕
-(CGRect)resizeImageToFitScreen:(UIImage *)image {
    CGSize imageSize=image.size;
    
    float x,y,width,height;
    
    float imgRatio=imageSize.width/imageSize.height;
    float scrollRatio=_imageScrollSize.width/_imageScrollSize.height;
    if (imgRatio>scrollRatio) {
        width=_imageScrollSize.width;
        height=width/imgRatio;
        x=0.f;
        y=(_imageScrollSize.height-height)/2;
    }else{
        height=_imageScrollSize.height;
        width=imgRatio*height;
        y=0.f;
        x=(_imageScrollSize.width-width)/2;
    }
    
    return CGRectMake(x, y, width, height);
}

//设置图片在scrollView中的Inset
-(void)resizeImageScrollInset:(CGSize)viewSize {
    if (viewSize.width>_imageScrollSize.width&&viewSize.height>_imageScrollSize.height) {
        _imageScroll.contentInset=UIEdgeInsetsZero;
    }else{
        _imageScroll.contentInset=UIEdgeInsetsMake(_resizeImageRect.origin.y, _resizeImageRect.origin.x, _resizeImageRect.origin.y, _resizeImageRect.origin.x);
    }
    
    float x=(_imageScrollSize.width-viewSize.width)/2;
    float y=(_imageScrollSize.height-viewSize.height)/2;
    if (x<0) {
        x=0;
    }
    if (y<0) {
        y=0;
    }
    
    _coordinateOffset=CGPointMake(x, y);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; {
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ((int)scrollView.tag==11) {
        [self resizeImageScrollInset:view.frame.size];
        _imgScale=scale;
    }
}

/*==================================================       旋转图片       ================================================*/

#pragma mark - 图片旋转

//旋转图片
-(void)doRonation {
    
    //旋转原图
    _image=[self image:_image rotation:UIImageOrientationRight];
    
    if (staticPicture) {
        staticPicture=nil;
    }
    
    [self initStaticPicture];
    
    /*
    //旋转imageView
    _imageView.transform=CGAffineTransformMakeRotation(M_PI_2*_transform);

    _transform++;
    if (_transform>4) {
        _transform=1;
    }
    */
}

//图片旋转
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation {
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    //释放context
    CGContextRelease(context);
    
    return newPic;
}

/*==================================================       旋转图片(END)       ================================================*/


/*==================================================       裁剪图片       ================================================*/

#pragma mark - 裁剪图片

#define CORNER_SIZE 100

//裁剪图片
-(void)doCutImage {
    //将裁剪按钮的enabled=no
    UIButton *button=(UIButton *)[self.view viewWithTag:200];
    button.enabled=NO;
    
    //navi头部显示裁剪的取消和成功按钮
    [self showOrHiddenCutNavi:YES];
    
    //设置遮罩层
    _cropView = [[NLCropViewLayer alloc] initWithFrame:_imageScroll.frame];
    _cropView.tag=51;
    [_cropView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_cropView];
    _movePoint = NoPoint;
    _lastMovePoint = CGPointMake(0, 0);
    
    //设置裁剪框
    CGFloat x=(self.view.bounds.size.width-CORNER_SIZE)/2;
    CGFloat y=(self.view.bounds.size.height-CORNER_SIZE-64)/2;
    
    [self setCropRegionRect:CGRectMake(x, y, CORNER_SIZE, CORNER_SIZE)];
}

//navi头部显示裁剪的取消和成功按钮
-(void)showOrHiddenCutNavi:(BOOL)flag {
    if (flag) {
        UIView *cutNavi=[[UIView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0, self.view.bounds.size.width, TOP_NAVI_HEIGHT)];
        cutNavi.tag=50;
        cutNavi.backgroundColor=[UIColor lightGrayColor];
        
        //取消裁剪
        UIButton *cancelBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame=CGRectMake(8, TOP_NAVI_HEIGHT-30-8, 30, 30);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelCut) forControlEvents:UIControlEventTouchUpInside];
        [cutNavi addSubview:cancelBtn];
        
        //完成裁剪
        UIButton *doneBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        doneBtn.frame=CGRectMake(self.view.bounds.size.width-30-8, TOP_NAVI_HEIGHT-30-8, 30, 30);
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doneCut) forControlEvents:UIControlEventTouchUpInside];
        [cutNavi addSubview:doneBtn];
        
        [self.view addSubview:cutNavi];
        
        [UIView animateWithDuration:0.3 animations:^{
            cutNavi.frame=CGRectMake(0, 0, self.view.bounds.size.width, TOP_NAVI_HEIGHT);
        }];
        
    }else{
        //移除裁剪navi
        UIView *cutNavi=[self.view viewWithTag:50];
        [UIView animateWithDuration:0.3 animations:^{
            cutNavi.frame=CGRectMake(-self.view.bounds.size.width, 0, self.view.bounds.size.width, TOP_NAVI_HEIGHT);
        } completion:^(BOOL finished) {
            if (finished) {
                [cutNavi removeFromSuperview];
            }
        }];
        
        //移除裁剪页面
        NLCropViewLayer *cropV=(NLCropViewLayer *)[self.view viewWithTag:51];
        [cropV removeFromSuperview];
    }
}

-(void)cancelCut {
    [self showOrHiddenCutNavi:NO];
    
    //将裁剪按钮的enabled=YES
    UIButton *button=(UIButton *)[self.view viewWithTag:200];
    button.enabled=YES;
}

-(void)doneCut {
    [self showOrHiddenCutNavi:NO];
    //将裁剪按钮的enabled=YES
    UIButton *button=(UIButton *)[self.view viewWithTag:200];
    button.enabled=YES;
    
    //将裁剪后的图片设置到页面上
    UIImage *cutImage=[self getCroppedImage];
    //保存裁剪后图片
    _image=cutImage;
    
    if (staticPicture) {
        staticPicture=nil;
    }
    [self initStaticPicture];
}

//设置裁剪框视图
- (void)setCropRegionRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _translatedCropRect =CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height);
    
    [_cropView setCropRegionRect:_translatedCropRect];
}

#define navitop 68

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    
    /*
    NSLog(@"当前点击的位置 %@",NSStringFromCGPoint(locationPoint));
    NSLog(@"裁剪框的位置 %@",NSStringFromCGRect(_translatedCropRect));
    NSLog(@"图片区域的位置 %@",NSStringFromCGSize(_imageView.bounds.size));
    NSLog(@"偏移量 %@",NSStringFromCGPoint(_coordinateOffset));
    NSLog(@"不在图片范围内 %@",[NSNumber numberWithBool:locationPoint.x<_coordinateOffset.x || locationPoint.x>(_imageView.bounds.size.width*_imgScale+_coordinateOffset.x) || locationPoint.y<(_coordinateOffset.y+navitop) || locationPoint.y>(_imageView.bounds.size.height*_imgScale+_coordinateOffset.y+navitop)]);
    */
    
    if (locationPoint.x<_coordinateOffset.x || locationPoint.x>(_imageView.bounds.size.width*_imgScale+_coordinateOffset.x) || locationPoint.y<(_coordinateOffset.y+navitop) || locationPoint.y>(_imageView.bounds.size.height*_imgScale+_coordinateOffset.y+navitop)) {
        _movePoint=NoPoint;
        return;
    }
    
    _lastMovePoint = locationPoint;
    
    //判断选择的是哪个角
    if(((locationPoint.x - 5) <= _translatedCropRect.origin.x) && ((locationPoint.x + 5) >= _translatedCropRect.origin.x)) {    //在左半边
        if(((locationPoint.y - 5) <= (_translatedCropRect.origin.y+navitop)) && ((locationPoint.y + 5) >= (_translatedCropRect.origin.y+navitop)))    //是否在左上角
            _movePoint = LeftTop;
        else if ((locationPoint.y - 5) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop) && (locationPoint.y + 5) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop))  //在左下角
            _movePoint = LeftBottom;
        else
            _movePoint = NoPoint;
    } else if(((locationPoint.x - 5) <= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) && ((locationPoint.x + 5) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width))) {   //在右半边
        if(((locationPoint.y - 5) <= (_translatedCropRect.origin.y+navitop)) && ((locationPoint.y + 5) >= (_translatedCropRect.origin.y+navitop)))  //在右上角
            _movePoint = RightTop;
        else if ((locationPoint.y - 5) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop) && (locationPoint.y + 5) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop))    //在右下角
            _movePoint = RightBottom;
        else
            _movePoint = NoPoint;
    } else if ((locationPoint.x > _translatedCropRect.origin.x) && (locationPoint.x < (_translatedCropRect.origin.x + _translatedCropRect.size.width)) && (locationPoint.y > _translatedCropRect.origin.y+navitop) && (locationPoint.y < (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop))) {   //在裁剪框中间
        _movePoint = MoveCenter;
    } else  //  在裁剪框外边
        _movePoint = NoPoint;
    
//    NSLog(@"movePoint %d",_movePoint);
}

//移动裁剪框
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    
    /*
    NSLog(@"当前点击的位置 %@",NSStringFromCGPoint(locationPoint));
    NSLog(@"裁剪框的位置 %@",NSStringFromCGRect(_translatedCropRect));
    NSLog(@"图片区域的位置 %@",NSStringFromCGSize(_imageView.bounds.size));
    NSLog(@"偏移量 %@",NSStringFromCGPoint(_coordinateOffset));
    */
     
    if (locationPoint.x<_coordinateOffset.x || locationPoint.x>(_imageView.bounds.size.width*_imgScale+_coordinateOffset.x) || locationPoint.y<(_coordinateOffset.y+navitop) || locationPoint.y>(_imageView.bounds.size.height*_imgScale+_coordinateOffset.y+navitop)) {
        _movePoint=NoPoint;
        return;
    }
    
    float x,y;
    switch (_movePoint) {
        case LeftTop:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) || ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop)))
                return;
            _translatedCropRect = CGRectMake(locationPoint.x, locationPoint.y-navitop, _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x), _translatedCropRect.size.height + (_translatedCropRect.origin.y+navitop - locationPoint.y));
            break;
        case LeftBottom:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_cropRect.origin.x + _translatedCropRect.size.width)) || ((locationPoint.y - _translatedCropRect.origin.y+navitop) <= MIN_IMG_SIZE))
                return;
            _translatedCropRect = CGRectMake(locationPoint.x, _translatedCropRect.origin.y, _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x), locationPoint.y - (_translatedCropRect.origin.y+navitop));
            break;
        case RightTop:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) || ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height+navitop)))
                return;
            _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, locationPoint.y-navitop, locationPoint.x - _translatedCropRect.origin.x, _translatedCropRect.size.height + (_translatedCropRect.origin.y+navitop - locationPoint.y));
            break;
        case RightBottom:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) || ((locationPoint.y - (_translatedCropRect.origin.y+navitop)) <= MIN_IMG_SIZE))
                return;
            _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y, locationPoint.x - _translatedCropRect.origin.x, locationPoint.y - (_translatedCropRect.origin.y+navitop));
            break;
        case MoveCenter:
            x = _lastMovePoint.x - locationPoint.x;
            y = _lastMovePoint.y - locationPoint.y;
            if(((_translatedCropRect.origin.x-x - _coordinateOffset.x) > 0) && ((_translatedCropRect.origin.x + _translatedCropRect.size.width - x +_coordinateOffset.x) < _cropView.bounds.size.width) && ((_translatedCropRect.origin.y-y-_coordinateOffset.y) > 0) && ((_translatedCropRect.origin.y + _translatedCropRect.size.height - y + _coordinateOffset.y) < _cropView.bounds.size.height)) {
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x - x, _translatedCropRect.origin.y - y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }
            _lastMovePoint = locationPoint;
            break;
        default: //NO Point
            return;
            break;
    }
    [_cropView setNeedsDisplay];
    _cropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y, _translatedCropRect.size.width, _translatedCropRect.size.height);
    [self setCropRegionRect:_cropRect];
    
}

//裁剪图片
- (UIImage *)getCroppedImage {
    
    /*
    //判断当前图片的的旋转状态
    UIImageOrientation orientation=UIImageOrientationUp;
    switch (_transform) {
        case 2:
            orientation=UIImageOrientationRight;
            break;
        case 3:
            orientation=UIImageOrientationDown;
            break;
        case 4:
            orientation=UIImageOrientationLeft;
            break;
    }
    
    if (orientation!=UIImageOrientationUp) {
        _image=[self image:_image rotation:orientation];
        [self resizeImageScroll:_image];
    }
    */
    
    //计算显示的图片与原图的比例
    float a=_imageView.bounds.size.height*_imgScale;
    float b=_image.size.height;
    float k=b/a;
    
    float imgOffsetX=_imageScroll.contentOffset.x;
    float imgOffsetY=_imageScroll.contentOffset.y;
    if (imgOffsetX<0) {
        imgOffsetX=0;
    }
    if (imgOffsetY<0) {
        imgOffsetY=0;
    }
    
    CGRect imageRect = CGRectMake((_cropRect.origin.x-_coordinateOffset.x+imgOffsetX)*k, (_cropRect.origin.y-_coordinateOffset.y+imgOffsetY)*k, _cropRect.size.width*k, _cropRect.size.height*k);
    CGImageRef imageRef = CGImageCreateWithImageInRect(_image.CGImage, imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

/*==================================================       裁剪图片(END)       ================================================*/

//移除所有过滤标记
-(void) removeAllTargets {
    [filter removeAllTargets];
    [staticPicture removeAllTargets];
}

-(void)dealloc {
    [self removeAllTargets];
    filter = nil;
    staticPicture = nil;
}

@end
