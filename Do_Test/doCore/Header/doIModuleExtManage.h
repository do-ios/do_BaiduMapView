//
//  doIModuleExtManage.h
//  DoCore
//
//  Created by 刘吟 on 14/12/3.
//  Copyright (c) 2014年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIModuleExtManage 
#pragma mark -
@required
-(NSString*) GetIdentifier:(NSString*) resName :(NSString*) pluginKey;
@optional
- (NSString *)GetThirdAppKey:(NSString *) fileName :(NSString *) key;
@end
