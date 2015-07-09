//
//  doUIModuleContainer.h
//  libDolib
//
//  Created by linliyuan on 14-11-11.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import "doUIModule.h"
#import <UIKit/UIKit.h>

@interface doUIModuleCollection : doUIModule

@property(strong,nonatomic,readonly) NSMutableArray* ChildUIModules;
@property(assign,nonatomic)double InnerXZoom;
@property(assign,nonatomic)double InnerYZoom;
//所有容器类都具有add方法，可以增加一个子view，add方法实现整体逻辑，AddSubview给子类override
- (NSString*)Add:(id<doIScriptEngine>) _scriptEngine :(NSString*) _path : (NSString*) _targetX : (NSString*) _targetY :(NSString*) _viewid;
-(void) AddSubview:(doUIModule*) _model;
@end
