//
//  doPage.m
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import "doPage.h"
#import "doApp.h"

@implementation doPage
@synthesize CurrentApp;
@synthesize PageView;
@synthesize UIFile;
@synthesize ScriptEngine;
@synthesize RootView;
@synthesize Data;
@synthesize IsFullScreen;
@synthesize SoftMode;


- (doUIModule *) CreateUIModule: (doUIContainer *)_uiContainer : (NSDictionary *) _moduleNode
{
    return nil;
}
- (void) RemoveUIModule: (doUIModule *)_module
{
    return;
}

- (doUIModule *) GetUIModuleByAddress: (NSString *) _key
{
    return nil;
}
- (void) LoadRootUiContainer
{
    return;
}
- (void) LoadScriptEngine: (NSString *) _scriptFile
{
    return;
}
-(doMultitonModule*) CreateMultitonModule:(NSString*) _typeID :(NSString*) _id
{
    return nil;
}
-(doMultitonModule*) GetMultitonModuleByAddress:(NSString*) _key
{
    return nil;
}
-(BOOL) DeleteMultitonModule:(NSString*) _address
{
    return NO;
}
- (void) Dispose
{
    return ;
}
@end
