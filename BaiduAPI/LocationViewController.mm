//
//  LocationViewController.m
//  BaiduAPI
//
//  Created by 赵立波 on 14/11/3.
//  Copyright (c) 2014年 赵立波. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@property (retain, nonatomic) IBOutlet BMKMapView *_mapView;
@property(nonatomic,retain)BMKLocationService *_locService;
@property(nonatomic,retain)NSMutableDictionary *tmpColorDic;
@property(nonatomic,retain)NSMutableArray *sectionArr;
@property(nonatomic,retain)NSMutableDictionary *sectionDic;

@end

const double littleOffset=0.000001;

@implementation LocationViewController
@synthesize _mapView;
@synthesize _locService;
@synthesize tmpColorDic;
@synthesize sectionArr;
@synthesize sectionDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    //定位服务
    _locService = [[BMKLocationService alloc]init];
    //获取json数据
    NSString *roadJsonPath=[[NSBundle mainBundle] pathForResource:@"road" ofType:@"json"];
    NSData *jsonData=[[NSData alloc] initWithContentsOfFile:roadJsonPath];
    NSDictionary *jsonDic=[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    tmpColorDic=[[NSMutableDictionary alloc] init];
    sectionArr=[[NSMutableArray alloc] init];
    sectionDic=[[NSMutableDictionary alloc] init];
    
    [self setLocation:[jsonDic objectForKey:@"dests"]];
    [self setRoad:[jsonDic objectForKey:@"sections"] minAltitude:[[jsonDic objectForKey:@"min_altitude"] floatValue] maxAltitude:[[jsonDic objectForKey:@"max_altitude"] floatValue]];
}

/*
 * 设置位置标注
 */
