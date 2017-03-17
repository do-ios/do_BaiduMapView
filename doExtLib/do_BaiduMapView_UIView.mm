//
//  do_BaiduMapView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduMapView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doJsonHelper.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"
#import "MyAnimatedAnnotationView.h"
#import "doIOHelper.h"
#import "doIPage.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>

#import <objc/runtime.h>
#import "doILogEngine.h"
#import "doRouteAnnotation.h"
#import "UIImage+doRotate.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface do_BaiduMapView_UIView() <BMKMapViewDelegate, BMKGeneralDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate,BMKOfflineMapDelegate>
@end
@implementation do_BaiduMapView_UIView
{
    NSMutableDictionary *_dictAnnotation;
    NSMutableDictionary *_dictOverlay;
    NSMutableDictionary *_dictImags;
    NSString *_annotationID;
    NSDictionary *dict;
    id<doIScriptEngine> _scritEngine;
    NSString *_callbackName;
    BMKPoiSearch *_poisearch;
    BMKMapManager *_mapManager;
    BMKMapView *_mapView;
    BMKOfflineMap *_offlineMap;
    
    BMKRouteSearch *_routesearch;
    
    NSString *_modelString;
    
    NSMutableArray *markerInfos;
    
    NSString *_fillColor0;
    NSString *_fillColor1;
    NSString *_fillColor2;
    NSString *_fillColor3;
    
    NSString *_strokecolor0;
    NSString *_strokecolor1;
    NSString *_strokecolor2;
    NSString *_strokecolor3;
    
    int _lineWidth0;
    int _lineWidth1;
    int _lineWidth2;
    int _lineWidth3;
    
    BOOL _isDash0;
    BOOL _isDash1;
    BOOL _isDash2;
    BOOL _isDash3;
    
    BMKPolyline *_polyline;
    BMKArcline *_arcline;
    BMKPolygon *_polygon;
    BMKCircle *_circle;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    NSString *_BMKMapKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduMapAppKey.plist" :@"baiduMapViewAppKey" ];
    
    NSString *isStart =  objc_getAssociatedObject([UIApplication sharedApplication], "BaiduLocation");
    objc_setAssociatedObject([UIApplication sharedApplication], "BaiduMapView", @"start", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (![isStart isEqualToString:@"start"]) {
        if (!_mapManager)
        {
            _mapManager = [[BMKMapManager alloc]init];
        }
        [_mapManager start:_BMKMapKey generalDelegate:nil];
    }
    if (!_mapView)
    {
        _mapView = [[BMKMapView alloc]init];
    }
    [_mapView setFrame:CGRectMake(0 ,0 ,_model.RealWidth, _model.RealHeight)];
    [self addSubview:_mapView];
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(39.9255, 116.3995);
    _mapView.showMapScaleBar = YES;
    _mapView.delegate = self;
    _poisearch = [[BMKPoiSearch alloc]init];
    _poisearch.delegate = self;
    _dictAnnotation = [[NSMutableDictionary alloc]init];
    _dictOverlay = [NSMutableDictionary dictionary];
    _dictImags = [[NSMutableDictionary alloc]init];
    
    NSString *mapType = [(doUIModule *)_model GetProperty:@"mapType"].DefaultValue;
    
    [_model SetPropertyValue:@"mapType" :mapType];
    
    //marker的信息
    markerInfos = [NSMutableArray array];
}

//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    
    [self removeAll:nil];
    _dictAnnotation = nil;
    _dictImags = nil;
    [_mapView removeFromSuperview];
    _mapView = nil;
    if(_mapManager)
    {
        [_mapManager stop];
    }
    
    markerInfos = nil;
}

//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    [_mapView setFrame:CGRectMake(0, 0, _model.RealWidth, _model.RealHeight)];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */

- (void)change_mapType:(NSString *)newValue
{
    //自己的代码实现
    if (newValue == nil || [newValue isEqualToString:@""])
    {
        newValue = [(doUIModule *)_model GetProperty:@"mapType"].DefaultValue;
    }
    if ([newValue isEqualToString:@"standard"]) {
        [_mapView setMapType:BMKMapTypeStandard];
    }
    else
    {
        [_mapView setMapType:BMKMapTypeSatellite];
    }
    
}
- (void)change_zoomLevel:(NSString *)newValue
{
    //自己的代码实现
    if (newValue == nil || [newValue isEqualToString:@""])
    {
        newValue = [(doUIModule *)_model GetProperty:@"zoomLevel"].DefaultValue;
    }
    float level = [newValue floatValue];
    if (level<3) {
        level = 3;
    }
    else if(level > 20)
    {
        level = 20;
    }
    _mapView.zoomLevel = level;
}

