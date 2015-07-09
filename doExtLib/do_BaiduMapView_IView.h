//
//  do_BaiduMapView_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_BaiduMapView_IView <NSObject>

@required
//属性方法
- (void)change_zoomLevel:(NSString *)newValue;

//同步或异步方法
- (void)addMarkers:(NSArray *)parms;
- (void)removeAll:(NSArray *)parms;
- (void)removeMarker:(NSArray *)parms;
- (void)setCenter:(NSArray *)parms;


@end