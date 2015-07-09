//
//  doModuleFactory.m
//  Do_Test
//
//  Created by 刘吟 on 15/5/14.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "doModuleFactory.h"
#import "ViewController.h"

@implementation doModuleFactory
-(id) init:(id) _model {
    self = [super init];
    model = _model;
    return self;
}
- (doSingletonModule *) GetSingletonModuleByID: (id<doIScriptEngine>) _scriptEngine : (NSString *) _typeID
{
    return model;
}
- (doSingletonModule *) GetSingletonModuleByAddress:(NSString *)_key
{
    return nil;
}
- (void)RegistGroup: (id<doISingletonModuleGroup>) _moduleGroup
{
    return ;
}
-(void) RemoveSingletonModuleByAddress:(NSString*) _address
{
    return;
}
@end