#pragma mark -
#pragma mark - 同步异步方法的实现
- (void)getDistance:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *startPoint = [doJsonHelper GetOneText:_dictParas :@"startPoint" :@""];
    NSString *endPoint = [doJsonHelper GetOneText:_dictParas :@"endPoint" :@""];
    NSArray *starts = [startPoint componentsSeparatedByString:@","];
    NSArray *ends = [endPoint componentsSeparatedByString:@","];
    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([[starts firstObject] floatValue],[[starts lastObject]floatValue]));
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([[ends firstObject] floatValue],[[ends lastObject]floatValue]));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    [_invokeResult SetResultFloat:distance];
    //_invokeResult设置返回值
}

//同步
- (void)addMarkers:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    NSArray *parmArray = [doJsonHelper GetOneArray :_dictParas :@"data"];
    [markerInfos addObjectsFromArray:parmArray];
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    for (NSDictionary *parm in parmArray) {
        BMKPointAnnotation *_pointAnnotation = [[BMKPointAnnotation alloc]init];
        NSString *latitude = [doJsonHelper GetOneText:parm :@"latitude" :@"39.91574"];
        NSString *longitude = [doJsonHelper GetOneText:parm :@"longitude" :@"116.403901"];
        NSString *imagePath = [doJsonHelper GetOneText:parm:@"url":@""];
        NSString *info = [doJsonHelper GetOneText:parm:@"info":@""];
        CLLocationCoordinate2D coor;
        coor.latitude = [latitude floatValue];
        coor.longitude = [longitude floatValue];
        [_pointAnnotation setTitle:info];
        [_pointAnnotation setCoordinate:coor];
        _annotationID = [doJsonHelper GetOneText:parm :@"id" :@""];
        if ([self isExitKey:_annotationID withArray:[_dictAnnotation allKeys]]) {
            NSString *errorStr = [NSString stringWithFormat:@"id为%@已经存在",_annotationID];
            NSException *ex = [[NSException alloc]initWithName:@"do_BaiduMapView addMarkers" reason:errorStr userInfo:nil];
            [[doServiceContainer Instance].LogEngine WriteError:ex :@"do_BaiduMapView"];
            continue;
        }
        [_dictAnnotation setValue:_pointAnnotation forKey:_annotationID];
        [_dictImags setValue:imagePath forKey:_annotationID];
        [_mapView addAnnotation:_pointAnnotation];
    }
    [_invokeResult SetResultBoolean:YES];
}
- (BOOL)isExitKey:(NSString *)key withArray:(NSArray *)keys
{
    BOOL isExit = NO;
    for (NSString  *temp in keys) {
        if ([key isEqualToString:temp]) {
            isExit = YES;
            break;
        }
    }
    return isExit;
}
- (void)addOverlay:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    int type = [doJsonHelper GetOneInteger:_dictParas :@"type" :0];
    
    NSString *_id = [doJsonHelper GetOneText:_dictParas :@"id" :@""];
    if ([self isExitKey:_id withArray:[_dictOverlay allKeys]]) {
        NSString *errorStr = [NSString stringWithFormat:@"id为%@已经存在",_id];
        NSException *ex = [[NSException alloc]initWithName:@"do_BaiduMapView addOverlay" reason:errorStr userInfo:nil];
        [[doServiceContainer Instance].LogEngine WriteError:ex :@"do_BaiduMapView"];
        return;
    }
    id<BMKOverlay> currentOverLay;
    if (type == 0) {//Circle
        _fillColor0 = [doJsonHelper GetOneText:_dictParas :@"fillColor" :@""];
        _strokecolor0 = [doJsonHelper GetOneText:_dictParas :@"strokeColor" :@""];
        _lineWidth0 = [doJsonHelper GetOneInteger:_dictParas :@"width" :1];
        _isDash0 = [doJsonHelper GetOneBoolean:_dictParas :@"isDash" :NO];
        NSDictionary *parma = [doJsonHelper GetOneNode:_dictParas :@"data"];
        currentOverLay = [self addCircleOverlay:parma];
    }
    else if (type == 1)//Polyline
    {
        _fillColor1 = [doJsonHelper GetOneText:_dictParas :@"fillColor" :@""];
        _strokecolor1 = [doJsonHelper GetOneText:_dictParas :@"strokeColor" :@""];
        _lineWidth1 = [doJsonHelper GetOneInteger:_dictParas :@"width" :1];
        _isDash1 = [doJsonHelper GetOneBoolean:_dictParas :@"isDash" :NO];
        NSArray *parmas = [doJsonHelper GetOneArray:_dictParas :@"data"];
        currentOverLay = [self addPolylineOverlay:parmas];
    }
    else if (type == 2)//Polygon
    {
        _fillColor2 = [doJsonHelper GetOneText:_dictParas :@"fillColor" :@""];
        _strokecolor2 = [doJsonHelper GetOneText:_dictParas :@"strokeColor" :@""];
        _lineWidth2 = [doJsonHelper GetOneInteger:_dictParas :@"width" :1];
        _isDash2 = [doJsonHelper GetOneBoolean:_dictParas :@"isDash" :NO];
        NSArray *parmas = [doJsonHelper GetOneArray:_dictParas :@"data"];
        currentOverLay = [self addPolygonOverlay:parmas];
    }
    else if (type == 3)//Arc
    {
        _fillColor3 = [doJsonHelper GetOneText:_dictParas :@"fillColor" :@""];
        _strokecolor3 = [doJsonHelper GetOneText:_dictParas :@"strokeColor" :@""];
        _lineWidth3 = [doJsonHelper GetOneInteger:_dictParas :@"width" :1];
        _isDash3 = [doJsonHelper GetOneBoolean:_dictParas :@"isDash" :NO];
        NSArray *parmas = [doJsonHelper GetOneArray:_dictParas :@"data"];
        currentOverLay = [self addArcOverlay:parmas];
    }
    [_dictOverlay setObject:currentOverLay forKey:_id];
    
}

