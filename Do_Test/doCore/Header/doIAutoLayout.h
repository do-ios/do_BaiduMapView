//
//  doIAutoLayout.h
//  DoCore
//
//  Created by 刘吟 on 15/5/16.
//  Copyright (c) 2015年 DongXian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol doIAutoLayout <NSObject>
//当一个collectionview支持自动布局，比如width，height为-1的时候可以自动布局
- (void) OnResize;
@end
