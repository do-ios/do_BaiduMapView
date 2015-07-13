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
#import "BaiduMapAPI/BMapKit.h"
#import "doJsonHelper.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"

BMKMapManager *_mapManager;
BMKMapView *_mapView;
@interface do_BaiduMapView_UIView() <BMKMapViewDelegate, BMKGeneralDelegate>
@end
@implementation do_BaiduMapView_UIView
{
    BMKPointAnnotation *_pointAnnotation;
    NSMutableDictionary *_dictPointAnnotation;
    NSString *_annotationID;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    NSString *_BMKMapKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduMapAppKey.plist" :@"baiduMapAppKey" ];
    if (!_mapManager)
    {
        _mapManager = [[BMKMapManager alloc]init];
        [_mapManager start:_BMKMapKey generalDelegate:self];
    }
    if (!_mapView)
    {
        _mapView = [[BMKMapView alloc]init];
    
        [_mapView setFrame:CGRectMake(_model.RealX, _model.RealY, _model.RealWidth, _model.RealHeight)];
        [self addSubview:_mapView];
        [_mapView setZoomLevel:11];
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(39.9255, 116.3995);
        _mapView.delegate = self;
//    [_mapView viewWillAppear];
    }
    
}
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    if (_mapView)
    {
//        [_mapView viewWillDisappear];
        _mapView.delegate = nil;
        _mapView = nil;
        
    }
}

//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_zoomLevel:(NSString *)newValue
{
    //自己的代码实现
    if (newValue == nil || [newValue isEqualToString:@""])
    {
        newValue = [(doUIModule *)_model GetProperty:@"zoomLevel"].DefaultValue;
    }
    _mapView.zoomLevel = [newValue floatValue];
}

#pragma mark -
#pragma mark - 同步异步方法的实现
//同步
- (void)addMarkers:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    _pointAnnotation = [[BMKPointAnnotation alloc]init];
    NSString *latitude = _dictParas[@"latitude"];
    NSString *longitude = _dictParas[@"longitude"];
    if (latitude == nil || [latitude isEqualToString:@""] || longitude == nil || [longitude isEqualToString:@""])
    {
        [_invokeResult SetResultBoolean:NO];
    }
    else
    {
        CLLocationCoordinate2D coor;
        coor.latitude = [latitude floatValue];
        coor.longitude = [longitude floatValue];
        _pointAnnotation.coordinate = coor;
        _annotationID = _dictParas[@"id"];
        _pointAnnotation.title = _dictParas[@"url"];
        _pointAnnotation.subtitle = _dictParas[@"info"];
        [_mapView addAnnotation:_pointAnnotation];
        [_dictPointAnnotation setValue:_pointAnnotation forKey:_annotationID];
        [_invokeResult SetResultBoolean:YES];
    }
}
- (void)removeAll:(NSArray *)parms
{
    for (id key in _dictPointAnnotation.allKeys) {
        [_mapView removeAnnotation:_dictPointAnnotation[key]];
    }
    [_dictPointAnnotation removeAllObjects];
}
- (void)removeMarker:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *_pointAnnotationID = _dictParas[@"id"];
    if ([_dictPointAnnotation objectForKey:_pointAnnotationID] != nil)
    {
        [_mapView removeAnnotation:_dictPointAnnotation[_pointAnnotationID]];
        [_dictPointAnnotation removeObjectForKey:_pointAnnotationID];
        [_invokeResult SetResultBoolean:YES];
    }
    else
    {
        [_invokeResult SetResultBoolean:NO];
    }
}
- (void)setCenter:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *latitude = _dictParas[@"latitude"];
    NSString *longitude = _dictParas[@"longitude"];
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

#pragma mark - BMKMapViewDelegate
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKPinAnnotationView *_annotationView;
    if (annotation == _pointAnnotation) {
        NSString *AnnotationViewID = @"renameMark";
        _annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (_annotationView == nil) {
            _annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
            _annotationView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
            _annotationView.animatesDrop = YES;
            // 设置可拖拽
            _annotationView.draggable = YES;
        }
    }
    return _annotationView;
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_invokeResult setValue:_annotationID forKey:@"pointAnnotationID"];
    [_model.EventCenter FireEvent:@"touchMarker":_invokeResult];
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