-(void)setLocation:(NSArray *)locationArr {
    CLLocationCoordinate2D minScope={0,0};
    CLLocationCoordinate2D maxScope={0,0};
    
    NSMutableArray *locations=[[NSMutableArray alloc] init];
    int i=0;
    for (NSDictionary *dic in locationArr) {
        NSArray *lnglatArr=(NSArray *)[dic objectForKey:@"baidu_lnglat"];
        //地点标注
        CLLocationCoordinate2D coor;
        coor.latitude = [[lnglatArr objectAtIndex:1] doubleValue];
        coor.longitude = [[lnglatArr objectAtIndex:0] doubleValue];
        
        if (i==0) {
            minScope=coor;
            maxScope=coor;
        }else{
            maxScope.latitude=MAX(maxScope.latitude, coor.latitude);
            maxScope.longitude=MAX(maxScope.longitude, coor.longitude);
            minScope.latitude=MIN(minScope.latitude, coor.latitude);
            minScope.longitude=MIN(minScope.longitude, coor.longitude);
        }
        
        BMKPointAnnotation *point=[[BMKPointAnnotation alloc] init];
        point.coordinate = coor;
        point.title = [dic objectForKey:@"name"];
        [locations addObject:point];
        
        i++;
    }
    
    [_mapView addAnnotations:locations];
    
    //确定中心点，显示所有的坐标位置
    CLLocationCoordinate2D centercoor;
    centercoor.latitude=(minScope.latitude+maxScope.latitude)/2;
    centercoor.longitude=(minScope.longitude+maxScope.longitude)/2;
    
    CLLocationCoordinate2D span;
    span.latitude=maxScope.latitude-minScope.latitude;
    span.longitude=maxScope.longitude-minScope.longitude;
    
    _mapView.centerCoordinate=centercoor;
    BMKCoordinateRegion region=BMKCoordinateRegionMake(_mapView.centerCoordinate, BMKCoordinateSpanMake(span.latitude, span.longitude));
    [_mapView setRegion:region animated:YES];
    [_mapView setMapCenterToScreenPt:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
}

/*
 * 设置线路
 */
-(void)setRoad:(NSArray *)road minAltitude:(float)minAltitude maxAltitude:(float)maxAltitude {
    UIColor *tmpColor = nil;
    double offset=0.0005f;
    
    float middleAltitude=(minAltitude+maxAltitude)/2;
    float half=(maxAltitude-minAltitude)/2;
    
    for (NSDictionary *dic in road) {
        //红色 255,0,0    maxAltitude
        //黄色 255,255,0  middleAltitude
        //绿色 0,255,0    minAltitude
        
        /*
        int baiduCoordsCount=(int)[[dic objectForKey:@"baidu_coords"] count];
        // 添加折线覆盖物
        CLLocationCoordinate2D coors[baiduCoordsCount];
        int i=0;
        for (NSArray *lnglat in (NSArray *)[dic objectForKey:@"baidu_coords"]) {
            coors[i].latitude = [[lnglat objectAtIndex:1] doubleValue];
            coors[i].longitude = [[lnglat objectAtIndex:0] doubleValue];
            i++;
        }
        
        BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:baiduCoordsCount];
        [_mapView addOverlay:polyline];
         */
        
        //绘制彩色的折线覆盖物
        float startAltitude=[[dic objectForKey:@"start_altitude"] floatValue];
        float endAltitude=[[dic objectForKey:@"end_altitude"] floatValue];
        int sectorNum=(int)[[dic objectForKey:@"baidu_coords"] count]-1;
        
        BOOL altitudeEqual=NO;
        float piece = 0.0;
        if (startAltitude==endAltitude) {
            if(startAltitude>middleAltitude){
                //在黄-红区间
                float greenFloat=(maxAltitude-startAltitude)/half;
                tmpColor=[UIColor colorWithRed:1.0 green:greenFloat blue:0 alpha:1];
            }else{
                //在绿-黄区间
                float redFloat=(startAltitude-minAltitude)/half;
                tmpColor=[UIColor colorWithRed:redFloat green:1.0 blue:0 alpha:1];
            }
            altitudeEqual=YES;
        }else if (startAltitude>endAltitude){
            piece=(startAltitude-endAltitude)/sectorNum;
        }else{
            piece=(endAltitude-startAltitude)/sectorNum;
        }
        
        CLLocationCoordinate2D coors[2];
        NSArray *coordsArr=[dic objectForKey:@"baidu_coords"];
        for (int i=0; i<[coordsArr count]-1;i++) {
            double x1=[[[coordsArr objectAtIndex:i] objectAtIndex:0] doubleValue];
            double y1=[[[coordsArr objectAtIndex:i] objectAtIndex:1] doubleValue];
            double x2=[[[coordsArr objectAtIndex:i+1] objectAtIndex:0] doubleValue];
            double y2=[[[coordsArr objectAtIndex:i+1] objectAtIndex:1] doubleValue];
            
            //计算可点击的范围区间
            [self setClickableSectionWithx1:x1 y1:y1 x2:x2 y2:y2 AndOffset:offset];
            
            //设置线路线段
            coors[0].latitude=y1;
            coors[0].longitude=x1;
            coors[1].latitude=y2;
            coors[1].longitude=x2;
            
            if (altitudeEqual==NO) {
                if (startAltitude>endAltitude){
                    float current=(startAltitude-piece*i);
                    if (endAltitude>middleAltitude) {
                        //在黄-红区间
                        float greenFloat=(maxAltitude-current)/half;
                        tmpColor=[UIColor colorWithRed:1.0 green:greenFloat blue:0 alpha:1];
                    }else if (startAltitude<middleAltitude){
                        //在绿-黄区间
                        float redFloat=(current-minAltitude)/half;
                        tmpColor=[UIColor colorWithRed:redFloat green:1.0 blue:0 alpha:1];
                    }else{
                        //startAltitude在黄-红区间,endAltitude在绿-黄区间
                        if (current>middleAltitude) {
                            //当前海拔在黄-红区间
                            float greenFloat=(maxAltitude-current)/half;
                            tmpColor=[UIColor colorWithRed:1.0 green:greenFloat blue:0 alpha:1];
                        }else{
                            //当前海拔在绿-黄区间
                            float redFloat=(current-minAltitude)/half;
                            tmpColor=[UIColor colorWithRed:redFloat green:1.0 blue:0 alpha:1];
                        }
                    }
                }else{
                    float current=(startAltitude+piece*i);
                    if (startAltitude>middleAltitude) {
                        //在黄-红区间
                        float greenFloat=(maxAltitude-current)/half;
                        tmpColor=[UIColor colorWithRed:1.0 green:greenFloat blue:0 alpha:1];
                    }else if (endAltitude<middleAltitude){
                        //在绿-黄区间
                        float redFloat=(current-minAltitude)/half;
                        tmpColor=[UIColor colorWithRed:redFloat green:1.0 blue:0 alpha:1];
                    }else{
                        //startAltitude在绿-黄区间,endAltitude在黄-红区间
                        if (current>middleAltitude) {
                            //当前海拔在黄-红区间
                            float greenFloat=(maxAltitude-current)/half;
                            tmpColor=[UIColor colorWithRed:1.0 green:greenFloat blue:0 alpha:1];
                        }else{
                            //当前海拔在绿-黄区间
                            float redFloat=(current-minAltitude)/half;
                            tmpColor=[UIColor colorWithRed:redFloat green:1.0 blue:0 alpha:1];
                        }
                    }
                }
            }
            BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:2];
            [_mapView addOverlay:polyline];
            [tmpColorDic setObject:tmpColor forKey:[NSString stringWithFormat:@"%p",polyline]];
        }
        
    }
    //设置到sectionDic中
    NSArray *road1Arr=[[NSArray alloc] initWithArray:sectionArr];
    [sectionDic setObject:road1Arr forKey:@"road1"];
    [sectionArr removeAllObjects];
    
    //第二条线段
    double otherx1=121.823976;
    double othery1=29.755386;
    double otherx2=121.819795;
    double othery2=29.745322;
    tmpColor=[UIColor purpleColor];
    CLLocationCoordinate2D othercoor[2];
    othercoor[0].latitude=othery1;
    othercoor[0].longitude=otherx1;
    othercoor[1].latitude=othery2;
    othercoor[1].longitude=otherx2;
    
    [self setClickableSectionWithx1:otherx1 y1:othery1 x2:otherx2 y2:othery2 AndOffset:offset];
    
    BMKPolyline *otherpolyline=[BMKPolyline polylineWithCoordinates:othercoor count:2];
    [_mapView addOverlay:otherpolyline];
    [tmpColorDic setObject:tmpColor forKey:[NSString stringWithFormat:@"%p",otherpolyline]];
    
    //设置到sectionDic中
    NSArray *road2Arr=[[NSArray alloc] initWithArray:sectionArr];
    [sectionDic setObject:road2Arr forKey:@"road2"];
    [sectionArr removeAllObjects];
}

