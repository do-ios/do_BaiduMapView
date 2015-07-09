//
//  doIHashData.h
//  DoCore
//
//  Created by 刘吟 on 15/4/25.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIHashData <NSObject>
-(NSArray*) GetAllKey;
-(id) GetData:(NSString*) key;
-(void) SetData:(NSString*) key :(id) data;
-(NSString*) Serialize;
-(id) UnSerialize:(NSString*) str;
@end
