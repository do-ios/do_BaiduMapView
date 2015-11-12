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
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Base/BMKGeneralDelegate.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <objc/runtime.h>

BMKMapManager *_mapManager;
BMKMapView *_mapView;
NSString *_modelString;

@interface do_BaiduMapView_UIView() <BMKMapViewDelegate, BMKGeneralDelegate>
@end
@implementation do_BaiduMapView_UIView
{
    NSMutableDictionary *_dictAnnotation;
    NSMutableDictionary *_dictImags;
    NSString *_annotationID;
    NSDictionary *dict;
    id<doIScriptEngine> _scritEngine;
    NSString *_callbackName;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    NSString *_BMKMapKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduMapAppKey.plist" :@"baiduMapAppKey" ];
    
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
    _mapView.delegate = self;
    _dictAnnotation = [[NSMutableDictionary alloc]init];
    _dictImags = [[NSMutableDictionary alloc]init];
}

//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    
    [self removeAll:nil];
    _dictAnnotation = nil;
    _dictImags = nil;
    if(_mapManager)
    {
        [_mapManager stop];
    }
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
    else if(level > 18)
    {
        level = 18;
    }
    _mapView.zoomLevel = level;
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
    for (id _annotation in _dictParas[@"data"]) {
        BMKPointAnnotation *_pointAnnotation = [[BMKPointAnnotation alloc]init];
        NSString *latitude = _annotation[@"latitude"];
        NSString *longitude = _annotation[@"longitude"];
        NSString *imagPath = _annotation[@"url"];
        NSString *info = _annotation[@"info"];
        if (latitude == nil || [latitude isEqualToString:@""] || longitude == nil || [longitude isEqualToString:@""])
        {
            [_invokeResult SetResultBoolean:NO];
            return;
        }
        else
        {
            CLLocationCoordinate2D coor;
            coor.latitude = [latitude floatValue];
            coor.longitude = [longitude floatValue];
            [_pointAnnotation setTitle:info];
            [_pointAnnotation setCoordinate:coor];
            _annotationID = _annotation[@"id"];
            for (id key in _dictAnnotation.allKeys) {
                if ([key isEqualToString:_annotationID]) {
                    [_mapView removeAnnotation:_dictAnnotation[key]];
                    break;
                }
            }
            [_dictAnnotation setValue:_pointAnnotation forKey:_annotationID];
            [_dictImags setValue:imagPath forKey:_annotationID];
            [_mapView addAnnotation:_pointAnnotation];
        }
    }
    [_invokeResult SetResultBoolean:YES];
}
- (void)removeAll:(NSArray *)parms
{
    for (id key in _dictAnnotation.allKeys) {
        [_mapView removeAnnotation:_dictAnnotation[key]];
    }
    [_dictAnnotation removeAllObjects];
    [_dictImags removeAllObjects];
}

- (void)removeMarker:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *_pointAnnotationID = _dictParas[@"ids"][0];
    if ([_dictAnnotation objectForKey:_pointAnnotationID] != nil)
    {
        [_mapView removeAnnotation:_dictAnnotation[_pointAnnotationID]];
        [_dictAnnotation removeObjectForKey:_pointAnnotationID];
        [_dictImags removeObjectForKey:_pointAnnotationID];
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
    UIImage * image = [UIImage imageWithContentsOfFile:imgPath];
    NSMutableArray *images = [NSMutableArray array];
    [images addObject:image];
    
    _annotationView.annotationImages = images;
    _annotationView.draggable = YES;
    return _annotationView;
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init];
    [_invokeResult SetResultText:_dictAnnotation[@"AnimatedAnnotation"]];
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