/*
 * 设置可点击的区间
 */
-(void)setClickableSectionWithx1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2 AndOffset:(double)offset {
    double k=(y2-y1)/(x2-x1);    //斜率
    double b=y1-k*x1;            //与y轴焦点
    double b0=b-offset;
    double b1=b+offset;
    NSDictionary *tmpDic=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:k],@"k",[NSNumber numberWithDouble:b0],@"b0",[NSNumber numberWithDouble:b1],@"b1",[NSNumber numberWithDouble:x1],@"x1",[NSNumber numberWithDouble:x2],@"x2", nil];
    [sectionArr addObject:tmpDic];
}

/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    //折线
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [tmpColorDic objectForKey:[NSString stringWithFormat:@"%p",overlay]];
        polylineView.lineWidth = 5.0f;
        
        return polylineView;
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate=(id<BMKMapViewDelegate>)self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate=(id<BMKLocationServiceDelegate>)self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * 定位
 */
- (IBAction)doLocation:(id)sender {
    NSLog(@"进入普通定位态");
    [self locationService];
}

/*
 * 停止定位
 */
- (IBAction)stopLocation:(id)sender {
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

-(void)locationService {
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"点击的位置 %f,%f",coordinate.longitude,coordinate.latitude);
    
    BOOL findPosition=NO;
    double x=coordinate.longitude;
    double y=coordinate.latitude;
    
    for (NSString *sectionKey in sectionDic) {
        for (NSDictionary *dic in [sectionDic objectForKey:sectionKey]) {
            double k=[[dic objectForKey:@"k"] doubleValue];
            double b0=[[dic objectForKey:@"b0"] doubleValue];
            double b1=[[dic objectForKey:@"b1"] doubleValue];
            double x1=[[dic objectForKey:@"x1"] doubleValue];
            double x2=[[dic objectForKey:@"x2"] doubleValue];
            
            double xmin=x1;
            double xmax=x2;
            if (x1>x2) {
                xmin=x2;
                xmax=x1;
            }
            if (x>=xmin&&x<=xmax) {
                double resulty0=k*x+b0;
                double resulty1=k*x+b1;
                
                double ymin=resulty0;
                double ymax=resulty1;
                if (resulty0>resulty1) {
                    ymin=resulty1;
                    ymax=resulty0;
                }
                if (y>=ymin&&y<=ymax) {
                    findPosition=YES;
                    //找到点击在线路上的位置
                    NSLog(@"当前在 %@",sectionKey);
                    NSLog(@"x范围 (%f , %f)",xmin,xmax);
                    NSLog(@"y范围 (%f , %f)",ymin,ymax);
                    break;
                }
            }
        }
        if (findPosition==YES) {
            break;
        }
    }
    
}

/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (BMKAnnotationView *subView in views) {
//        subView.canShowCallout=NO;
        subView.image=[UIImage imageNamed:@"a"];
        subView.centerOffset=CGPointMake(0, 0);
    }
}

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    view.image=[UIImage imageNamed:@"b"];
    view.centerOffset=CGPointMake(22.5, -22.5);
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_mapView.centerCoordinate.latitude+littleOffset, _mapView.centerCoordinate.longitude+littleOffset) animated:YES];
}

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    view.image=[UIImage imageNamed:@"a"];
    view.centerOffset=CGPointMake(0, 0);
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_mapView.centerCoordinate.latitude-littleOffset, _mapView.centerCoordinate.longitude-littleOffset) animated:YES];
}

@end
