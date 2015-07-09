//
//  doService.h
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import "doIEventCallBack.h"
#import "doServiceContainer.h"
#import "doInvokeResult.h"
#import "doModule.h"
#import "doScriptEngine.h"
#import "doLogEngine.h"
#import "doIScriptEngineFactory.h"

@interface doService : NSObject
+(doService*) Instance;
-(void)Init ;

-(void)SetPropertyValue:(doModule *)_module :(NSString *)_propertyID :(NSString *)_value ;

-(void)SyncMethod:(doModule *)_module :(NSString *)_methodName : (NSMutableDictionary *)_paras ;
-(void)AsyncMethod:(doModule *)_module :(NSString *)_methodName : (NSMutableDictionary *)_paras :(id<doIEventCallBack>)_eventCallBack ;

-(void)SubscribeEvent:(doModule *)_moduel :(NSString *)_eventID :(id<doIEventCallBack>)_eventCallBack;
@end
