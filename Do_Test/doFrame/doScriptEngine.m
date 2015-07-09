//
//  doScriptEngine.m
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import "doScriptEngine.h"
#import "doCallBackTask.h"
#import "doInvokeResult.h"

@implementation doScriptEngine
{
@private
    NSMutableDictionary* dictCallBack;
}
@synthesize CurrentApp;
@synthesize CurrentPage;

- (void) Init
{
    dictCallBack = [[NSMutableDictionary alloc] init];
}
//释放资源
- (void) Dispose
{
    
}
//函数回调
- (void) Callback:(NSString *)_methodName :(doInvokeResult *)_invokeResult
{
    if (![dictCallBack.allKeys containsObject:_methodName]) {
        return;
    }
    @try {
        [[dictCallBack objectForKey:_methodName] eventCallBack:[_invokeResult GetResult] ];
    } @catch (NSException* e) {
       
    }
}
//运行脚本
- (void) LoadScripts:(NSString *)_scripts
{
    
}
//创建回调任务
- (doCallBackTask *) CreateCallBackTask:(NSString *)_callBackMethodName
{
    doCallBackTask* _callbackTask = [[doCallBackTask alloc]init:self :_callBackMethodName];
    return _callbackTask;
}

-(void) CallLoadScriptsAsModel:(NSString *)_scripts : (NSString*) libname
{
    
}
-(void) CallLoadScriptsAsModelWithPreDefine:(NSString*) uiRootViewAddress :(NSString *)_scripts
{
    
}

-(doInvokeResult*) CreateInvokeResult:(NSString*) _uniqueKey
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_uniqueKey];
    return _invokeResult;
}

-(void) AddCallBack:(NSString*) _eventID : (id<doIEventCallBack>) _eventCallBack
{
    [dictCallBack setObject:_eventCallBack forKey:_eventID];
}
@end
