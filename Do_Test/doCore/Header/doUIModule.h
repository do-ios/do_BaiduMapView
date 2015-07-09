//
//  doUIModule.h
//  libDolib
//
//  Created by linliyuan on 14-11-11.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import "doModuleBase.h"
@protocol doIPage;
@class doInvokeResult;
@protocol doIUIModuleView;
@class doProperty;
@class doUIModuleCollection;
@class doUIContainer;

@interface doMargins : NSObject
@property(assign,nonatomic)double l;//左
@property(assign,nonatomic)double t;//上
@property(assign,nonatomic)double r;//右
@property(assign,nonatomic)double b;//下
-(id) init:(NSString*) _mar;
-(void) SetData:(NSString*) _mar;
@end

@interface doUIModule : doModuleBase
{
@private
    NSString* uiid;
    NSMutableDictionary* initilizedProperties;
    doMargins* margins;
}
#pragma mark -
@property(strong,nonatomic) doUIModuleCollection* ParentUICollection;//当前所属父控件
@property(strong,nonatomic)doUIContainer* CurrentUIContainer;//当前所属视图
@property(strong,nonatomic)id<doIUIModuleView> CurrentUIModuleView;//相关的组件
@property(strong,nonatomic)doUIContainer* UIContainer;//如果是一个RootView，这个值才有值，否则为nil
@property(strong,nonatomic,readonly)NSString* ID;//
@property(assign,nonatomic)double X;
@property(assign,nonatomic)double Y;
@property(assign,nonatomic)double Width;
@property(assign,nonatomic)double Height;
//控件转换到设备上的坐标和尺寸
@property(assign,nonatomic)double XZoom;
@property(assign,nonatomic)double YZoom;
@property(assign,nonatomic)double RealX;
@property(assign,nonatomic)double RealY;
@property(assign,nonatomic)double RealWidth;
@property(assign,nonatomic)double RealHeight;
@property(assign,nonatomic)NSString* Tag;
@property(strong,nonatomic)doMargins* Margins;

#pragma mark -
- (void) LoadView;

@end