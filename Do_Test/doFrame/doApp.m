//
//  doApp.m
//  doText
//
//  Created by Doviceone on 15/4/7.
//  Copyright (c) 2015年 Doviceone. All rights reserved.
//

#import "doApp.h"
#import "doDataFs.h"

static doApp *_app;

@implementation doApp : NSObject
@synthesize AppID;
@synthesize DataFS;
@synthesize SourceFS;
@synthesize Config;
@synthesize ScriptEngine;
-(id)init
{
    self = [super init];
    DataFS = [[doDataFs alloc]init];
    return self;
}
- (id<doIConfig>) GetConfig:(NSString *) _adapterID
{
    return nil;
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
-(void) Dispose
{
    
}
@end;
