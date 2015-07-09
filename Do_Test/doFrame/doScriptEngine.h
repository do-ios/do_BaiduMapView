//
//  doScriptEngine.h
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "doIScriptEngine.h"
#import "doIEventCallBack.h"

@interface doScriptEngine : NSObject<doIScriptEngine>
-(doInvokeResult*) CreateInvokeResult:(NSString*) _uniqueKey;
-(void) AddCallBack:(NSString*) _eventID : (id<doIEventCallBack>) _eventCallBack;
@end
