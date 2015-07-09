//
//  doIListData.h
//  DoCore
//
//  Created by 刘吟 on 15/4/8.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIListData <NSObject>
-(int) GetCount;
-(id) GetData:(int) index;
-(void) SetData:(int) index :(id) data;
-(NSString*) Serialize;
-(id) UnSerialize:(NSString*) str;
@end
