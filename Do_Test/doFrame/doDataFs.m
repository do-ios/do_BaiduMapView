//
//  doDataFs.m
//  Do_Test
//
//  Created by 刘吟 on 15/5/12.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "doDataFs.h"

@implementation doDataFs
@synthesize CurrentApp;
@synthesize RootPath;
@synthesize PathSys;
@synthesize PathSysCache;
@synthesize PathPublic;
@synthesize PathPrivate;
@synthesize PathSecurity;
@synthesize PathPrivateTemp;
#pragma mark -
//获取完整的路径
- (NSString *)GetFileFullPathByName: (NSString *) _fileName
{
    if (![_fileName hasPrefix:@"data://"]){
        return nil;
    }
    NSString *relDir = [_fileName substringFromIndex:6];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* _RootPath = [[cachePaths objectAtIndex:0] stringByAppendingString:@"/test"];
    return [NSString stringWithFormat:@"%@%@",_RootPath,relDir];
}

//释放资源
- (void)Dispose
{
    
}
@end
