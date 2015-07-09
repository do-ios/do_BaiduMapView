//
//  doModuleFactory.h
//  Do_Test
//
//  Created by 刘吟 on 15/5/14.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "doISingletonModuleFactory.h"
@interface doModuleFactory : NSObject<doISingletonModuleFactory>
{
    id model;
}
-(id) init:(id) _model;
@end
