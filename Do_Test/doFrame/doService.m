//
//  doService.m
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import "doService.h"
#import "doApp.h"
#import "doPage.h"
#import "doServiceContainer.h"
#import "doPageViewFactory.h"

static doService* Instace;
static int uniqueKeyCursor = 0;
@implementation doService
{
    @private
    doScriptEngine* TestScriptEngine;
}
+(doService*) Instance
{
    if(Instace==nil){
        Instace = [[doService alloc]init];
        [Instace Init];
    }
    return Instace;
}
-(void)Init {
    [doServiceContainer Instance].LogEngine = [[doLogEngine alloc] init];
    [doServiceContainer Instance].PageViewFactory = [[doPageViewFactory alloc] init];
    TestScriptEngine = [[doScriptEngine alloc] init];
    [TestScriptEngine Init];
}

-(void)SetPropertyValue:(doModule *)_module :(NSString *)_propertyID :(NSString *)_value {
    doInvokeResult *_invokeResult = [TestScriptEngine CreateInvokeResult:nil];
    @try {
        //设置text的参数
        NSMutableDictionary *_jsonPara = [[NSMutableDictionary alloc]init];
        [_jsonPara setObject:_value forKey:_propertyID];
        NSMutableDictionary *jsonNode = [[NSMutableDictionary alloc]init];
        [jsonNode setObject:_jsonPara forKey:@"data"];
        doApp* _doApp = [[doApp alloc]init];
        if(TestScriptEngine.CurrentApp==nil)
        {
            TestScriptEngine.CurrentApp = _doApp;
        }
        [ _module InvokeSyncMethod:@"set" :jsonNode :TestScriptEngine :_invokeResult ];
        NSString *str = [NSString stringWithFormat:@"设置属性成功：%@\n%@",_propertyID,[_invokeResult GetResult]];
        [[doServiceContainer Instance].LogEngine WriteDebug:str];
    }
    @catch (NSException *_err) {
        NSString *str2 = [NSString stringWithFormat:@"设置属性失败：%@",_propertyID];
        [[doServiceContainer Instance].LogEngine WriteError:_err :str2,nil];
    }
}

-(void)SyncMethod:(doModule *)_module :(NSString *)_methodName : (NSMutableDictionary *)_paras {
    doInvokeResult *_invokeResult = [TestScriptEngine CreateInvokeResult:nil];
    @try {
        NSMutableDictionary *_jsonPara = [[NSMutableDictionary alloc]init];
        if(_paras != nil)
        {
            for (NSString *key in [_paras allKeys]) {
                [_jsonPara setObject:[_paras objectForKey:key] forKey:key];
            }
        }
        
        doApp* _doApp = [[doApp alloc]init];
        if(TestScriptEngine.CurrentApp==nil)
        {
            TestScriptEngine.CurrentApp = _doApp;
        }
        
        [_module InvokeSyncMethod:_methodName :_jsonPara :TestScriptEngine :_invokeResult];
        
        [[doServiceContainer Instance].LogEngine WriteDebug:[NSString stringWithFormat:@"调用同步方法成功：%@\n%@",_methodName,[_invokeResult GetResult]]];
    }
    @catch (NSException *_err) {
        [[doServiceContainer Instance].LogEngine WriteError:_err :[NSString stringWithFormat:@"调用同步方法失败：%@",_methodName]];
    }
}

-(void)AsyncMethod:(doModule *)_module :(NSString *)_methodName : (NSMutableDictionary *)_paras :(id<doIEventCallBack>)_eventCallBack {
    @try {
        NSMutableDictionary *_jsonPara = [[NSMutableDictionary alloc]init];
        if(_paras != nil)
        {
            for (NSString *key in [_paras allKeys]) {
                [_jsonPara setObject:[_paras objectForKey:key] forKey:key ];
            }
        }
        NSString *_uniqueKey = [NSString stringWithFormat:@"doCallBackKey_%d",uniqueKeyCursor++];
        doApp* _doApp = [[doApp alloc]init];
        if(TestScriptEngine.CurrentApp==nil)
        {
            TestScriptEngine.CurrentApp = _doApp;
        }
        [TestScriptEngine AddCallBack:_uniqueKey :_eventCallBack];
        [_module InvokeAsyncMethod:_methodName :_jsonPara :TestScriptEngine :_uniqueKey ];
        [[doServiceContainer Instance].LogEngine WriteDebug:[NSString stringWithFormat:@"调用异步方法成功:%@",_methodName]];
    }
    @catch (NSException *_err) {
        [[doServiceContainer Instance].LogEngine WriteError: _err :[NSString stringWithFormat:@"调用异步方法失败:%@",_methodName]];
    }
}

-(void)SubscribeEvent:(doModule *)_moduel :(NSString *)_eventID :(id<doIEventCallBack>)_eventCallBack {
    @try {
        NSString *_messageName = _eventID;
        doApp* _doApp = [[doApp alloc]init];
        if(TestScriptEngine.CurrentApp==nil)
        {
            TestScriptEngine.CurrentApp = _doApp;
        }
        [TestScriptEngine AddCallBack:_eventID :_eventCallBack];
        [_moduel.EventCenter Subscribe:_messageName :_eventID :TestScriptEngine ];
        [[doServiceContainer Instance].LogEngine WriteDebug: [NSString stringWithFormat:@"订阅消息成功:%@",_eventID]];
    }
    @catch (NSException *_err) {
        [[doServiceContainer Instance].LogEngine WriteError:_err : @"设置属性失败\n"];
    }
}

@end
