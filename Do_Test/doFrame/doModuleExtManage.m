//
//  doModuleExtManage.m
//  Do_Test
//
//  Created by 刘吟 on 15/5/18.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "doModuleExtManage.h"

@implementation doModuleExtManage
-(NSString*) GetIdentifier:(NSString*) resName :(NSString*) pluginKey
{
    return nil;
}

- (NSString *)GetThirdAppKey:(NSString *) fileName :(NSString *) key
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (plistPath && ![plistPath isEqualToString:@""])
    {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        if (info != nil && info.count > 0)
        {
            return info[key];
        }
    }
    return @"";
}
@end