- (void)removeAll:(NSArray *)parms
{
    for (id key in _dictAnnotation.allKeys) {
        [_mapView removeAnnotation:_dictAnnotation[key]];
    }
    for (NSString *key in _dictOverlay.allKeys) {
        [_mapView removeOverlay:_dictOverlay [key]];
    }
    [_dictAnnotation removeAllObjects];
    [_dictOverlay removeAllObjects];
    [_dictImags removeAllObjects];
    [markerInfos removeAllObjects];
}

- (void)removeMarker:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSArray *ids = [doJsonHelper GetOneArray:_dictParas :@"ids"];
    BOOL flag = YES;
    for (NSString *_pointAnnotationID in ids) {
        if ([_dictAnnotation objectForKey:_pointAnnotationID] != nil)
        {
            [_mapView removeAnnotation:_dictAnnotation[_pointAnnotationID]];
            [_dictAnnotation removeObjectForKey:_pointAnnotationID];
            [_dictImags removeObjectForKey:_pointAnnotationID];
        }
        else
        {
            flag = NO;
        }
    }
    [_invokeResult SetResultBoolean:flag];
    
}
- (void)removeOverlay:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    NSArray *ids = [doJsonHelper GetOneArray:_dictParas :@"ids"];
    for (NSString *overlayID in ids) {
        if ([_dictOverlay objectForKey:overlayID] != nil) {
            [_mapView removeOverlay:[_dictOverlay objectForKey:overlayID]];
            [_dictOverlay removeObjectForKey:overlayID];
        }
    }
}
- (void)setCenter:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *latitude = [doJsonHelper GetOneText:_dictParas :@"latitude" :@""];
    NSString *longitude = [doJsonHelper GetOneText:_dictParas :@"longitude" :@""];
    if (latitude != nil && longitude != nil)
    {
        _mapView.centerCoordinate = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
        [_invokeResult SetResultBoolean:YES];
    }
    else
    {
        [_invokeResult SetResultBoolean:NO];
    }
}
//异步
- (void)poiSearch:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    int type = [doJsonHelper GetOneInteger:_dictParas :@"type" :0];
    NSString *keyword = [doJsonHelper GetOneText:_dictParas :@"keyword" :@""];
    int pageIndex = [doJsonHelper GetOneInteger:_dictParas :@"pageIndex" :0];
    int pageNum = [doJsonHelper GetOneInteger:_dictParas :@"pageSize" :10];
    NSDictionary *param = [doJsonHelper GetOneNode:_dictParas :@"param"];
    if (type == 0) {
        BMKCitySearchOption *option = [self getCitySearchOption:param];
        option.keyword = keyword;
        option.pageIndex = pageIndex;
        option.pageCapacity = pageNum;
        [_poisearch poiSearchInCity:option];
    }
    else if(type == 1)
    {
        BMKBoundSearchOption *option = [self getBoundSearchOption:param];
        option.keyword = keyword;
        option.pageIndex = pageIndex;
        option.pageCapacity = pageNum;
        [_poisearch poiSearchInbounds:option];
    }
    else if (type == 2)
    {
        BMKNearbySearchOption *option = [self getNearbySearchOption:param];
        option.keyword = keyword;
        option.pageIndex = pageIndex;
        option.pageCapacity = pageNum;
        [_poisearch poiSearchNearBy:option];
    }
    _callbackName = [parms objectAtIndex:2];
}
- (void)routePlanSearch:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    NSString *type = [doJsonHelper GetOneText:_dictParas :@"type" :@""];
    NSString *startCityName = [doJsonHelper GetOneText:_dictParas :@"startCityName" :@""];
    NSString *endCityName = [doJsonHelper GetOneText:_dictParas :@"endCityName" :@""];
    NSString *startCitySite = [doJsonHelper GetOneText:_dictParas :@"startCitySite" :@""];
    NSString *endCitySite = [doJsonHelper GetOneText:_dictParas :@"endCitySite" :@""];
    _routesearch = [[BMKRouteSearch alloc]init];
    _routesearch.delegate = self;
    //开始结束点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = startCitySite;
    start.cityName = startCityName;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = endCitySite;
    end.cityName = endCityName;
    BMKBaseRoutePlanOption *option = [self routePlanFactory:type];
    option.from = start;
    option.to = end;
    BOOL flag = [self routeSearch:option];
    if (flag) {
        NSLog(@"success");
    }
}

- (void)getHotCityList:(NSArray *)parms
{
//    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngineHot = [parms objectAtIndex:1];
    //自己的代码实现
    
    _callbackName = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    if (!_offlineMap) {
        _offlineMap = [[BMKOfflineMap alloc] init];
    }
    _offlineMap.delegate = self;
    NSArray *cities = [_offlineMap getHotCityList];
    NSMutableArray *hotCityList = [NSMutableArray array];
    for (BMKOLSearchRecord *record in cities) {
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        [node setObject:@(record.cityID) forKey:@"cityID"];
        [node setObject:record.cityName forKey:@"cityName"];
        [node setObject:@(record.size) forKey:@"size"];
        [hotCityList addObject:node];
    }
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_invokeResult SetResultArray:hotCityList];
    [_scritEngineHot Callback:_callbackName :_invokeResult];
}
- (void)pauseDownload:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    int cityID = [doJsonHelper GetOneInteger:_dictParas :@"cityID" :0];
    //_invokeResult设置返回值
    BOOL success = NO;
    if (!_offlineMap) {
        _offlineMap = [[BMKOfflineMap alloc] init];
    }
    _offlineMap.delegate = nil;
    success = [_offlineMap pause:cityID];
    [_invokeResult SetResultBoolean:success];
}
- (void)startDownload:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _scritEngine = [parms objectAtIndex:1];
    _callbackName = [parms objectAtIndex:2];
    //自己的代码实现
    int cityID = [doJsonHelper GetOneInteger:_dictParas :@"cityID" :0];
    //_invokeResult设置返回值
    if (!_offlineMap) {
        _offlineMap = [[BMKOfflineMap alloc] init];
    }
    _offlineMap.delegate = self;
    BOOL success = [_offlineMap start:cityID];
    doInvokeResult *_invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_invokeResult SetResultBoolean:success];
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)removeDownload:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    int cityID = [doJsonHelper GetOneInteger: _dictParas :@"cityID" :0];
    //_invokeResult设置返回值
    BOOL success = NO;
    if (_offlineMap) {
         success = [_offlineMap remove:cityID];
    }
    _offlineMap.delegate = nil;
    [_invokeResult SetResultBoolean:success];
}
#pragma mark - 离线地图代理
- (void)onGetOfflineMapState:(int)type withState:(int)state
{
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    if (type == TYPE_OFFLINE_UPDATE) {
        BMKOLUpdateElement *element = [_offlineMap getUpdateInfo:state];
        [node setObject:@(element.cityID) forKey:@"cityID"];
        [node setObject:element.cityName forKey:@"cityName"];
        [node setObject:@(element.ratio) forKey:@"ratio"];
        doInvokeResult *invoke = [[doInvokeResult alloc]init:_model.UniqueKey];
        [invoke SetResultNode:node];
        [_model.EventCenter FireEvent:@"download" :invoke];
    }
}
#pragma mark - BMKMapViewDelegate
/**
 *查找指定overlay对应的View，如果该View尚未创建，返回nil
 *@param overlay 指定的overlay
 *@return 指定overlay对应的View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        [doUIModuleHelper GetColorFromString:_fillColor0 :[UIColor blackColor]];
        circleView.fillColor = [doUIModuleHelper GetColorFromString:_fillColor0 :[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        circleView.strokeColor = [doUIModuleHelper GetColorFromString:_strokecolor0 :[UIColor blackColor]];
        circleView.lineWidth = _lineWidth0;
        circleView.lineDash = _isDash0;
        return circleView;
    }
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        if (_lineWidth1 == 0) {
            polylineView.lineWidth = 3;
        }
        else
        {
            polylineView.lineWidth = _lineWidth1;
        }
        polylineView.lineDash = _isDash1;
        /// 使用分段颜色绘制时，必须设置（内容必须为UIColor）
        if (!_fillColor1) {
            polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        }
        else
        {
            polylineView.fillColor = [doUIModuleHelper GetColorFromString:_fillColor1 :[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        }
        if (!_strokecolor1) {
            polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        }
        else
        {
            polylineView.strokeColor = [doUIModuleHelper GetColorFromString:_strokecolor1 :[UIColor blackColor]];
        }
        polylineView.colors = [NSArray arrayWithObjects:[doUIModuleHelper GetColorFromString:_strokecolor1 :[UIColor blackColor]], nil];
        return polylineView;
    }
    
    if ([overlay isKindOfClass:[BMKPolygon class]])
    {
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [doUIModuleHelper GetColorFromString:_strokecolor2 :[UIColor blackColor]];
        polygonView.fillColor = [doUIModuleHelper GetColorFromString:_fillColor2 :[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        polygonView.lineWidth =_lineWidth2;
        polygonView.lineDash = _isDash2;
        return polygonView;
    }
    if ([overlay isKindOfClass:[BMKArcline class]]) {
        BMKArclineView *arclineView = [[BMKArclineView alloc] initWithArcline:overlay];
        arclineView.strokeColor = [doUIModuleHelper GetColorFromString:_strokecolor3 :[UIColor blackColor]];
        arclineView.lineDash = _isDash3;
        arclineView.lineWidth = _lineWidth3;
        return arclineView;
    }
    return nil;
}
/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CGFloat latitude = mapView.region.center.latitude;
    CGFloat longitude = mapView.region.center.longitude;
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setObject:@(latitude)forKey:@"latitude"];
    [node setObject:@(longitude) forKey:@"longitude"];
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:node];
    [_model SetPropertyValue:@"zoomLevel" :[NSString stringWithFormat:@"%f",mapView.zoomLevel]];
    [_model.EventCenter FireEvent:@"regionChange" :invokeResult];
}
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[doRouteAnnotation class]]) {
        return [(doRouteAnnotation*)annotation getRouteAnnotationView:mapView];
    }
    NSString *AnnotationViewID = @"AnimatedAnnotation";
    MyAnimatedAnnotationView *_annotationView = nil;
    if (_annotationView == nil) {
        _annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    NSString *_pathID;
    for (NSString *_anno in _dictAnnotation.allKeys) {
        if (annotation == _dictAnnotation[_anno])
        {
            _pathID = _anno;
            break;
        }
    }
    
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:_model.CurrentPage.CurrentApp :_dictImags[_pathID]];
    if([[NSFileManager defaultManager]fileExistsAtPath:imgPath])
    {
        UIImage * image = [UIImage imageWithContentsOfFile:imgPath];
        
        _annotationView.image = image;
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:image];
    }
    else
    {
        NSString *errorStr = [NSString stringWithFormat:@"%@文件不存在",_dictImags[_pathID]];
        NSException *ex = [[NSException alloc]initWithName:@"do_BaiduMapView addMarker" reason:errorStr userInfo:nil];
        [[doServiceContainer Instance].LogEngine WriteError:ex :@"do_BaiduMapView"];
    }
    _annotationView.viewID = _pathID;
    _annotationView.draggable = YES;
    return _annotationView;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view isKindOfClass:[MyAnimatedAnnotationView class]]) {
        NSMutableDictionary *node ;
        NSString *viewID = ((MyAnimatedAnnotationView *)view).viewID;
        for (NSDictionary *dictTmp in markerInfos) {
            if ([[dictTmp objectForKey:@"id"] isKindOfClass:[NSString class]]) {
                if ([[dictTmp objectForKey:@"id"]isEqualToString:viewID]) {
                    node = [NSMutableDictionary dictionaryWithDictionary:dictTmp];
                }
            }
        }
        doInvokeResult* _invokeResult = [[doInvokeResult alloc]init];
        [_invokeResult SetResultNode:node];
        [_model.EventCenter FireEvent:@"touchMarker":_invokeResult];
    }
}
//- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
//{
//    if ([view isKindOfClass:[MyAnimatedAnnotationView class]]) {
//        NSMutableDictionary *node ;
//        NSString *viewID = ((MyAnimatedAnnotationView *)view).viewID;
//        for (NSDictionary *dictTmp in markerInfos) {
//            if ([[dictTmp objectForKey:@"id"]isEqualToString:viewID]) {
//                node = [NSMutableDictionary dictionaryWithDictionary:dictTmp];
//            }
//        }
//        doInvokeResult* _invokeResult = [[doInvokeResult alloc]init];
//        [_invokeResult SetResultNode:node];
//        [_model.EventCenter FireEvent:@"touchMarker":_invokeResult];
//    }
//    
//}
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    NSString *latitudeStr = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSMutableDictionary *resNode = [NSMutableDictionary dictionary];
    [resNode setObject:latitudeStr forKey:@"latitude"];
    [resNode setObject:longitudeStr forKey:@"longitude"];
    [invokeResult SetResultNode:resNode];
    [_model.EventCenter FireEvent:@"touchMap" :invokeResult];
}
#pragma mark - poi搜索代理方法
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        NSArray *poiInfoList = poiResult.poiInfoList;
        for (BMKPoiInfo *info in poiInfoList) {
            NSString *pt = [NSString stringWithFormat:@"%f,%f",info.pt.latitude,info.pt.longitude];
            NSMutableDictionary *dictNode = [NSMutableDictionary dictionary];
            [dictNode setObject:info.name forKey:@"name"];
            [dictNode setObject:pt forKey:@"pt"];
            [dictNode setObject:info.address forKey:@"address"];
            [dictNode setObject:info.city forKey:@"city"];
            [resultArray addObject:dictNode];
        }
        doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
        [invokeResult SetResultArray:resultArray];
        [_scritEngine Callback:_callbackName :invokeResult];
    }
}
#pragma  mark - 线路检索代理
//步行线路检索
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
//骑行检索
- (void)onGetRidingRouteResult:(BMKRouteSearch *)searcher result:(BMKRidingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"onGetRidingRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKRidingRouteLine* plan = (BMKRidingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
            } else if(i==size-1){
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.degree = (int)transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            NSLog(@"%@   %@    %@", transitStep.entraceInstruction, transitStep.exitInstruction, transitStep.instruction);
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
/**
 *返回公共交通路线检索结果（new）
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKMassTransitRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetMassTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKMassTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetMassTransitRouteResult error:%d", (int)error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKMassTransitRouteLine* routeLine = (BMKMassTransitRouteLine*)[result.routes objectAtIndex:0];
        
        BOOL startCoorIsNull = YES;
        CLLocationCoordinate2D startCoor;//起点经纬度
        CLLocationCoordinate2D endCoor;//终点经纬度
        
        NSInteger size = [routeLine.steps count];
        NSInteger planPointCounts = 0;
        for (NSInteger i = 0; i < size; i++) {
            BMKMassTransitStep* transitStep = [routeLine.steps objectAtIndex:i];
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                //添加annotation节点
                doRouteAnnotation* item = [[doRouteAnnotation alloc]init];
                item.coordinate = subStep.entraceCoor;
                item.title = subStep.instructions;
                item.type = 2;
                [_mapView addAnnotation:item];
                
                if (startCoorIsNull) {
                    startCoor = subStep.entraceCoor;
                    startCoorIsNull = NO;
                }
                endCoor = subStep.exitCoor;
                
                //轨迹点总数累计
                planPointCounts += subStep.pointsCount;
                
                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        //添加起点标注
        doRouteAnnotation* startAnnotation = [[doRouteAnnotation alloc]init];
        startAnnotation.coordinate = startCoor;
        startAnnotation.title = @"起点";
        startAnnotation.type = 0;
        [_mapView addAnnotation:startAnnotation]; // 添加起点标注
        //添加终点标注
        doRouteAnnotation* endAnnotation = [[doRouteAnnotation alloc]init];
        endAnnotation.coordinate = endCoor;
        endAnnotation.title = @"终点";
        endAnnotation.type = 1;
        [_mapView addAnnotation:endAnnotation]; // 添加起点标注
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        NSInteger index = 0;
        for (BMKMassTransitStep* transitStep in routeLine.steps) {
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                for (NSInteger i = 0; i < subStep.pointsCount; i++) {
                    temppoints[index].x = subStep.points[i].x;
                    temppoints[index].y = subStep.points[i].y;
                    index++;
                }
                
                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
#pragma mark - 私有方法
//添加圆形遮盖物
- (id<BMKOverlay>) addCircleOverlay:(NSDictionary *)parma
{
    NSString *latitude = [doJsonHelper GetOneText:parma :@"latitude" :@""];
    NSString *longitude = [doJsonHelper GetOneText:parma :@"longitude" :@""];
    NSString *radius = [doJsonHelper GetOneText:parma :@"radius" :@""];
    CLLocationCoordinate2D coor;
    coor.latitude = [latitude doubleValue];
    coor.longitude = [longitude doubleValue];
    _circle = [BMKCircle circleWithCenterCoordinate:coor radius:[radius doubleValue]];
    [_mapView addOverlay:_circle];
    return _circle;
}

// 添加折线遮盖物
- (id<BMKOverlay> ) addPolylineOverlay:(NSArray *)parmas
{
    CLLocationCoordinate2D coords[1000] = {0};
    for (int i = 0; i < parmas.count; i ++) {
        NSDictionary *tempDict = [parmas objectAtIndex:i];
        NSString *latitude = [doJsonHelper GetOneText:tempDict :@"latitude" :@""];
        NSString *longitude = [doJsonHelper GetOneText:tempDict :@"longitude" :@""];
        coords[i].latitude = [latitude doubleValue];
        coords[i].longitude = [longitude doubleValue];
    }
    NSArray *colorIndexs = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:0], nil];
    _polyline = [BMKPolyline polylineWithCoordinates:coords count:parmas.count textureIndex:colorIndexs];
    [_mapView addOverlay:_polyline];
    return _polyline;
}
// 添加多边形遮盖物
- (id<BMKOverlay>) addPolygonOverlay:(NSArray *)parmas
{
    CLLocationCoordinate2D coords[1000] = {0};
    for (int i = 0; i < parmas.count; i ++) {
        NSDictionary *tempDict = [parmas objectAtIndex:i];
        NSString *latitude = [doJsonHelper GetOneText:tempDict :@"latitude" :@""];
        NSString *longitude = [doJsonHelper GetOneText:tempDict :@"longitude" :@""];
        coords[i].latitude = [latitude doubleValue];
        coords[i].longitude = [longitude doubleValue];
    }
    _polygon = [BMKPolygon polygonWithCoordinates:coords count:parmas.count];
    [_mapView addOverlay:_polygon];
    return _polygon;
}
// 添加圆弧遮盖物
- (id<BMKOverlay>) addArcOverlay:(NSArray *)parmas
{
    CLLocationCoordinate2D coords[3] = {0};
    for (int i = 0; i < parmas.count; i ++) {
        NSDictionary *tempDict = [parmas objectAtIndex:i];
        NSString *latitude = [doJsonHelper GetOneText:tempDict :@"latitude" :@""];
        NSString *longitude = [doJsonHelper GetOneText:tempDict :@"longitude" :@""];
        coords[i].latitude = [latitude doubleValue];
        coords[i].longitude = [longitude doubleValue];
    }
    _arcline = [BMKArcline arclineWithCoordinates:coords];
    [_mapView addOverlay:_arcline];
    return _arcline;
}

//城市内搜索
-(BMKCitySearchOption *) getCitySearchOption:(NSDictionary *)parma
{
    BMKCitySearchOption* option = [[BMKCitySearchOption alloc]init];
    option.city = [parma objectForKey:@"city"];
    return option;
}
//矩形内搜索
- (BMKBoundSearchOption *)getBoundSearchOption:(NSDictionary *)parma
{
    BMKBoundSearchOption *option = [[BMKBoundSearchOption alloc]init];
    NSString *leftBottom = [parma objectForKey:@"leftBottom"];
    NSString *rightTop = [parma objectForKey:@"rightTop"];
    NSArray *lefts = [leftBottom componentsSeparatedByString:@","];
    NSArray *rights = [rightTop componentsSeparatedByString:@","];
    CLLocationCoordinate2D _leftBottom = CLLocationCoordinate2DMake([lefts[0]floatValue ], [lefts[1] floatValue]);
    CLLocationCoordinate2D _rightTop = CLLocationCoordinate2DMake([rights[0] floatValue],[rights[1] floatValue]);
    option.leftBottom = _leftBottom;
    option.rightTop = _rightTop;
    return option;
}
//圆形内搜索
- (BMKNearbySearchOption *)getNearbySearchOption:(NSDictionary *)parma
{
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    NSString *location = [parma objectForKey:@"location"];
    NSString *radius = [parma objectForKey:@"radius"];
    NSArray *locS = [location componentsSeparatedByString:@","];
    CLLocationCoordinate2D _location = CLLocationCoordinate2DMake([locS[0]floatValue ], [locS[1] floatValue]);
    option.location = _location;
    option.radius = [radius floatValue];
    return option;
}
- (BMKBaseRoutePlanOption *)routePlanFactory:(NSString *)type
{
    BMKBaseRoutePlanOption *option;
    if ([[type lowercaseString] isEqualToString:@"bus"]) {
        option = [[BMKMassTransitRoutePlanOption alloc]init];
    }
    else if([[type lowercaseString] isEqualToString:@"ride"])
    {
        option = [[BMKRidingRoutePlanOption alloc]init];
    }
    else if([[type lowercaseString] isEqualToString:@"walk"])
    {
        option = [[BMKWalkingRoutePlanOption alloc]init];
    }
    else if([[type lowercaseString] isEqualToString:@"drive"])
    {
        option = [[BMKDrivingRoutePlanOption alloc]init];
    }
    return option;
}
- (BOOL)routeSearch:(BMKBaseRoutePlanOption *)option
{
    if ([option isKindOfClass:[BMKDrivingRoutePlanOption class]]) {
        return  [_routesearch drivingSearch:(BMKDrivingRoutePlanOption *)option];
    }
    else if ([option isKindOfClass:[BMKWalkingRoutePlanOption class]])
    {
        return  [_routesearch walkingSearch:(BMKWalkingRoutePlanOption *)option];
    }
    else if ([option isKindOfClass:[BMKRidingRoutePlanOption class]])
    {
        return  [_routesearch ridingSearch:(BMKRidingRoutePlanOption *)option];
    }
    else if ([option isKindOfClass:[BMKMassTransitRoutePlanOption class]])
    {
        return [_routesearch massTransitSearch:(BMKMassTransitRoutePlanOption*)option];
    }
    return NO;
}
//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}
#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
